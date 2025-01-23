-- Step 1 deduplicate reference table and extract only unique entries

CREATE OR REPLACE TABLE clarivate-datapipline-project.jstor_international.int_references_uniq AS (
WITH preprocessed_references AS (
  SELECT
    ref_id,
    REGEXP_REPLACE(TRIM(LOWER(cited_title)), r'[^\w\s]', '') AS normalized_cited_title,
    SAFE_CAST(REGEXP_EXTRACT(year, r'(19[0-9]{2}|20[0-9]{2})') AS INT64) AS extracted_year,
    REGEXP_REPLACE(
      REGEXP_REPLACE(TRIM(LOWER(cited_author)), r'[^\w\s]', ''),  -- Remove non-word characters
      r'\b\w{1,2}\b',  -- Match whole words of 1 or 2 letters
      ''  -- Replace with empty string
    ) AS cited_author
  FROM `clarivate-datapipline-project.bq_wos_2024_data_fix.wos_references`
  WHERE ref_id IS NOT NULL
  AND REGEXP_CONTAINS(ref_id, r'^WOS:\d{15}$')
),
ranked_references AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY normalized_cited_title ORDER BY extracted_year DESC, ref_id ASC) AS row_num
  FROM preprocessed_references
  WHERE extracted_year >= 2010
  AND extracted_year IS NOT NULL
),
filtered_references AS (
  SELECT *
  FROM ranked_references
  WHERE row_num = 1  -- Keep only the first entry for each normalized_cited_title
)
SELECT * from filtered_references);

-- create the combined table with jstor and WOS document metadata
CREATE OR REPLACE TABLE clarivate-datapipline-project.jstor_international.int_articlemeta_jstor AS (
WITH normalized_meta AS (
  SELECT
    id,
    REGEXP_REPLACE(TRIM(LOWER(title)), r'[^\w\s]', '') AS normalized_title,
    datePublished as jstor_date,
    EXTRACT(YEAR FROM datePublished) AS jstor_year,
    publisher,
    REGEXP_REPLACE(
      REGEXP_REPLACE(TRIM(LOWER(creator)), r'[^\w\s]', ''),  -- Remove non-word characters
      r'\b\w{1,2}\b',  -- Match whole words of 1 or 2 letters
      ''  -- Replace with empty string
    ) AS creator,
  FROM `clarivate-datapipline-project.jstor_international.int_meta`
)
SELECT
  nm.id,
  nr.ref_id,
  nm.normalized_title AS title,
  nr.normalized_cited_title AS cited_title,
  woss.country,
  woss.city,
  woss.addr_id,
  woss.full_address,
  nm.jstor_date as jstor_date,
  nr.extracted_year as wos_year,
  nm.publisher as jstor_publisher,
  nm.creator as jstor_creator,
  nr.cited_author as wos_creator
FROM normalized_meta AS nm
LEFT JOIN `clarivate-datapipline-project.jstor_international.int_references_uniq` AS nr
  ON LEFT(nm.normalized_title, 100) = LEFT(nr.normalized_cited_title, 100)
  AND REGEXP_CONTAINS(
       nm.creator,
       CONCAT(r'\b', REPLACE(nr.cited_author, ' ', r'\b|\b'), r'\b')
     )
  AND nm.jstor_year = nr.extracted_year
LEFT JOIN `clarivate-datapipline-project.bq_wos_2024_data_fix.wos_addresses` AS woss
  ON woss.id = nr.ref_id
  AND woss.addr_id = 1
);


-- Step 3 cleaning the title entries

CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned` AS
SELECT *
FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor`
WHERE ARRAY_LENGTH(SPLIT(title, ' ')) = ARRAY_LENGTH(SPLIT(cited_title, ' '));


