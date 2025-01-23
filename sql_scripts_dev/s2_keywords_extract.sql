-- the place where we can find the keywords are in the meta-tables 'keyphrase' column.
-- We will extract uni-, bi-, and trigram keywords into separate tables and need to enumerate them by distinct ID

-- selecting unigrams from the meta keywords and enumerating with distinct ID with "U_" prefix
CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_keyword_uni` AS
SELECT
  CONCAT("U_", FORMAT('%04d', DENSE_RANK() OVER (ORDER BY keyword))) AS keyword_id,  -- Unique ID with prefix for unigrams
  keyword AS original_keyword
FROM (
  SELECT DISTINCT keyword
  FROM `clarivate-datapipline-project.jstor_international.int_meta`,
  UNNEST(SPLIT(keyphrase, '; ')) AS keyword
  WHERE keyphrase IS NOT NULL
  AND NOT REGEXP_CONTAINS(keyword, r'\s')
);

-- selecting bigrams from the meta keywords and enumerating with distinct ID with "B_" prefix
CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_keyword_bi` AS
SELECT
  CONCAT("B_", FORMAT('%04d', DENSE_RANK() OVER (ORDER BY keyword))) AS keyword_id,  -- Unique ID with prefix for bigrams
  keyword AS original_keyword
FROM (
  SELECT DISTINCT keyword
  FROM `clarivate-datapipline-project.jstor_international.int_meta`,
  UNNEST(SPLIT(keyphrase, '; ')) AS keyword
  WHERE keyphrase IS NOT NULL
    AND REGEXP_CONTAINS(keyword, r'^\S+\s\S+$')  -- Matches exactly two words (bigram)
);


-- selecting trigrams from the meta keywords and enumerating with distinct ID with "T_" prefix

CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_keyword_tri` AS
SELECT
  CONCAT("T_", FORMAT('%04d', DENSE_RANK() OVER (ORDER BY keyword))) AS keyword_id,  -- Unique ID with prefix for trigrams
  keyword AS original_keyword
FROM (
  SELECT DISTINCT keyword
  FROM `clarivate-datapipline-project.jstor_international.int_meta`,
  UNNEST(SPLIT(keyphrase, '; ')) AS keyword
  WHERE keyphrase IS NOT NULL
    AND REGEXP_CONTAINS(keyword, r'^\S+\s\S+\s\S+$')  -- Matches exactly three words (trigram)
);

