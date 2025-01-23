CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_keyword_uni_combined` AS
WITH new_keywords AS (
  SELECT DISTINCT
    string_field_0 AS original_keyword
  FROM `clarivate-datapipline-project.jstor_international.selected_keywords_uni`
  WHERE string_field_0 NOT IN (SELECT original_keyword FROM `clarivate-datapipline-project.jstor_international.int_keyword_uni`)
),
new_keywords_with_ids AS (
  SELECT
    CONCAT('UN_', CAST(ROW_NUMBER() OVER () AS STRING)) AS keyword_id,
    original_keyword
  FROM new_keywords
),
existing_keywords AS (
  SELECT
    keyword_id,
    original_keyword
  FROM `clarivate-datapipline-project.jstor_international.int_keyword_uni`
)
SELECT * FROM existing_keywords
UNION ALL
SELECT * FROM new_keywords_with_ids;


CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_keyword_tri_combined` AS
WITH new_keywords AS (
  SELECT DISTINCT
    string_field_0 AS original_keyword
  FROM `clarivate-datapipline-project.jstor_international.selected_keywords_tri`
  WHERE string_field_0 NOT IN (SELECT original_keyword FROM `clarivate-datapipline-project.jstor_international.int_keyword_tri`)
),
new_keywords_with_ids AS (
  SELECT
    CONCAT('UN_', CAST(ROW_NUMBER() OVER () AS STRING)) AS keyword_id,
    original_keyword
  FROM new_keywords
),
existing_keywords AS (
  SELECT
    keyword_id,
    original_keyword
  FROM `clarivate-datapipline-project.jstor_international.int_keyword_tri`
)
SELECT * FROM existing_keywords
UNION ALL
SELECT * FROM new_keywords_with_ids;

CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_keyword_bi_combined` AS
WITH new_keywords AS (
  SELECT DISTINCT
    string_field_0 AS original_keyword
  FROM `clarivate-datapipline-project.jstor_international.selected_keywords_bi`
  WHERE string_field_0 NOT IN (SELECT original_keyword FROM `clarivate-datapipline-project.jstor_international.int_keyword_bi`)
),
new_keywords_with_ids AS (
  SELECT
    CONCAT('UN_', CAST(ROW_NUMBER() OVER () AS STRING)) AS keyword_id,
    original_keyword
  FROM new_keywords
),
existing_keywords AS (
  SELECT
    keyword_id,
    original_keyword
  FROM `clarivate-datapipline-project.jstor_international.int_keyword_bi`
)
SELECT * FROM existing_keywords
UNION ALL
SELECT * FROM new_keywords_with_ids;

-- check the list of new keywords added

SELECT *
FROM `clarivate-datapipline-project.jstor_international.int_keyword_uni_combined`
WHERE keyword_id LIKE 'UN_%';


SELECT *
FROM `clarivate-datapipline-project.jstor_international.int_keyword_bi_combined`
WHERE keyword_id LIKE 'UN_%';

SELECT *
FROM `clarivate-datapipline-project.jstor_international.int_keyword_tri_combined`
WHERE keyword_id LIKE 'UN_%';