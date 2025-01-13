-- Creating the main table
CREATE TABLE articleconcepts_meta (
    articleid VARCHAR(11),
    conceptid INT,
    totaltf INT,
    datesubmitted DATETIME,
    country_entity_name VARCHAR(40),
    title VARCHAR(40)
);

-- Adding indexes
CREATE INDEX i_articleid_datesubmitted_idx
ON articleconcepts_meta (articleid, datesubmitted);

CREATE INDEX i_conceptid_totaltf_datesubmitted_idx
ON articleconcepts_meta (conceptid, totaltf, datesubmitted);

CREATE INDEX idx_articleconcepts_conceptid_totaltf
ON articleconcepts_meta (conceptid, totaltf);

CREATE INDEX idx_concept_date_article_tot
ON articleconcepts_meta (conceptid, datesubmitted, articleid, totaltf);

CREATE INDEX i_articleid_totaltf_country_idx
ON articleconcepts_meta (articleid, totaltf,country_entity_name);

OPTIMIZE TABLE articleconcepts_meta;

UPDATE articleconcepts_meta
SET country_entity_name = 'Unknown'
WHERE country_entity_name='';

select count(distinct articleid) from articleconcepts_meta where country_entity_name!='UnitedStates';

SELECT country_entity_name, count(distinct articleid) n_doc  FROM articleconcepts_meta
group by country_entity_name
order by n_doc desc;

-- Step 1: Create the table structure
CREATE TABLE country_document_counts (
    country_entity_name VARCHAR(255),  -- Adjust size based on expected length
    n_doc INT,
    total_no_country INT
);

-- Step 2: Insert data into the newly created table
INSERT INTO country_document_counts (country_entity_name, n_doc, total_no_country)
SELECT
    country_entity_name,
    COUNT(DISTINCT articleid) AS n_doc,
    451523 - COUNT(DISTINCT articleid) AS total_no_country
FROM articleconcepts_meta
GROUP BY country_entity_name
ORDER BY n_doc DESC;

Select total_no_country from country_document_counts where country_entity_name = 'UnitedStates';

SELECT totalsid, lastdate
FROM articleidtotals
WHERE DATE_FORMAT(lastdate, '%m-%d') = '04-25'
AND lastdate BETWEEN '2002-04-25' AND '2018-04-25';

select * from country_document_counts;

