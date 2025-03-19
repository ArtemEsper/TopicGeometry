import config
from google.cloud import bigquery


def main():
    # 1) Read settings from config file
    project_id = config.PROJECT_ID
    dataset_id = config.DATASET_ID
    # Table name can be whatever you define in config,
    # e.g., UNIGRAMS_CLEANED_TABLE = "unigrams_cleaned"
    unigrams_table = config.UNIGRAMS_CLEANED_TABLE  # or define your own variable name

    # 2) Construct the final table reference (backticks for BQ syntax)
    final_table_ref = f"`{project_id}.{dataset_id}.{unigrams_table}`"

    # 3) Build the query string
    query = f"""
CREATE OR REPLACE TABLE {final_table_ref} AS
SELECT
  * EXCEPT(ngram),
  TRIM(LOWER(ngram)) AS ngram
FROM `{{your_project}}.{{your_dataset}}.{{dedup_table}}`
WHERE
  -- 1) Not a short word (1 or 2 letters)
  LENGTH(TRIM(ngram)) NOT BETWEEN 1 AND 2

  -- 2) If it’s 3 letters, must be one of these
  AND NOT (
    LENGTH(TRIM(ngram)) = 3
    AND LOWER(TRIM(ngram)) NOT IN ("law", "job", "age", "tax", "war", "usa")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 4
    AND LOWER(TRIM(ngram)) NOT IN ("work", "city")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 5
    AND LOWER(TRIM(ngram)) NOT IN ("urban", "state", "grant", "japan", "spain", "trump", "egypt", "islam", "kenya", "local")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 6
    AND LOWER(TRIM(ngram)) NOT IN ("policy", "public", "region", "budget", "county", "zoning")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 7
    AND LOWER(TRIM(ngram)) NOT IN ("citizen", "service", "council", "finance", "charter")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 8
    AND LOWER(TRIM(ngram)) NOT IN ("election", "planning", "governor")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 9
    AND LOWER(TRIM(ngram)) NOT IN ("community", "democracy", "authority", "territory", "ordinance")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 10
    AND LOWER(TRIM(ngram)) NOT IN ("leadership", "compliance", "federalism")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 11
    AND LOWER(TRIM(ngram)) NOT IN ("bureaucracy")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 12
    AND LOWER(TRIM(ngram)) NOT IN ("coordination", "constitution", "metropolitan", "unemployment", "bureaucratic")
  )

  -- 3) Exclude numeric, special chars, underscore, multi-token
  AND NOT REGEXP_CONTAINS(
    TRIM(LOWER(ngram)),
    r'[^\w\s]|\d|^(?:_.*)|(?:_.*)$|\s'
  )

  -- 4) Exclude empty
  AND TRIM(LOWER(ngram)) <> '';
"""

    # We need to replace {{your_project}}.{{your_dataset}} with correct references
    # If you want e.g., `clarivate-datapipline-project.lg_jstor.unigrams_deduplicated`, do:
    dedup_project = config.PROJECT_ID
    dedup_dataset = config.DATASET_ID
    dedup_table = config.UNIGRAMS_DD_TABLE
    query = query.format(
        your_project=dedup_project,
        your_dataset=dedup_dataset,
        dedup_table=dedup_table
    )

    # 4) Execute the query
    client = bigquery.Client(project=project_id)
    job = client.query(query)
    job.result()  # Wait for completion

    print("✅ Created unigrams_cleaned table successfully!")


if __name__ == "__main__":
    main()
