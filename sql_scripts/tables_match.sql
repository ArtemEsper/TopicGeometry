-- make a merge with unigram tables

-- for this we clean uni-, bi- and trigram tables from id that are not present in cleaned meta file

CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_uni_cleaned` AS
SELECT id, ngram, count
  FROM `clarivate-datapipline-project.jstor_international.int_uni`
  WHERE id IN (
      SELECT DISTINCT id
      FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
    );


CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_bi_cleaned` AS
SELECT id, ngram, count
  FROM `clarivate-datapipline-project.jstor_international.int_bi`
  WHERE id IN (
      SELECT DISTINCT id
      FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
    );

CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_tri_cleaned` AS
SELECT id, ngram, count
  FROM `clarivate-datapipline-project.jstor_international.int_tri`
  WHERE id IN (
      SELECT DISTINCT id
      FROM `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned`
    );

-- if selecting only manually selected words instead of 'int_keyword_uni_combined' table with all keywords
SELECT DISTINCT
  t1.id,
  t1.original_keyword
FROM
  `clarivate-datapipline-project.jstor_international.int_keyword_uni_combined` AS t1
JOIN
  `clarivate-datapipline-project.jstor_international.selected_keywords_uni` AS t2
ON
  LOWER(t1.original_keyword) = LOWER(t2.string_field_0) -- Exact match for unigrams

---
CREATE OR REPLACE TABLE `clarivate-datapipline-project.wise_jstor_left.int_uni_match` AS
WITH matched_keywords AS (
  SELECT
    t1.id AS jstor_id,
    t2.keyword_id AS id,
    t2.original_keyword,
    t1.ngram,
    t1.count AS jstor_tf
  FROM `clarivate-datapipline-project.jstor_international.int_uni_cleaned` AS t1
  JOIN `clarivate-datapipline-project.jstor_international.int_keyword_uni_combined` AS t2
  ON TRIM(LOWER(t1.ngram)) = TRIM(LOWER(CAST(t2.original_keyword AS STRING)))
),
final_result AS (
  SELECT
    m.jstor_id,
    m.id,
    m.original_keyword,
    m.ngram,
    m.jstor_tf,
    t3.country,
    t3.jstor_publisher,
    t3.jstor_date
  FROM matched_keywords AS m
  JOIN `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned` AS t3
  ON m.jstor_id = t3.id
)
SELECT * FROM final_result;


-- for bigrams

CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_bi_match` AS
WITH matched_keywords AS (
  SELECT
    t1.id AS jstor_id,
    t2.keyword_id AS id,
    t2.original_keyword,
    t1.ngram,
    t1.count AS jstor_tf
  FROM `clarivate-datapipline-project.jstor_international.int_bi_cleaned` AS t1
  JOIN `clarivate-datapipline-project.jstor_international.int_keyword_bi_combined` AS t2
  ON TRIM(LOWER(t1.ngram)) = TRIM(LOWER(CAST(t2.original_keyword AS STRING)))
),
final_result AS (
  SELECT
    m.jstor_id,
    m.id,
    m.original_keyword,
    m.ngram,
    m.jstor_tf,
    t3.country,
    t3.jstor_publisher,
    t3.jstor_date
  FROM matched_keywords AS m
  JOIN `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned` AS t3
  ON m.jstor_id = t3.id
)
SELECT * FROM final_result;

-- for trigrams

CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_tri_match` AS
WITH matched_keywords AS (
  SELECT
    t1.id AS jstor_id,
    t2.keyword_id AS id,
    t2.original_keyword,
    t1.ngram,
    t1.count AS jstor_tf
  FROM `clarivate-datapipline-project.jstor_international.int_tri_cleaned` AS t1
  JOIN `clarivate-datapipline-project.jstor_international.int_keyword_tri_combined` AS t2
  ON TRIM(LOWER(t1.ngram)) = TRIM(LOWER(CAST(t2.original_keyword AS STRING)))
),
final_result AS (
  SELECT
    m.jstor_id,
    m.id,
    m.original_keyword,
    m.ngram,
    m.jstor_tf,
    t3.country,
    t3.jstor_publisher,
    t3.jstor_date
  FROM matched_keywords AS m
  JOIN `clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned` AS t3
  ON m.jstor_id = t3.id
)
SELECT * FROM final_result;

-- join all the tables into single table for the topic analysis

CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.articleconcepts_int` AS
SELECT
  jstor_id,
  id,
  original_keyword,
  ngram,
  jstor_tf,
  country,
  jstor_publisher,
  jstor_date
