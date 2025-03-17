from google.cloud import bigquery
from config import DEDUPLICATION_SQL

# Initialize BigQuery client
client = bigquery.Client()

# 1. Read the SQL content from a file
with open(DEDUPLICATION_SQL, "r", encoding="utf-8") as f:
    sql_script = f.read()

# 2. Execute the multi-statement script in BigQuery
job = client.query(sql_script)
job.result()

print("✅ Deduplication script executed successfully!")
