# Data Cleaning Pipeline for JSTOR Metadata and N-gram Files

This project aims to automate the preprocessing of JSTOR metadata and n-gram files from 
the Constellate dataset. It cleans ASCII null characters and excess whitespace, prepares metadata 
for analysis, and uploads cleaned files to Google Cloud Storage for further processing in BigQuery.

## Project Structure

- **`config.py`**: Stores file paths and Google Cloud project information.
- **`data_cleaning.py`**: Combines the logic for ASCII characters cleaning and setting correct line delimiters.
- **`GCPstorage_upload.py`**: Sorts and uploads metadata and data files in separate folders (metadata, 
unigrams, bigrams and trigrams)
- **`bq_upload.py`**: Uploads files from Cloud Storage to BigQuery. Create four tables 'meta_raw', 'unigrams_raw', 
'bigrams_raw' and 'trigrams_raw'.
- **`pipline.py`**: Orchestrates the cleaning and uploading steps.

## Getting Started

1. **Prerequisites**:
   - Python 3.x
   - Required Python libraries: `csv`, `re`, `os`, `chardet`, `shutil`, `google-cloud-storage`, `google.api_core.exceptions`
   - Google Cloud SDK for uploading cleaned files to Google Cloud Storage

2. **Configuration**:
   - Set local file paths, bucket details and BQ dataset in `config.py`. 
   - Example:
     ```python
     # config.py
     RAW_META_DATA_PATH = "metadata file path"
     CLEANED_META_DATA_PATH = "cleaned metadata file path"
     RAW_DATA_PATH = "path to a folder with uni-,bi-, and trigrams csv files"
     CLEANED_DATA_PATH = "path to a folder with cleaned uni-,bi-, and trigrams csv files"
     BUCKET_NAME = "GCP_bucket_name"
     PROJECT_ID = "GCP_project_name"
     DATASET_ID = "BigQuery dataset name"
     ```

## Pipeline Workflow

### Step 1: Clean Metadata Files (part of pipline.py)
The `data_cleaning.py` script cleans ASCII null characters from metadata files and sets correct newline delimiters.

Process:
Loops through all files in RAW_META_DATA_PATH and RAW_DATA_PATH.
Cleans each file of ASCII null characters and preprocesses whitespace and adds newline delimiters to n-gram and 
other metadata files.
Saves cleaned meta files in CLEANED_META_DATA_PATH and data files in CLEANED_DATA_PATH.
- **Usage**:
  ```bash
  python data_cleaning.py

### Step 2: Sort and upload files to GCP bucket (part of pipline.py)
The `GCPstorage_upload.py` script uploads metadata and n-gram files to corresponding folders GCP clous storage.
- **Usage**:
  ```bash
  python GCPstorage_upload.py

Process:
Sort files in CLEANED_DATA_PATH into three categories unigrams, bigrams, trigrams and save in Google Cloud Storage in  
corresponding folders.
Saves files from CLEANED_META_DATA_PATH to meta folder in Google Cloud Storage.

### Step 3: Load Cleaned Files into BigQuery (part of pipline.py)
The `bq_upload.py` script uploads csv files from the Google Cloud Storage folders 'meta', 'unigrams', 'bigrams' 
and 'trigrams' to corresponding tables 'meta_raw', 'unigrams_raw', 'bigrams_raw' and 'trigrams_raw'.
- **Usage**:
  ```bash
  python bq_upload.py
  
### Combine steps 1 to 3
Combines the cleaning and uploading steps described above.
- **Usage**:
  ```bash
  python pipline.py

### Step 4: Clean uni, bi and trigrams tables from the stopwords and various special characters like punctuation and etc.
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

The cleaning steps apply only to files that match the designated paths in config.py.
The initial JSTOR dataset on 'International security' topic can be found on Zenodo repository 10.5281/zenodo.14638434.

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
