import os
from google.cloud import storage
from config import CLEANED_DATA_PATH, CLEANED_META_DATA_PATH, BUCKET_NAME
from google.api_core.exceptions import GoogleAPIError


def upload_to_gcs(local_path, destination_folder):
    """Uploads a file to Google Cloud Storage into the specified folder."""
    client = storage.Client()
    bucket = client.bucket(BUCKET_NAME)

    # Ensure destination folder is correct
    blob_name = f"{destination_folder}/{os.path.basename(local_path)}"
    blob = bucket.blob(blob_name)

    try:
        blob.upload_from_filename(local_path)
        print(f"✅ Uploaded {local_path} to gs://{BUCKET_NAME}/{blob_name}")
    except GoogleAPIError as e:
        print(f"❌ Error uploading {local_path} to GCS: {e}")


def process_and_upload_files(local_folder, gcs_folder_prefix):
    """Process and upload files based on their category, without creating redundant subfolders."""
    for file_name in os.listdir(local_folder):
        file_path = os.path.join(local_folder, file_name)

        if not file_name.endswith(".csv") or not os.path.isfile(file_path):
            continue  # Skip non-CSV or non-file entries

        # Detect and assign the correct folder for each file
        if "-unigrams.csv" in file_name:
            upload_to_gcs(file_path, f"{gcs_folder_prefix}/unigrams")
        elif "-bigrams.csv" in file_name:
            upload_to_gcs(file_path, f"{gcs_folder_prefix}/bigrams")
        elif "-trigrams.csv" in file_name:
            upload_to_gcs(file_path, f"{gcs_folder_prefix}/trigrams")
        else:
            print(f"⚠️ Skipping file (no category match): {file_name}")


def upload_meta_files(meta_folder, gcs_meta_folder):
    """Upload all metadata files to the 'meta' folder in GCS."""
    for file_name in os.listdir(meta_folder):
        file_path = os.path.join(meta_folder, file_name)

        if file_name.endswith(".csv") and os.path.isfile(file_path):
            upload_to_gcs(file_path, gcs_meta_folder)


if __name__ == "__main__":
    print("\n=== Uploading Categorized Data Files to GCS ===")
    process_and_upload_files(CLEANED_DATA_PATH, "raw")

    print("\n=== Uploading Metadata Files to GCS ===")
    upload_meta_files(CLEANED_META_DATA_PATH, "raw/meta")

    print("\n✅ All files uploaded successfully!")
