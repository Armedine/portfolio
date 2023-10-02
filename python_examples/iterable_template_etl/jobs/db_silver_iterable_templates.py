import pyspark.sql.functions as F
from ngcp_dataeng_pyspark.common import DeltaUtils
from ngcp_dataeng_iterable_tooling.iterableconnector import IterableConnector
from ngcp_dataeng_iterable_tooling.utils import to_snake_case
from datetime import datetime, timedelta


# this job currently publishes both Bronze and Silver.


# configurable #####################
force_full_refresh = False
lookback_days = 2
####################################


# COMMAND ----------
# DBTITLE 1,

# generate Iterable connector with secrets (these cannot be used in a udf):
conn = IterableConnector(project="prod")
conn.creds[conn.project] = dbutils.secrets.get(
    scope="iterable_" + conn.project, key="api_key"
)
conn.api.cadence = 1.0
conn.build_header()

# get campaign metadata line items:
results = conn.get_campaign_metadata().json()["campaigns"]
# print(results)

# convert list of dictionaries into pyspark frame:
rdd = sc.parallelize(results)
campaign_metadata_df = spark.createDataFrame(rdd, samplingRatio=1000)

# fetch our manual export of Iterable journeys
journey_figma_map_df = (
    spark.read.format("csv")
    .option("header", "true")
    .load(
        "dbfs:/FileStore/shared_uploads/[REDACTED_USER_NAME]/[REDACTED_FILE_PATH].csv"
    )
)

# COMMAND ----------
# DBTITLE 1,

