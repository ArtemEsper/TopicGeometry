import os
import chardet

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

    with open(input_file, 'r', newline='', encoding=encoding, errors='replace') as infile:
        with open(output_file, 'w', newline='', encoding='utf-8') as outfile:
            for line in infile:
                cleaned_line = line.replace('\x00', '')  # Remove NULL characters
                outfile.write(cleaned_line)


def process_all_files(input_folder, output_folder):
    """Process all CSV files in a folder, ignoring hidden files."""
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for file_name in os.listdir(input_folder):
        if file_name.startswith("."):  # Ignore hidden files (including AppleDouble)
            print(f"Skipping hidden file: {file_name}")
            continue

        if file_name.endswith(".csv"):  # Process only CSV files
            input_path = os.path.join(input_folder, file_name)
            output_path = os.path.join(output_folder, file_name)

            try:
                remove_ascii_null(input_path, output_path)
            except Exception as e:
                print(f"Error processing {file_name}: {e}")


# Set paths
meta_input_folder = RAW_META_DATA_PATH
meta_output_folder = CLEANED_META_DATA_PATH
data_input_folder = RAW_DATA_PATH
data_output_folder = CLEANED_DATA_PATH

# Process all files
process_all_files(meta_input_folder, meta_output_folder)
print("All meta files processed.")

process_all_files(data_input_folder, data_output_folder)
print("All data files processed.")
