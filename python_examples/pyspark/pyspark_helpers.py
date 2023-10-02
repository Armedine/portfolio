import re
from pyspark.sql.dataframe import DataFrame
from colorama import Fore, Style
from pyspark.sql import SparkSession


def get_col_type(df, column_name):
    return [dtype for name, dtype in df.dtypes if name == column_name][0]


def get_db_utils(spark):
    dbutils = None
    if spark.conf.get("spark.databricks.service.client.enabled") == "true":
        from pyspark.dbutils import DBUtils
        dbutils = DBUtils(spark)
    else:
        import IPython
        dbutils = IPython.get_ipython().user_ns["dbutils"]
    return dbutils


def camel_to_snake(name: str):
    name = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', name)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', name).lower()


def rename_df_columns_to_snake(df: DataFrame) -> DataFrame:
    new_df = df
    for col in new_df.columns:
        res = any(ele.isupper() for ele in col)
        if res:
            new_df = new_df.withColumnRenamed(col, camel_to_snake(col))
    return new_df


def spark_session(appName: str = "audience_builder"):
    return SparkSession.builder.appName(appName).getOrCreate()


class ColorPrint:

    @staticmethod
    def get_red(s):
        return Fore.RED + str(s) + Style.RESET_ALL

    @staticmethod
    def get_green(s):
        return Fore.GREEN + str(s) + Style.RESET_ALL

    @staticmethod
    def get_yellow(s):
        return Fore.YELLOW + str(s) + Style.RESET_ALL

    @staticmethod
    def get_cyan(s):
        return Fore.CYAN + str(s) + Style.RESET_ALL

    @staticmethod
    def get_purple(s):
        return Fore.MAGENTA + str(s) + Style.RESET_ALL

    @staticmethod
    def red(s):
        print(Fore.RED + str(s) + Style.RESET_ALL)

    @staticmethod
    def green(s):
        print(Fore.GREEN + str(s) + Style.RESET_ALL)

    @staticmethod
    def yellow(s):
        print(Fore.YELLOW + str(s) + Style.RESET_ALL)

    @staticmethod
    def cyan(s):
        print(Fore.CYAN + str(s) + Style.RESET_ALL)
