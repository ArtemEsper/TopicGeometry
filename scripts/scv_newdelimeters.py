import csv
import re
import os
from config import RAW_DATA_PATH, CLEANED_DATA_PATH  # Import paths from config


def preprocess_line(line):
    # Remove excessive whitespace and concatenate lines
    return ' '.join(line.split())


def fix_csv(input_file, output_file):
    with open(input_file, 'r', newline='') as infile:
        with open(output_file, 'w', newline='') as outfile:
            reader = csv.reader(infile)
            writer = csv.writer(outfile, quoting=csv.QUOTE_MINIMAL, escapechar='\\', doublequote=True)
            for row in reader:
                # Preprocess each field to remove excessive whitespace
                row = [preprocess_line(field) for field in row]
                # Check if the specific string is in the current row
                if "unigrams; bigrams; trigrams" in row:
                    # Add newline delimiter after the specific string
                    index = row.index("unigrams; bigrams; trigrams")
                    row[index] += 'n'
                # Write the corrected row to the output file
                writer.writerow(row)

    print("CSV file fixed successfully!")


# Process all files in RAW_DATA_PATH
def process_all_data_files():
    for file_name in os.listdir(RAW_DATA_PATH):
        input_file = os.path.join(RAW_DATA_PATH, file_name)
        output_file = os.path.join(CLEANED_DATA_PATH, file_name)
        print(f"Processing file: {file_name}")
        fix_csv(input_file, output_file)


if __name__ == "__main__":
    process_all_data_files()