FROM `clarivate-datapipline-project.wise_jstor_left.int_uni_match`

UNION ALL

SELECT
  jstor_id,
  id,
  original_keyword,
  ngram,
  jstor_tf,
  country,
  jstor_publisher,
  jstor_date
FROM `clarivate-datapipline-project.jstor_international.int_bi_match`

UNION ALL

SELECT
  jstor_id,
  id,
  original_keyword,
  ngram,
  jstor_tf,
  country,
  jstor_publisher,
  jstor_date
FROM `clarivate-datapipline-project.jstor_international.int_tri_match`;

-- to use 'unknown' in jstor_publisher field instead of NULL

UPDATE `clarivate-datapipline-project.jstor_international.articleconcepts_int`
SET jstor_publisher = 'unknown'
WHERE jstor_publisher IS NULL;
-- 1780 rows affected

UPDATE `clarivate-datapipline-project.jstor_international.articleconcepts_int`
SET country = 'unknown'
WHERE country IS NULL;
-- 89,501 rows affected

-- normalize country names to fit the countryentity names in mathematica
UPDATE `clarivate-datapipline-project.jstor_international.articleconcepts_int`
SET country = CASE
    WHEN country = "Macedonia" THEN "NorthMacedonia"
    WHEN country = "North Macedonia" THEN "NorthMacedonia"
    WHEN country = "Dominican Rep" THEN "DominicanRepublic"
    WHEN country = "St Kitts & Nevi" THEN "SaintKittsAndNevis"
    WHEN country = "Cayman Islands" THEN "CaymanIslands"
    WHEN country = "Bosnia & Herceg" THEN "BosniaHerzegovina"
    WHEN country = "Swaziland" THEN "Eswatini"
    WHEN country = "PEOPLES R CHINA" OR country = "Peoples R China" THEN "China"
    WHEN country = "British Virgin Isl" THEN "BritishVirginIslands"
    WHEN country = "Yugoslavia" THEN "Serbia"  -- Successor state
    WHEN country = "Serbia Monteneg" THEN "Serbia"  -- Successor state
    WHEN country = "DEM REP CONGO" THEN "DemocraticRepublicOfTheCongo"
    WHEN country = "Ivory Coast" THEN "CoteDIvoire"
    WHEN country = "U Arab Emirates" THEN "UnitedArabEmirates"
    WHEN country = "Trinidad Tobago" THEN "TrinidadAndTobago"
    WHEN country = "Vatican" THEN "VaticanCity"
    WHEN country = "North Ireland" OR country = "England" OR country = "Scotland" OR country = "Wales" THEN "UnitedKingdom"
    WHEN country = "Czech Republic" THEN "Czechia"
    ELSE
      CASE
        WHEN country = "Iraq" THEN "Iraq"
        WHEN country = "Latvia" THEN "Latvia"
        WHEN country = "Albania" THEN "Albania"
        WHEN country = "New Zealand" THEN "NewZealand"
        WHEN country = "MEXICO" THEN "Mexico"
        WHEN country = "Mauritius" THEN "Mauritius"
        WHEN country = "Andorra" THEN "Andorra"
        WHEN country = "Sudan" THEN "Sudan"
        WHEN country = "Canada" THEN "Canada"
        WHEN country = "Brazil" OR country = "BRAZIL" THEN "Brazil"
        WHEN country = "Tanzania" THEN "Tanzania"
        WHEN country = "Bulgaria" THEN "Bulgaria"
        WHEN country = "France" OR country = "FRANCE" THEN "France"
        WHEN country = "Morocco" THEN "Morocco"
        WHEN country = "Israel" OR country = "ISRAEL" THEN "Israel"
        WHEN country = "Monaco" THEN "Monaco"
        WHEN country = "Slovenia" THEN "Slovenia"
        WHEN country = "Tunisia" THEN "Tunisia"
        WHEN country = "Cameroon" THEN "Cameroon"
        WHEN country = "Ukraine" THEN "Ukraine"
        WHEN country = "Switzerland" OR country = "SWITZERLAND" THEN "Switzerland"
        WHEN country = "Burkina Faso" THEN "BurkinaFaso"
        WHEN country = "Indonesia" OR country = "INDONESIA" THEN "Indonesia"
        WHEN country = "Chile" THEN "Chile"
        WHEN country = "Jordan" THEN "Jordan"
        WHEN country = "Cambodia" THEN "Cambodia"
        WHEN country = "Haiti" THEN "Haiti"
        WHEN country = "Mozambique" THEN "Mozambique"
        WHEN country = "Colombia" OR country = "COLOMBIA" THEN "Colombia"
        WHEN country = "Yemen" THEN "Yemen"
        WHEN country = "Benin" THEN "Benin"
        WHEN country = "Romania" OR country = "ROMANIA" THEN "Romania"
        WHEN country = "Guatemala" THEN "Guatemala"
        WHEN country = "Malaysia" THEN "Malaysia"
        WHEN country = "Australia" THEN "Australia"
        WHEN country = "Uzbekistan" THEN "Uzbekistan"
        WHEN country = "Malawi" THEN "Malawi"
        WHEN country = "Luxembourg" THEN "Luxembourg"
        WHEN country = "Kazakhstan" THEN "Kazakhstan"
        WHEN country = "Barbados" THEN "Barbados"
        WHEN country = "Zimbabwe" THEN "Zimbabwe"
        WHEN country = "Kyrgyzstan" THEN "Kyrgyzstan"
        WHEN country = "USA" THEN "UnitedStates"
        WHEN country = "Nepal" THEN "Nepal"
        WHEN country = "Singapore" THEN "Singapore"
        WHEN country = "Jamaica" THEN "Jamaica"
        WHEN country = "Fiji" THEN "Fiji"
        WHEN country = "VIETNAM" OR country = "Vietnam" THEN "Vietnam"
        WHEN country = "Norway" THEN "Norway"
        WHEN country = "Italy" OR country = "ITALY" THEN "Italy"
        WHEN country = "Hungary" OR country = "HUNGARY" THEN "Hungary"
        WHEN country = "Philippines" THEN "Philippines"
        WHEN country = "Germany" OR country = "GERMANY" THEN "Germany"
        WHEN country = "Lesotho" THEN "Lesotho"
        WHEN country = "Iceland" THEN "Iceland"
        WHEN country = "Turkey" THEN "Turkey"
        WHEN country = "Lebanon" THEN "Lebanon"
        WHEN country = "Georgia" THEN "Georgia"
        WHEN country = "French Guiana" THEN "FrenchGuiana"
        WHEN country = "India" OR country = "INDIA" THEN "India"
        WHEN country = "Zambia" THEN "Zambia"
        WHEN country = "Iran" THEN "Iran"
        WHEN country = "Greece" THEN "Greece"
        WHEN country = "Taiwan" THEN "Taiwan"
        WHEN country = "Grenada" THEN "Grenada"
        WHEN country = "Gabon" THEN "Gabon"
        WHEN country = "RUSSIA" OR country = "Russia" THEN "Russia"
        WHEN country = "Namibia" THEN "Namibia"
        WHEN country = "Liechtenstein" THEN "Liechtenstein"
        WHEN country = "New Caledonia" THEN "NewCaledonia"
        WHEN country = "Oman" THEN "Oman"
        WHEN country = "Belgium" THEN "Belgium"
        WHEN country = "Tajikistan" THEN "Tajikistan"
        WHEN country = "SPAIN" OR country = "Spain" THEN "Spain"
        WHEN country = "POLAND" OR country = "Poland" THEN "Poland"
        WHEN country = "Rwanda" THEN "Rwanda"
        WHEN country = "Burundi" THEN "Burundi"
        WHEN country = "Mali" THEN "Mali"
        WHEN country = "Serbia" THEN "Serbia"
        WHEN country = "Panama" THEN "Panama"
        WHEN country = "Nigeria" THEN "Nigeria"
        WHEN country = "Madagascar" THEN "Madagascar"
        WHEN country = "Seychelles" THEN "Seychelles"
        WHEN country = "Austria" OR country = "AUSTRIA" THEN "Austria"
        WHEN country = "BELARUS" THEN "Belarus"
        WHEN country = "Cyprus" THEN "Cyprus"
        WHEN country = "Togo" THEN "Togo"
        WHEN country = "Sweden" OR country = "SWEDEN" THEN "Sweden"
        WHEN country = "Estonia" THEN "Estonia"
        WHEN country = "Bolivia" THEN "Bolivia"
        WHEN country = "Niger" THEN "Niger"
        WHEN country = "Pakistan" THEN "Pakistan"
        WHEN country = "Syria" THEN "Syria"
        WHEN country = "Palestine" THEN "StateOfPalestine"
        WHEN country = "Senegal" THEN "Senegal"
        WHEN country = "Japan" OR country = "JAPAN" THEN "Japan"
        WHEN country = "Algeria" THEN "Algeria"
        WHEN country = "Portugal" THEN "Portugal"
        WHEN country = "Bangladesh" THEN "Bangladesh"
        WHEN country = "Ireland" THEN "Ireland"
        WHEN country = "Armenia" THEN "Armenia"
        WHEN country = "Cape Verde" THEN "CapeVerde"
        WHEN country = "Costa Rica" THEN "CostaRica"
        WHEN country = "Ethiopia" THEN "Ethiopia"
        WHEN country = "Montenegro" THEN "Montenegro"
        WHEN country = "Egypt" THEN "Egypt"
        WHEN country = "Finland" THEN "Finland"
        WHEN country = "Brunei" THEN "Brunei"
        WHEN country = "Denmark" OR country = "DENMARK" THEN "Denmark"
        WHEN country = "Ghana" THEN "Ghana"
        WHEN country = "Afghanistan" THEN "Afghanistan"
        WHEN country = "Azerbaijan" THEN "Azerbaijan"
        WHEN country = "South Korea" THEN "SouthKorea"
        WHEN country = "Kosovo" THEN "Kosovo"
        WHEN country = "South Africa" THEN "SouthAfrica"
        WHEN country = "San Marino" THEN "SanMarino"
        WHEN country = "Bahamas" THEN "Bahamas"
        WHEN country = "Uruguay" THEN "Uruguay"
        WHEN country = "Kuwait" THEN "Kuwait"
        WHEN country = "Nicaragua" THEN "Nicaragua"
        WHEN country = "Peru" THEN "Peru"
        WHEN country = "Cuba" THEN "Cuba"
        WHEN country = "Libya" THEN "Libya"
        WHEN country = "Botswana" THEN "Botswana"
        WHEN country = "Croatia" THEN "Croatia"
        WHEN country = "Sri Lanka" THEN "SriLanka"
        WHEN country = "Uganda" THEN "Uganda"
        WHEN country = "Malta" THEN "Malta"
        WHEN country = "Slovakia" THEN "Slovakia"
        WHEN country = "Netherlands" THEN "Netherlands"
        WHEN country = "Honduras" THEN "Honduras"
        WHEN country = "Argentina" THEN "Argentina"
        WHEN country = "Lithuania" THEN "Lithuania"
        WHEN country = "Mongolia" THEN "Mongolia"
        WHEN country = "Moldova" THEN "Moldova"
        WHEN country = "Saudi Arabia" THEN "SaudiArabia"
        WHEN country = "North Korea" THEN "NorthKorea"
        WHEN country = "Kenya" THEN "Kenya"
        WHEN country = "Paraguay" THEN "Paraguay"
        WHEN country = "Rep Congo" THEN "RepublicOfTheCongo"
        WHEN country = "Qatar" THEN "Qatar"
        WHEN country = "Ecuador" THEN "Ecuador"
        WHEN country = "Thailand" THEN "Thailand"
        WHEN country = "Bahrain" THEN "Bahrain"
        WHEN country = "Myanmar" THEN "Myanmar"
        WHEN country = "Venezuela" THEN "Venezuela"
      END
  END WHERE country IS NOT NULL;

