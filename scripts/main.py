import os
from google.cloud import storage
from config import (
    RAW_META_DATA_PATH,
    CLEANED_META_DATA_PATH,
    RAW_DATA_PATH,
    CLEANED_DATA_PATH,
    BUCKET_NAME,
)
from removeascii import remove_ascii_null  # Import ASCII cleaning function for metadata
from scv_newdelimeters import fix_csv  # Import CSV preprocessing function for data files


def upload_to_gcs(bucket_name, source_file_name, destination_blob_name):
    client = storage.Client()
    bucket = client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(source_file_name)
    print(f"File {source_file_name} uploaded to {destination_blob_name}.")


def process_meta_files():
    # Process metadata files only, applying ASCII cleaning
    for file_name in os.listdir(RAW_META_DATA_PATH):
        input_file_path = os.path.join(RAW_META_DATA_PATH, file_name)
        output_file_path = os.path.join(CLEANED_META_DATA_PATH, file_name)

        print(f"Cleaning metadata file: {file_name}")
        remove_ascii_null(input_file_path, output_file_path)

        # Upload cleaned metadata file to GCS
        destination_path = f"impact/meta_cleaned/{file_name}"
        upload_to_gcs(BUCKET_NAME, output_file_path, destination_path)


def process_data_files():
    # Process data files (non-metadata) with `fix_csv` function
    for file_name in os.listdir(RAW_DATA_PATH):
        input_file_path = os.path.join(RAW_DATA_PATH, file_name)
        output_file_path = os.path.join(CLEANED_DATA_PATH, file_name)

        print(f"Processing data file with new delimiters: {file_name}")
        fix_csv(input_file_path, output_file_path)

        # Upload preprocessed data file to GCS
        destination_path = f"impact/data_cleaned/{file_name}"
        upload_to_gcs(BUCKET_NAME, output_file_path, destination_path)


def main():
    # Process metadata files with ASCII cleaning
    process_meta_files()

    # Process data files with `fix_csv`
    process_data_files()

    print("All files processed and uploaded.")


if __name__ == "__main__":
    main()
