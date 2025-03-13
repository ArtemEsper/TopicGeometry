import subprocess
import sys  # To ensure correct Python executable is used


def run_script(script_name):
    """Helper function to run a script and check for errors."""
    python_executable = sys.executable  # Ensure correct Python interpreter
    result = subprocess.run([python_executable, script_name], capture_output=True, text=True)
    print(result.stdout)

    if result.returncode != 0:
        print(f"❌ Error in {script_name} step!")
        return False
    return True


# Define the pipeline execution steps
def main():
    print("\n=== Step 1: Running Data Cleaning ===")
    if not run_script("data_cleaning.py"):
        return

    print("\n=== Step 2: Uploading Files to Google Cloud Storage ===")
    if not run_script("GCPstorage_upload.py"):
        return

    print("\n=== Step 3: Loading Data into BigQuery ===")
    if not run_script("bq_upload_tab_autocreate.py"):
        return

    print("\n✅ Pipeline execution completed successfully!")


if __name__ == "__main__":
    main()