_____________________________________%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%___________________________________
-- create a table with number of documents published before the specific dates

WITH date_steps AS (
  SELECT
    DATE_ADD(DATE('2010-04-25'), INTERVAL n MONTH) AS lastdate
  FROM UNNEST(GENERATE_ARRAY(0, DATE_DIFF(DATE('2025-04-25'), DATE('2010-04-25'), MONTH))) AS n
),
distinct_counts AS (
  SELECT
    d.lastdate,
    COUNT(DISTINCT t.jstor_id) AS totalsid
  FROM date_steps AS d
  LEFT JOIN `clarivate-datapipline-project.jstor_international.articleconcepts_int` AS t
  ON t.jstor_date < d.lastdate -- Include only documents before the current step date
  GROUP BY d.lastdate
)
SELECT
  totalsid,
  lastdate
FROM distinct_counts
ORDER BY lastdate;


_________________________________________________
--    Additional cleaning
_________________________________________________
DELETE FROM articleconcepts_int
WHERE id = 'U_14141' OR
      id = 'U_14641' OR
      id = 'U_14771' OR
      id = 'U_15129' OR
      id = 'U_16662' OR
      id = 'U_16765' OR
      id = 'U_17667' OR
      id = 'U_17965' OR
      id = 'U_18312' OR
      id = 'U_18385' OR
      id = 'U_19141' OR
      id = 'U_2085' OR
      id = 'U_10361' OR
      id = 'U_10266' OR
      id = 'U_0814' OR
      id = 'U_10375' OR
      id = 'U_1141' OR
      id = 'U_11810' OR
      id = 'U_12489' OR
      id = 'U_12636' OR
      id = 'U_12694' OR
      id = 'U_13651' OR
      id = 'U_13666' OR
      id = 'U_13688' OR
      id = 'U_13790' OR
      id = 'U_2603' OR
      id = 'U_3177' OR
      id = 'U_3539' OR
      id = 'U_3548' OR
      id = 'U_3612' OR
      id = 'U_3719' OR
      id = 'U_3761' OR
      id = 'U_3770' OR
      id = 'U_3815' OR
      id = 'U_3858' OR
      id = 'U_4023' OR
      id = 'U_4875' OR
      id = 'U_4938' OR
      id = 'U_5380' OR
      id = 'U_6596' OR
      id = 'U_6598' OR
      id = 'U_6969' OR
      id = 'U_7356' OR
      id = 'U_7358' OR
      id = 'U_7797' OR
      id = 'U_8454' OR
      id = 'U_8696' OR
      id = 'U_8718' OR
      id = 'U_8886' OR
      id = 'U_9538' OR
      id = 'U_9608' OR
      id = 'U_9955' OR
      id = 'U_9996' OR
      id = 'U_14011' OR
      id = 'U_16778' OR
      id = 'U_3927' OR
      id = 'U_2526' OR
      id = 'U_6575' OR
      id = 'U_6576' OR
      id = 'B_8129' OR
      id = 'B_8135' OR
      id = 'B_8127';