DELETE FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
WHERE LOWER(title) LIKE '%untitled%'
   OR LOWER(cited_title) LIKE '%untitled%'
   OR LOWER(title) LIKE '%editorial%'
   OR LOWER(cited_title) LIKE '%editorial%'
   OR (LOWER(title) LIKE '%foreword%' AND LOWER(cited_title) LIKE '%foreword%')
   OR (LOWER(title) LIKE 'introduction' AND LOWER(cited_title) LIKE 'introduction')
   OR (LOWER(title) LIKE 'editors note' AND LOWER(cited_title) LIKE 'editors note')
   OR (LOWER(title) LIKE 'from the editor' AND LOWER(cited_title) LIKE 'from the editor')
   OR (LOWER(title) LIKE 'preface' AND LOWER(cited_title) LIKE 'preface')
   OR (LOWER(title) LIKE 'book reviews' AND LOWER(cited_title) LIKE 'book reviews')
   OR (LOWER(title) LIKE 'editors notes' AND LOWER(cited_title) LIKE 'editors notes')
   OR LOWER(cited_title) LIKE 'editors preface'
   OR LOWER(cited_title) LIKE 'in this issue'
   OR LOWER(cited_title) LIKE 'commentary'
   OR LOWER(cited_title) LIKE 'germany'
   OR LOWER(cited_title) LIKE 'response'
   OR LOWER(cited_title) LIKE 'the tempest'
   OR LOWER(cited_title) LIKE 'special issue'
   OR LOWER(cited_title) LIKE 'europe'
   OR LOWER(cited_title) LIKE 'climate change'
   OR LOWER(cited_title) LIKE 'conclusion'
   OR LOWER(cited_title) LIKE 'interview'
   OR LOWER(cited_title) LIKE 'forget me not'
   OR LOWER(cited_title) LIKE 'australia'
   OR LOWER(cited_title) LIKE 'change'
   OR LOWER(cited_title) LIKE 'news'
   OR LOWER(cited_title) LIKE 'human rights'
   OR LOWER(cited_title) LIKE 'slovakia'
   OR LOWER(cited_title) LIKE 'india'
   OR LOWER(cited_title) LIKE 'crowd wisdom'
   OR LOWER(cited_title) LIKE 'book review'
   OR LOWER(cited_title) LIKE 'resources'
   OR LOWER(cited_title) LIKE 'on the rise'
   OR LOWER(cited_title) LIKE 'call for papers'
   OR LOWER(cited_title) LIKE 'comment'
   OR LOWER(cited_title) LIKE 'abstracts'
   OR LOWER(cited_title) LIKE 'qa'
   OR LOWER(cited_title) LIKE 'review article'
   OR LOWER(cited_title) LIKE 'southeast asia'
   OR LOWER(cited_title) LIKE 'review'
   OR LOWER(cited_title) LIKE 'ethics briefing'
   OR LOWER(cited_title) LIKE 'books in brief'
   OR LOWER(cited_title) LIKE 'after europe'
   OR LOWER(cited_title) LIKE 'greece'
   OR LOWER(cited_title) LIKE 'reply'
   OR LOWER(cited_title) LIKE 'mexico';

-- we seems to have a duplicates in JSTOR meta file and have to address these manually
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
where id = 'ark://27927/phw6bdb1g1';

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
where ref_id = 'WOS:000286872600002'
AND ref_id = 'WOS:000286872600004'
AND ref_id = 'WOS:000286872600005';

----- test for unique values

SELECT
  ref_id,
  COUNT(*) AS duplicate_count
FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
GROUP BY
  ref_id
HAVING
  COUNT(*) > 1
order by ref_id;

SELECT
  id,
  COUNT(*) AS duplicate_count
FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
GROUP BY
  id
HAVING
  COUNT(*) > 1
order by id;

-- We have a duplicated wos ref_id's in 'int_articlemeta_jstor_cleaned' table for different JSTOR id.
-- The titles of the publications are the same. So we will delete the duplicated JSTOR id while
-- retaining one record per duplicate group. We want to have a list of id for the deletion and use these on
-- uni-, bi- and trigram tables since these tables have also duplicated information

WITH duplicates AS (
  SELECT
    ref_id,
    title,
    cited_title,
    ARRAY_AGG(id ORDER BY id ASC) AS id_list,  -- Collect IDs of duplicates
    COUNT(*) AS duplicate_count
  FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
  GROUP BY
    ref_id,
    title,
    cited_title
  HAVING
    COUNT(*) > 1
),
ids_to_delete AS (
  SELECT
    id
  FROM duplicates,
  UNNEST(ARRAY_SLICE(id_list, 1, ARRAY_LENGTH(id_list))) AS id -- Skip the first ID in the list
)
SELECT id
FROM ids_to_delete;

-- from uni- bi and trigram tables
-- clarivate-datapipline-project.jstor_international.int_uni
-- clarivate-datapipline-project.jstor_international.int_bi
-- clarivate-datapipline-project.jstor_international.int_tri

DELETE FROM `your_other_table_name`
WHERE id IN (
  WITH duplicates AS (
    SELECT
      ref_id,
      title,
      cited_title,
      ARRAY_AGG(id ORDER BY id ASC) AS id_list,
      COUNT(*) AS duplicate_count
    FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
    GROUP BY
      ref_id,
      title,
      cited_title
    HAVING
      COUNT(*) > 1
  ),
  ids_to_delete AS (
    SELECT
      id
    FROM duplicates,
    UNNEST(ARRAY_SLICE(id_list, 1, ARRAY_LENGTH(id_list))) AS id
  )
  SELECT id
  FROM ids_to_delete
);

-- deleteing  duplicated entries based on a list of redundand id's

DELETE FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
WHERE id IN (
  WITH duplicates AS (
    SELECT
      ref_id,
      title,
      cited_title,
      ARRAY_AGG(id ORDER BY id ASC) AS id_list,
      COUNT(*) AS duplicate_count
    FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
    GROUP BY
      ref_id,
      title,
      cited_title
    HAVING
      COUNT(*) > 1
  ),
  ids_to_delete AS (
    SELECT
      id
    FROM duplicates,
    UNNEST(ARRAY_SLICE(id_list, 1, ARRAY_LENGTH(id_list))) AS id
  )
  SELECT id
  FROM ids_to_delete
);

-- we have a NULL values when wos_address do not contain any records about the wos id.
-- we will set country= 'unknown' for these records

UPDATE `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
SET country = 'unknown'
WHERE country IS NULL;