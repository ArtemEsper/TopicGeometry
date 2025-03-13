import os
import csv
import chardet
import shutil  # For safely renaming files

from config import (
    RAW_META_DATA_PATH,
    CLEANED_META_DATA_PATH,
    RAW_DATA_PATH,
    CLEANED_DATA_PATH
)


def detect_encoding(file_path, num_bytes=10000):
    """Detect file encoding by reading a portion of the file."""
    with open(file_path, 'rb') as f:
        raw_data = f.read(num_bytes)
    result = chardet.detect(raw_data)
    return result['encoding']


def remove_ascii_null(input_file, output_file):
    """Remove ASCII NULL characters while handling encoding issues."""
    encoding = detect_encoding(input_file)  # Auto-detect encoding
    print(f"Processing {input_file} with detected encoding: {encoding}")

    modified = False  # Track if any changes occur

    with open(input_file, 'r', newline='', encoding=encoding, errors='replace') as infile, \
            open(output_file, 'w', newline='', encoding='utf-8') as outfile:

        for line in infile:
            cleaned_line = line.replace('\x00', '')  # Remove NULL characters
            if cleaned_line != line:
                modified = True  # Track changes

            outfile.write(cleaned_line)  # Always write line, even if unchanged

    if not modified:
        print(f"No NULL characters found in {input_file}, file remains the same.")


def preprocess_line(line):
    """Remove excessive whitespace and concatenate lines."""
    return ' '.join(line.split())


def fix_csv(input_file, output_file):
    """Process a CSV file by cleaning whitespace and handling specific strings."""
    temp_file = output_file + ".tmp"  # Use a temporary file to prevent data loss
    modified = False

    with open(input_file, 'r', newline='', encoding='utf-8', errors='replace') as infile, \
            open(temp_file, 'w', newline='', encoding='utf-8') as outfile:

        reader = csv.reader(infile)
        writer = csv.writer(outfile, quoting=csv.QUOTE_MINIMAL, escapechar='\\', doublequote=True)

        for row in reader:
            new_row = [preprocess_line(field) for field in row]

            # Ensure "unigrams; bigrams; trigrams" is handled correctly
            if "unigrams; bigrams; trigrams" in new_row:
                index = new_row.index("unigrams; bigrams; trigrams")
                new_row[index] = "unigrams | bigrams | trigrams"  # Replace safely

            if new_row != row:
                modified = True

            writer.writerow(new_row)  # Always write row, even if unchanged

    if modified:
        shutil.move(temp_file, output_file)  # Replace original file with updated file
        print(f"Processed: {input_file} -> {output_file}")
    else:
        os.remove(temp_file)  # Remove temp file if no changes
        print(f"No changes made to {input_file}.")


def process_all_files(input_folder, output_folder, process_function):
    """Process all CSV files in a folder with a given function."""
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for file_name in os.listdir(input_folder):
        if file_name.startswith(".") or file_name.startswith("._"):  # Ignore hidden files
            print(f"Skipping hidden file: {file_name}")
            continue

        if file_name.endswith(".csv"):
            input_path = os.path.join(input_folder, file_name)
            output_path = os.path.join(output_folder, file_name)

            try:
                process_function(input_path, output_path)
            except Exception as e:
                print(f"Error processing {file_name}: {e}")


if __name__ == "__main__":
    print("\n=== Cleaning ASCII NULL Characters ===")
    process_all_files(RAW_META_DATA_PATH, CLEANED_META_DATA_PATH, remove_ascii_null)
    process_all_files(RAW_DATA_PATH, CLEANED_DATA_PATH, remove_ascii_null)

    print("\n=== Fixing CSV Formatting ===")
    process_all_files(CLEANED_META_DATA_PATH, CLEANED_META_DATA_PATH, fix_csv)
    process_all_files(CLEANED_DATA_PATH, CLEANED_DATA_PATH, fix_csv)

    print("\n✅ Data cleaning completed!")
