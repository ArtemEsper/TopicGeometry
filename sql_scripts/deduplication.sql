-- ANALYSIS
-- The main goal of this step is to identify and delete duplicated entries in 'meta' and ngrams tables.
-- We also will keep only those documents that have an authorship i.e. 'creator' fiels is not NULL.

-- Step 0
-- check for the unique id in 'meta_raw' table
-- If total_rows == distinct_ids, every row has a unique id.
SELECT
  COUNT(*) AS total_rows,
  COUNT(DISTINCT id) AS distinct_ids
FROM 'clarivate-datapipline-project.lg_jstor.meta_raw'

-- Step 1
-- In 'meta_raw' table we group by title, publicationYear, and creator. Within each group, we can pick one
-- “primary” id to keep (for example, the lexicographically smallest, or earliest, or whichever rule).
-- The other ids in that group become “duplicate” – we want to remove them from the n-gram tables.
-- We select documents with authorship only.
WITH duplicates AS (
  SELECT
    title,
    publicationYear,
    docType,
    creator,
    -- "keep_id" is the single ID you will keep
    ARRAY_AGG(id ORDER BY id LIMIT 1) AS keep_id,
    -- "other_ids" are the remaining IDs (duplicates)
    ARRAY_AGG(id ORDER BY id)[OFFSET(1)] AS other_ids,
    COUNT(*) AS cnt
  FROM 'clarivate-datapipline-project.lg_jstor.meta_raw'
  WHERE creator IS NOT NULL
  GROUP BY title, publicationYear, docType, creator
  HAVING COUNT(*) > 1
)
SELECT
  title,
  publicationYear,
  docType,
  creator,
  keep_id[SAFE_OFFSET(0)] AS keep_id,
  other_ids AS duplicates,
  cnt
FROM duplicates;

-- Step 2: Remove duplicate ids from ngram tables (unigrams_raw, bigrams_raw, trigrams_raw).
-- Step 3: Remove duplicates from meta_raw itself.

--########################################################################################################
-- EXECUTION
-- Step 1 Recap: Identify duplicates & store them
-- This picks a single 'keep_id' per group and gathers the rest in 'other_ids'
CREATE OR REPLACE TABLE `clarivate-datapipline-project.lg_jstor.duplicate_ids` AS
WITH duplicates AS (
  SELECT
    title,
    publicationYear,
    docType,
    creator,
    -- All IDs in ascending order
    ARRAY_AGG(id ORDER BY id) AS all_ids,
    COUNT(*) AS cnt
  FROM `clarivate-datapipline-project.lg_jstor.meta_raw`
  WHERE creator IS NOT NULL
  GROUP BY title, publicationYear, docType, creator
  HAVING COUNT(*) > 1
)
SELECT DISTINCT duplicate_id
FROM duplicates,
-- Re-UNNEST all_ids, skipping the first element
UNNEST(
  (SELECT ARRAY_AGG(x)
     FROM UNNEST(duplicates.all_ids) x WITH OFFSET pos
     WHERE pos > 0)
) AS duplicate_id
WHERE duplicate_id IS NOT NULL;

-- add to duplicated those 'id's where creator is not known
INSERT INTO `clarivate-datapipline-project.lg_jstor.duplicate_ids`
SELECT DISTINCT id AS duplicate_id
FROM `clarivate-datapipline-project.lg_jstor.meta_raw`
WHERE creator IS NULL;


-- Step 2 and 3. We create a new tables with no duplicates.
-- Create meta_deduplicated from meta_raw
CREATE OR REPLACE TABLE `clarivate-datapipline-project.lg_jstor.meta_deduplicated` AS
SELECT *
FROM `clarivate-datapipline-project.lg_jstor.meta_raw`
WHERE id NOT IN (
  SELECT duplicate_id FROM `clarivate-datapipline-project.lg_jstor.duplicate_ids`
);

-- Create unigrams_deduplicated from unigrams_raw
CREATE OR REPLACE TABLE `clarivate-datapipline-project.lg_jstor.unigrams_deduplicated` AS
SELECT *
FROM `clarivate-datapipline-project.lg_jstor.unigrams_raw`
WHERE id NOT IN (
  SELECT duplicate_id FROM `clarivate-datapipline-project.lg_jstor.duplicate_ids`
);

-- Create bigrams_deduplicated from bigrams_raw
CREATE OR REPLACE TABLE `clarivate-datapipline-project.lg_jstor.bigrams_deduplicated` AS
SELECT *
FROM `clarivate-datapipline-project.lg_jstor.bigrams_raw`
WHERE id NOT IN (
  SELECT duplicate_id FROM `clarivate-datapipline-project.lg_jstor.duplicate_ids`
);

-- Create trigrams_deduplicated from trigrams_raw
CREATE OR REPLACE TABLE `clarivate-datapipline-project.lg_jstor.trigrams_deduplicated` AS
SELECT *
FROM `clarivate-datapipline-project.lg_jstor.trigrams_raw`
WHERE id NOT IN (
  SELECT duplicate_id FROM `clarivate-datapipline-project.lg_jstor.duplicate_ids`
);

