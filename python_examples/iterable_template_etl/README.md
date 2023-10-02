# iterable_template_etl

**Note**: generic_api.py is quite old and does some weird stuff. I wrote that a long time ago for Marketo and modified it to fit Iterrable—it's on the to-do list to remake.

This is partial code used in a DBX-powered connector to Iterable from Databricks for the purpose of extracting existing emails into an s3 delta table.

With templates in s3, end users could then query our actual email content via Databricks SQL to extract or analyze copy, subject lines, etc., without the need for manual review (which was very time consuming and a massive interruption for campaign managers).

Despite its simplicity, this is one of those "hidden gems" and contributed to saving hundreds of hours of manual audits for Carvana.
