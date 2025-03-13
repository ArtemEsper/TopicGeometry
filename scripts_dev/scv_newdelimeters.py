import os
import csv
import re
from config import (
    RAW_META_DATA_PATH,
    CLEANED_META_DATA_PATH,
    RAW_DATA_PATH,
    CLEANED_DATA_PATH
)


def preprocess_line(line):
    """Remove excessive whitespace and concatenate lines."""
    return ' '.join(line.split())


def fix_csv(input_file, output_file):
    """Process a CSV file by cleaning whitespace and handling specific strings."""
    with open(input_file, 'r', newline='', encoding='utf-8', errors='replace') as infile:
        with open(output_file, 'w', newline='', encoding='utf-8') as outfile:
            reader = csv.reader(infile)
            writer = csv.writer(outfile, quoting=csv.QUOTE_MINIMAL, escapechar='\\', doublequote=True)
            for row in reader:
                # Preprocess each field to remove excessive whitespace
                row = [preprocess_line(field) for field in row]

                # Check if the specific string is in the current row
                if "unigrams; bigrams; trigrams" in row:
                    index = row.index("unigrams; bigrams; trigrams")
                    row[index] += '\n'  # Ensure newline character is correctly added

                # Write the corrected row to the output file
                writer.writerow(row)
    print(f"Processed: {input_file} -> {output_file}")


def process_all_csv_files(input_folder, output_folder):
    """Process all CSV files in the given folder."""
    if not os.path.exists(output_folder):
        os.makedirs(output_folder)

    for file_name in os.listdir(input_folder):
        if file_name.endswith(".csv") and not file_name.startswith("._"):  # Ignore hidden files
            input_path = os.path.join(input_folder, file_name)
            output_path = os.path.join(output_folder, file_name)
            try:
                fix_csv(input_path, output_path)
            except Exception as e:
                print(f"Error processing {file_name}: {e}")


# Set input and output folder paths
meta_input_folder = RAW_META_DATA_PATH
meta_output_folder = CLEANED_META_DATA_PATH
data_input_folder = RAW_DATA_PATH
data_output_folder = CLEANED_DATA_PATH

# Process all files in the metadata folder
process_all_csv_files(meta_input_folder, meta_output_folder)
print("All meta CSV files processed successfully!")

# Process all files in the data folder
process_all_csv_files(data_input_folder, data_output_folder)
print("All data CSV files processed successfully!")