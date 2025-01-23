# Data Cleaning Pipeline for JSTOR Metadata and N-gram Files

This project aims to automate the preprocessing of JSTOR metadata and n-gram files from the Constellate dataset. It cleans ASCII null characters and excess whitespace, prepares metadata for analysis, and uploads cleaned files to Google Cloud Storage for further processing in BigQuery.

## Project Structure

- **`config.py`**: Stores file paths and Google Cloud project information.
- **`removeascii.py`**: Cleans ASCII null characters from metadata files.
- **`csv_newdelimeters.py`**: Removes excess whitespace and adds newline delimiters to other CSV files.
- **`main.py`**: Orchestrates the pipeline by calling the cleaning scripts on relevant files.

## Getting Started

1. **Prerequisites**:
   - Python 3.x
   - Required Python libraries: `csv`, `re`, `os`, `google-cloud-storage`
   - Google Cloud SDK for uploading cleaned files to Google Cloud Storage

2. **Configuration**:
   - Set file paths and bucket details in `config.py`. 
   - Example:
     ```python
     # config.py
     RAW_META_DATA_PATH = "metadata file path"
     CLEANED_META_DATA_PATH = "cleaned metadata file path"
     RAW_DATA_PATH = "path to a folder with uni-,bi-, and trigrams csv files"
     CLEANED_DATA_PATH = "path to a folder with cleaned uni-,bi-, and trigrams csv files"
     BUCKET_NAME = "GCP_bucket_name"
     PROJECT_NAME = "GCP_project_name"
     DATASET_NAME = "dataset_name"
     ```

## Pipeline Workflow

### Step 1: Clean Metadata Files
The `removeascii.py` script cleans ASCII null characters from metadata files.

- **Usage**:
  ```bash
  python removeascii.py
Process:
Loops through all files in RAW_META_DATA_PATH.
Cleans each file of ASCII null characters.
Saves cleaned files in CLEANED_META_DATA_PATH.

### Step 2: Clean N-gram and Other Data Files
The csv_newdelimeters.py script preprocesses whitespace and adds newline delimiters to n-gram and 
other non-metadata files.
- **Usage**:
  ```bash
  python csv_newdelimeters.py

Process:
Loops through all files in RAW_DATA_PATH.
Removes excessive whitespace and adjusts newline delimiters.
Saves processed files in CLEANED_DATA_PATH.

### Step 3: Upload to Google Cloud Storage
Once the files are cleaned, they can be uploaded to Google Cloud Storage for further processing.

- **Usage**:
  ```bash
  ppython main.py --upload

Process:
The cleaned files in CLEANED_META_DATA_PATH and CLEANED_DATA_PATH are uploaded to the specified bucket in 
Google Cloud Storage.

### Step 4: Load Cleaned Files into BigQuery
- **Usage**:
  Use the following BigQuery CLI command to load each file as a separate table:
  ```bash
  bq load --source_format=CSV --autodetect \
  --skip_leading_rows=1 \
  --field_delimiter="\"" \
  --project_id=<your_project_id> \
  <your_dataset>.<table_name> \
  gs://<bucket_name>/<path_to_file>
  
Once the files are in Google Cloud Storage, they can be loaded into BigQuery as separate tables for analysis.

### Step 4a: Clean uni, bi and trigrams tables from the stopwords and various special characters like punctuation and etc.
Use files s4_uni_cleaning.sql, s4_bi_cleaning.sql, s4_tri_cleaning.sql.
The cleaning is incomplete and can be updated to remove more irrelevant words that can not be a part of scientific ontology.

### Step 5: Extract unique keywords from metadata table and distribute them across three tables of unigrams, bigrams and trigrams  
Use s5_keyword_extract.sql to separately extract uni-, bi- and trigrams from the 'keyword' column in the meta table 
and attribute keywords with uniq id for the extracted keywords and add appropriate prefix U_, B_ and T_.

### Step 8: Update the keywords tables with the manually selected most frequent words from a cleaned uni-, bi- and trigram tables
### and give to a new concepts distinct id with UN_, BN_ and TN_ prefixes
The most frequent keywords that can be considered as a concepts stored in 'selected_keywords_uni.csv', 
'selected_keywords_bi.csv' and 'selected_keywords_tri.csv' files.

### Step 9: Join JSTOR meta table with WOS_references and WOS_addresses to extract countries and journal titles
 -- metatable_jstor_wos.sql

### Step 10: Join the keywords table from step 9 and uni-, bi- and trigram tables to find their frequency across documents
 -- tables_match.sql
### Notes
Ensure config.py is correctly configured with your file paths and Google Cloud details before running the pipeline.
To run specific scripts, call them directly with python removeascii.py or python csv_newdelimeters.py.
The cleaning steps apply only to files that match the designated paths in config.py.

### Future Improvements
Implement logging for more robust monitoring.
Add validation steps to ensure data consistency before uploading.
Implement more extensive cleaning.

### License
This project is licensed under the MIT License.


### Explanation of `README.md` Sections

- **Project Structure**: Summarizes the role of each main file.
- **Getting Started**: Lists prerequisites and setup steps for `config.py`.
- **Pipeline Workflow**: Details each step of the ETL process, with usage instructions.
- **Notes**: Provides reminders for setup verification and testing individual scripts.
- **Future Improvements**: Suggests potential upgrades for pipeline robustness.