# get templates that are not attached to a campaign or journey:
results_all_templates = conn.get_all_email_templates(
    template_type="Base",
    medium="Email",
    start=(datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d %H:%M:%S"),
    end=datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
)
results_rdd = sc.parallelize(results_all_templates.json()["templates"])
if results_rdd.count() > 0:
    results_all_templates_df = (
        spark.createDataFrame(results_rdd, samplingRatio=100)
        .withColumn("type", F.lit("Base"))
        .withColumn("messageMedium", F.lit("Email"))
        .withColumnRenamed("creatorUserId", "createdByUserId")  # mismatched names.
        .drop(
            "messageTypeId",  # columns not in schema.
        )
    )
else:
    dbutils.notebook.exit("RDD was empty - no template updates found.")

# wrap into a new df with matching schema to campaign templates df:
empty_rdd = spark.sparkContext.emptyRDD()
empty_schema_df = spark.createDataFrame(empty_rdd, campaign_metadata_df.schema)

# merge schemas:
final_base_results_df = results_all_templates_df.unionByName(
    empty_schema_df, allowMissingColumns=True
)

# merge campaigns and base templates:
campaign_metadata_merged_df = campaign_metadata_df.unionByName(
    final_base_results_df, allowMissingColumns=True
)

# COMMAND ----------
# DBTITLE 1,


@F.udf
def udf_get_email_template(template_id, environment_api_key):
    """
    https://api.iterable.com/api/docs#templates_getEmailTemplate
    """
    conn.creds[conn.project] = environment_api_key
    conn.build_header()
    return conn.get_email_template(template_id).text


iterable_date_format = "%Y-%m-%dT%H:%M:%S+0000"

if force_full_refresh:
    lookback_days = 9999

email_templates_bronze = DeltaUtils(
    quality="bronze",
    provenance="iterable",
    dataset="templates_email",
    partition_field="created_at_date",
)

email_templates_silver = DeltaUtils(
    quality="silver",
    provenance="iterable",
    dataset="templates_email",
    partition_field="created_at_date",
)

# filter eligible message mediums:
email_campaigns_df = campaign_metadata_merged_df.filter(
    "messageMedium = 'Email'"
)

# get the json schema from the first template:
template_json_schema = F.schema_of_json(
    conn.get_email_template(
        email_campaigns_df.select("templateId").head()[0]
    ).text
)

# convert timestamps into readable datetimes, add row loaded for upserting, filter recently updated campaigns only:
email_campaigns_decorated_df = (
    email_campaigns_df.withColumn(
        "createdAtDate",
        F.to_date(
            F.to_timestamp(F.col("createdAt") / 1000)  # is in ms from api
        ),
    )
    .withColumn(
        "createdAtDateTime",
        F.to_timestamp(F.col("createdAt") / 1000),  # is in ms from api
    )
    .withColumn(
        "updatedAtDateTime",
        F.to_timestamp(F.col("updatedAt") / 1000),  # is in ms from api
    )
    .drop("createdAt", "updatedAt")
)

if not force_full_refresh:
    cut_off_date = (datetime.today() - timedelta(days=lookback_days)).strftime(
        iterable_date_format
    )
    email_campaigns_decorated_df = email_campaigns_decorated_df.filter(
        f"updatedAtDateTime >= '{cut_off_date}'"
    )

# fetch template data from api:
email_campaigns_decorated_final_df = (
    email_campaigns_decorated_df.join(
        journey_figma_map_df,
        on=(
            email_campaigns_decorated_df.workflowId
            == journey_figma_map_df.journeyId
        ),
        how="left",
    )
    .drop(
        "workflowId"  # api still has workflowId as identifier; in UI these are now journeys; our map has journeyId.
    )
    .withColumn(
        "templateContents",
        F.from_json(
            udf_get_email_template(
                F.col("templateId"),
                F.lit(
                    dbutils.secrets.get(
                        scope="iterable_" + conn.project, key="api_key"
                    )
                ),
            ),
            template_json_schema,
        ),
    )
)

# COMMAND ----------
# DBTITLE 1,

# flatten templateContents, rename 'name' column because it's shared in campaign and template api call:
flattened_template_df = email_campaigns_decorated_final_df.select(
    F.col("templateContents.*")
).withColumnRenamed("name", "templateName")

# join to original metadata, remove 'name' because it's shared in campaign and template api call:
email_campaigns_decorated_final_bronze_df = (
    email_campaigns_decorated_final_df.withColumnRenamed(
        "name", "campaignName"
    )
    .join(flattened_template_df, on="templateId", how="inner")
    .drop(
        "templateContents",
        "labels",
        "dataFeedIds",
        "ccEmails",
        "bccEmails",  # drop NullTypes and flattened column.
    )
)

# convert to snake case for delta standard:
for column in email_campaigns_decorated_final_bronze_df.columns:
    email_campaigns_decorated_final_bronze_df = (
        email_campaigns_decorated_final_bronze_df.withColumnRenamed(
            column, to_snake_case(column)
        )
    )

# COMMAND ----------
# DBTITLE 1,

# write bronze:
if not email_templates_bronze.spark.catalog.tableExists(
    email_templates_bronze.fully_qualified_table_name
):
    email_campaigns_decorated_final_bronze_df = (
        email_templates_bronze.append_load_metadata(
            spark_df=email_campaigns_decorated_final_bronze_df
        )
    )
    email_templates_bronze.save_with_date_parition(
        spark_df=email_campaigns_decorated_final_bronze_df,
        source_dt_field="created_at_date",
        save_mode="overwrite",
    )
else:
    query_filter = email_templates_bronze.pull_datetime_cutoff(
        table_dt_field="updated_at_date_time",
        look_back_interval=timedelta(days=-lookback_days),
        delta_partion_col="created_at_date",
    )
    email_campaigns_decorated_final_bronze_upsert_df = (
        email_campaigns_decorated_final_bronze_df.where(
            f"updated_at_date_time > '{query_filter}'"
        )
    )
    print(
        "adding templates to bronze:",
        email_campaigns_decorated_final_bronze_upsert_df.count(),
    )
    # load data into delta table
    email_templates_bronze.upsert_delta_table_unordered(
        update_df=email_campaigns_decorated_final_bronze_upsert_df,
        key_columns=["template_id"],
    )

# COMMAND ----------
# DBTITLE 1,

# write silver:
email_campaigns_decorated_final_silver_df = (
    email_campaigns_decorated_final_bronze_df.filter(
        F.col("journeyId").isNotNull()
    ).filter("campaignState = 'Running'")
)

if not email_templates_silver.spark.catalog.tableExists(
    email_templates_silver.fully_qualified_table_name
):
    email_campaigns_decorated_final_silver_df = (
        email_templates_silver.append_load_metadata(
            spark_df=email_campaigns_decorated_final_silver_df
        )
    )
    email_templates_silver.save_with_date_parition(
        spark_df=email_campaigns_decorated_final_silver_df,
        source_dt_field="created_at_date",
        save_mode="overwrite",
    )
else:
    query_filter = email_templates_silver.pull_datetime_cutoff(
        table_dt_field="updated_at_date_time",
        look_back_interval=timedelta(days=-lookback_days),
        delta_partion_col="created_at_date",
    )
    email_campaigns_decorated_final_silver_upsert_df = (
        email_campaigns_decorated_final_silver_df.where(
            f"updated_at_date_time > '{query_filter}'"
        )
    )
    print(
        "adding templates to silver:",
        email_campaigns_decorated_final_silver_upsert_df.count(),
    )
    # load data into delta table
    email_templates_silver.upsert_delta_table_unordered(
        update_df=email_campaigns_decorated_final_silver_upsert_df,
        key_columns=["template_id"],
    )
