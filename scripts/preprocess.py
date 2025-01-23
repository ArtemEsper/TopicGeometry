import pandas as pd
import os
import re
from config import RAW_DATA_PATH, CLEANED_DATA_PATH

def clean_ascii_characters(file_path, output_path):
    # Load CSV and remove non-ASCII characters
    df = pd.read_csv(file_path)
    # Replace non-ASCII characters with a blank
    df = df.applymap(lambda x: re.sub(r'[^\x00-\x7F]+', '', str(x)) if isinstance(x, str) else x)
    df.to_csv(output_path, index=False)

def preprocess_metadata(file_path, output_path):
    # Load metadata CSV and apply any custom processing here
    df = pd.read_csv(file_path)
    # Example: Drop rows with null values in specific columns
    df.dropna(inplace=True)
    df.to_csv(output_path, index=False)
