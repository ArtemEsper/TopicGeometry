def remove_ascii_null(input_file, output_file):
    with open(input_file, 'r', newline='', encoding='utf-8') as infile:
        with open(output_file, 'w', newline='', encoding='utf-8') as outfile:
            for line in infile:
                # Remove ASCII 0 characters from the line
                cleaned_line = line.replace('\x00', '')
                # Write the cleaned line to the output file
                outfile.write(cleaned_line)


# Set input and output file paths
input_file = '/Volumes/X9 Pro/JSTOR/international_sequrity/2020_2024_trigrams.csv'
output_file = '/Volumes/X9 Pro/JSTOR/int_seq_cleaned/2020_2024_tri_fixed.csv'

# Call the function to remove ASCII 0 characters
remove_ascii_null(input_file, output_file)
