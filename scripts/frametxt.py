def merge_words(input_file, output_file):
    # Read words from input file
    with open(input_file, 'r') as f:
        words = [line.strip() for line in f]

    # Join words with '|' separator
    merged_words = '|'.join(words)

    # Write merged words to output file
    with open(output_file, 'w') as f:
        f.write(merged_words)


# Example usage:
input_file = '/Users/macbook/Documents/SCI STUD LAB/PBR project/Jstor/stopwords/list_names.txt'  # Specify the input file containing words
output_file = '/Users/macbook/Documents/SCI STUD LAB/PBR project/Jstor/stopwords/list_names_BQ.txt'  # Specify the output file to write merged words
merge_words(input_file, output_file)
