import subprocess
import sys


def run_step(command, step_name):
    """Run a subprocess and stream output in real-time."""
    # Print which step we are running
    print(f"\n=== {step_name} ===")

    # Use sys.executable or the path of your Python interpreter if needed
    # example: process = subprocess.Popen(
    #     ["/Users/macbook/tensorflow-m1/bin/python3", script_name], ...
    # )
    # but if your scripts can run under sys.executable directly, do:
    process = subprocess.Popen(
        command,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1  # line-buffered output
    )

    # Read lines in real-time
    for line in process.stdout:
        print(line, end="")

    process.wait()

    if process.returncode != 0:
        print(f"❌ ERROR in {step_name}!")
        # Exit the pipeline on error
        sys.exit(1)

    print(f"✅ {step_name} completed successfully!")


def main():
    # Step 1: Data Cleaning
    run_step([sys.executable, "data_cleaning.py"], "Step 1: Running Data Cleaning")

    # Step 2: Upload to GCS
    run_step([sys.executable, "GCPstorage_upload.py"], "Step 2: Uploading Files to GCS")

    # Step 3: BigQuery Upload
    run_step([sys.executable, "bq_upload_tab_autocreate.py"], "Step 3: Loading Data into BigQuery")

    print("\n🚀 Pipeline finished successfully!")


if __name__ == "__main__":
    main()
