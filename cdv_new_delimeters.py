import csv
import re


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


# Set input and output file paths
input_file = '/Volumes/X9 Pro/JSTOR/international_sequrity/2020_2024_metadata.csv'
output_file = '/Volumes/X9 Pro/JSTOR/int_seq_cleaned/2020_2024_meta_fixed.csv'

# Call the function with input and output file paths
fix_csv(input_file, output_file)