-------------------------------------------------
----- tests for braking large tables in partitions
-------------------------------------------------
CREATE OR REPLACE TABLE clarivate-datapipline-project.jstor_international.int_uni_match_part1 AS
WITH filtered_uni AS (
  SELECT id, ngram, count
  FROM clarivate-datapipline-project.jstor_international.int_uni_cleaned
  WHERE MOD(FARM_FINGERPRINT(id), 7) = 1 -- Partition data into 7 batches
),
matched_keywords AS (
  SELECT
    t1.id AS jstor_id,
    t2.keyword_id AS id,
    t2.original_keyword,
    t1.ngram,
    t1.count AS jstor_tf
  FROM filtered_uni AS t1
  JOIN clarivate-datapipline-project.jstor_international.int_keyword_uni_combined AS t2
  ON LOWER(t1.ngram) LIKE CONCAT('% ', LOWER(CAST(t2.original_keyword AS STRING)), ' %')
     OR LOWER(t1.ngram) LIKE CONCAT(LOWER(CAST(t2.original_keyword AS STRING)), ' %')
     OR LOWER(t1.ngram) LIKE CONCAT('% ', LOWER(CAST(t2.original_keyword AS STRING)))
),
final_result AS (
  SELECT
    m.jstor_id,
    m.id,
    m.original_keyword,
    m.ngram,
    m.jstor_tf,
    t3.country,
    t3.city,
    t3.title,
    t3.jstor_date
  FROM matched_keywords AS m
  JOIN clarivate-datapipline-project.jstor_international.int_articlemeta_jstor_cleaned AS t3
  ON m.jstor_id = t3.id
)
SELECT * FROM final_result;