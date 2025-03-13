from google.cloud import bigquery
from config import PROJECT_ID, DATASET_ID, BUCKET_NAME

# Define mapping of GCS folders to BigQuery table names
TABLE_MAPPINGS = {
    "meta": "meta_raw",
    "unigrams": "unigrams_raw",
    "bigrams": "bigrams_raw",
    "trigrams": "trigrams_raw"
}

# Initialize BigQuery client
client = bigquery.Client(project=PROJECT_ID)


def load_csv_to_bigquery(folder_name, table_name):
    """Load CSV files from GCS into a BigQuery table."""
    gcs_uri = f"gs://{BUCKET_NAME}/raw/{folder_name}/*.csv"  # GCS path

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        autodetect=True,  # Enable schema auto-detection
        skip_leading_rows=1,  # Skip headers if present
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND  # Append or replace data
    )

    # ✅ Fix: Ensure correct table reference format
    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{table_name}".strip(".")  # Remove any trailing dots

    print(f"🚀 Loading data from {gcs_uri} into {table_ref}...")

    try:
        load_job = client.load_table_from_uri(gcs_uri, table_ref, job_config=job_config)
        load_job.result()  # Wait for job to complete
        print(f"✅ Successfully loaded data into {table_ref}")
    except Exception as e:
        print(f"❌ Error loading data into {table_ref}: {e}")


# Load each folder into corresponding BigQuery table
for folder, table in TABLE_MAPPINGS.items():
    load_csv_to_bigquery(folder, table)

print("✅ All tables have been created and loaded!")
