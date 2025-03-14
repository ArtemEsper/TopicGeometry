from google.cloud import bigquery
from config import PROJECT_ID, DATASET_ID, BUCKET_NAME

# Define mapping of GCS folders to BigQuery table names
TABLE_MAPPINGS = {
    "meta": "meta_raw",
    "unigrams": "unigrams_raw",
    "bigrams": "bigrams_raw",
    "trigrams": "trigrams_raw"
}

# Schema for metadata files (folder == "meta")
schema_meta = [
    bigquery.SchemaField("id", "STRING"),
    bigquery.SchemaField("title", "STRING"),
    bigquery.SchemaField("isPartOf", "STRING"),
    bigquery.SchemaField("publicationYear", "STRING"),  # or INT64 if purely numeric
    bigquery.SchemaField("doi", "STRING"),
    bigquery.SchemaField("docType", "STRING"),
    bigquery.SchemaField("docSubType", "STRING"),
    bigquery.SchemaField("provider", "STRING"),
    bigquery.SchemaField("collection", "STRING"),
    bigquery.SchemaField("datePublished", "STRING"),  # or DATE/TIMESTAMP if consistent
    bigquery.SchemaField("issueNumber", "STRING"),     # or INT64 if purely numeric
    bigquery.SchemaField("volumeNumber", "STRING"),    # e.g., "53/54"
    bigquery.SchemaField("url", "STRING"),
    bigquery.SchemaField("creator", "STRING"),
    bigquery.SchemaField("publisher", "STRING"),
    bigquery.SchemaField("language", "STRING"),
    bigquery.SchemaField("pageStart", "STRING"),       # or INT64 if numeric
    bigquery.SchemaField("pageEnd", "STRING"),         # or INT64 if numeric
    bigquery.SchemaField("placeOfPublication", "STRING"),
    bigquery.SchemaField("keyphrase", "STRING"),
    bigquery.SchemaField("wordCount", "INT64"),        # or STRING if non-numeric
    bigquery.SchemaField("pageCount", "INT64"),        # or STRING if non-numeric
    bigquery.SchemaField("outputFormat", "STRING"),
]

# Schema for n-gram files (folder == "unigrams" / "bigrams" / "trigrams")
schema_ngrams = [
    bigquery.SchemaField("id", "STRING"),
    bigquery.SchemaField("ngram", "STRING"),
    bigquery.SchemaField("count", "INT64"),
]

client = bigquery.Client(project=PROJECT_ID)

def load_csv_to_bigquery(folder_name, table_name):
    """Load CSV files from GCS into a BigQuery table, choosing different schemas."""
    gcs_uri = f"gs://{BUCKET_NAME}/raw/{folder_name}/*.csv"

    # Decide which schema to use
    if folder_name == "meta":
        chosen_schema = schema_meta
    else:
        chosen_schema = schema_ngrams  # for unigrams, bigrams, trigrams

    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,
        write_disposition=bigquery.WriteDisposition.WRITE_APPEND,
        autodetect=False,  # We are explicitly defining the schema
        schema=chosen_schema
    )

    table_ref = f"{PROJECT_ID}.{DATASET_ID}.{table_name}"
    print(f"🚀 Loading data from {gcs_uri} into {table_ref} with schema for {folder_name}...")

    try:
        load_job = client.load_table_from_uri(gcs_uri, table_ref, job_config=job_config)
        load_job.result()  # Wait for job completion
        print(f"✅ Successfully loaded data into {table_ref}")
    except Exception as e:
        print(f"❌ Error loading data into {table_ref}: {e}")

# Iterate over TABLE_MAPPINGS
for folder, table in TABLE_MAPPINGS.items():
    load_csv_to_bigquery(folder, table)

print("✅ All tables have been created and loaded!")
