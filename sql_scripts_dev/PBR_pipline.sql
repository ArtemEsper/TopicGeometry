##################################### readme for PBR_data_new #####################################
###################################################################################################

# The new dataset obtained as a result of three queries to BigQuery. In the first query below we search for the ID of
# documents in title, abstract, keyword, and keyword_plus sections.

# file: "PBR_id_select"
CREATE OR REPLACE TABLE `clarivate-datapipline-project.pbr_dataset.pbr_id_select` AS
SELECT
distinct id
FROM (
   SELECT id FROM clarivate-datapipline-project.bq_wosraw_data.wos_keywords WHERE REGEXP_CONTAINS(keyword, r'(?i)Practice-based research|Practice-based evidence|Practice-as-research|Practice oriented researc|Practice-led research|Practice research|Practitioner research|Practitioner-researcher|Researcher-practitioner')
UNION ALL
    SELECT id FROM clarivate-datapipline-project.bq_wosraw_data.wos_abstract_paragraphs WHERE REGEXP_CONTAINS(paragraph_text, r'(?i)Practice-based research|Practice-based evidence|Practice-as-research|Practice oriented researc|Practice-led research|Practice research|Practitioner research|Practitioner-researcher|Researcher-practitioner')
UNION ALL
    SELECT id FROM clarivate-datapipline-project.bq_wosraw_data.wos_titles WHERE REGEXP_CONTAINS(title, r'(?i)Practice-based research|Practice-based evidence|Practice-as-research|Practice oriented researc|Practice-led research|Practice research|Practitioner research|Practitioner-researcher|Researcher-practitioner')
UNION ALL
    SELECT id FROM clarivate-datapipline-project.bq_wosraw_data.wos_keywords_plus WHERE REGEXP_CONTAINS(keyword_plus, r'(?i)Practice-based research|Practice-based evidence|Practice-as-research|Practice oriented researc|Practice-led research|Practice research|Practitioner research|Practitioner-researcher|Researcher-practitioner')
);

# we have 9229 documents in total satisfying the criteria above
Select count(distinct id) from `clarivate-datapipline-project.pbr_dataset.pbr_id_select`;

# In the query below we search for the information about documents found in previous query.

(Query 1)

CREATE OR REPLACE TABLE `clarivate-datapipline-project.pbr_dataset.pbr_id_head_title_kw_kwp` AS
SELECT distinct
  wos_summary.id,
  wos_summary.pubyear,
  wos_headings.heading,
  STRING_AGG(distinct wos_titles.title, ',') AS titles,
  STRING_AGG(distinct wos_keywords.keyword, ',') AS keywords,
  LOWER(STRING_AGG(distinct wos_keywords_plus.keyword_plus,',')) AS keywords_plus
FROM `clarivate-datapipline-project.bq_wosraw_data.wos_summary` AS wos_summary
left join `clarivate-datapipline-project.bq_wosraw_data.wos_headings` AS wos_headings on wos_summary.id = wos_headings.id
left join `clarivate-datapipline-project.bq_wosraw_data.wos_titles` AS wos_titles on wos_summary.id = wos_titles.id
left join `clarivate-datapipline-project.bq_wosraw_data.wos_keywords` AS wos_keywords on wos_summary.id = wos_keywords.id
left join `clarivate-datapipline-project.bq_wosraw_data.wos_keywords_plus` AS wos_keywords_plus on wos_summary.id = wos_keywords_plus.id
WHERE wos_summary.id IN (
    SELECT
      id
    FROM
      `clarivate-datapipline-project.pbr_dataset.pbr_id_select`
  )
  AND
  wos_titles.title_id > 4 # we exclude everything except journal name and article title
  AND
  wos_headings.heading_id = 1 # we exclude everything except journal name
GROUP BY
  wos_summary.id,
  wos_headings.heading,
  wos_summary.pubyear;

# we have 8963 documents in total satisfying the criteria above
Select count(distinct id) from `clarivate-datapipline-project.pbr_dataset.pbr_id_head_title_kw_kwp`;

# The results are stored in the table PBR_data.pbr_q1 (total 7910->9458 records).

(Query 2)

CREATE OR REPLACE TABLE `clarivate-datapipline-project.pbr_dataset.pbr_id_abs_dcit` AS
SELECT distinct
    wos_summary.id,
    wos_dynamic_citation_topics.content AS meso_topics,
    wos_abstracts.paragraph_text as abstract
FROM `clarivate-datapipline-project.bq_wosraw_data.wos_summary` AS wos_summary
left join `clarivate-datapipline-project.bq_wosraw_data.wos_abstract_paragraphs_uniq` AS wos_abstracts on wos_summary.id = wos_abstracts.id
Inner join `clarivate-datapipline-project.bq_wosraw_data.wos_dynamic_citation_topics` AS wos_dynamic_citation_topics on wos_summary.id = wos_dynamic_citation_topics.id
WHERE wos_summary.id IN (
    SELECT
      id
    FROM
      `clarivate-datapipline-project.pbr_dataset.pbr_id_select`
  )
AND wos_dynamic_citation_topics.content_type = 'meso'
AND wos_abstracts.paragraph_id = 1
GROUP BY
  wos_summary.id,
  wos_dynamic_citation_topics.content,
  wos_abstracts.paragraph_text;

select count(*) from `clarivate-datapipline-project.pbr_dataset.pbr_id_abs_dcit`; #8130 records
select  * from `clarivate-datapipline-project.pbr_dataset.pbr_id_abs_dcit` limit 100;

# The results are stored in the table PBR_data.pbr_q2 (in total 7752->8130 distinct records).
# We join two tables using Full outer JOIN on ID column.

CREATE OR REPLACE TABLE `clarivate-datapipline-project.pbr_dataset.pbr_all_meso` AS
select distinct
       table_2.id,
       table_1.pubyear,
       table_1.heading,
       table_1.titles,
       table_1.keywords,
       table_1.keywords_plus,
       table_2.abstract,
       table_2.meso_topics meso_topics
from
  `clarivate-datapipline-project.pbr_dataset.pbr_id_head_title_kw_kwp` as table_1
Inner JOIN
  `clarivate-datapipline-project.pbr_dataset.pbr_id_abs_dcit` as table_2
ON
  table_1.id = table_2.id;

select  count(*) from `clarivate-datapipline-project.pbr_dataset.pbr_all_meso`; #7987 records
select  * from `clarivate-datapipline-project.pbr_dataset.pbr_all_meso` limit 1000;



# To eliminate duplicated records we run the query below (we get 7987 of distinct records)

CREATE OR REPLACE TABLE `clarivate-datapipline-project.pbr_dataset.pbr_all_meso`
AS
SELECT
DISTINCT * FROM `clarivate-datapipline-project.pbr_dataset.pbr_all_meso`;


# Results are saved in the dataset `clarivate-datapipline-project.pbr_dataset.pbr_all_meso`.
# We add a pubyear to the dataset to perform dynamic analysis later.
# To find citations of articles collected in PBR dataset we select relevant entries from
# wos_references and save obtained table as "pbr_references":

CREATE OR REPLACE TABLE `clarivate-datapipline-project.pbr_dataset.pbr_all_meso_citations` AS
select table_1.id,
       table_1.pubyear,
       table_1.heading,
       table_1.titles,
       table_1.keywords,
       table_1.keywords_plus,
       table_1.abstract,
       table_1.meso_topics,
       count(table_2.ref_id) citations
from
    `clarivate-datapipline-project.pbr_dataset.pbr_all_meso`as table_1
left join
    (select distinct id,ref_id from `clarivate-datapipline-project.bq_wosraw_data.wos_references`)  as table_2
on
  table_1.id = table_2.ref_id
group by
    table_1.id,
  table_1.pubyear,
  table_1.heading,
  table_1.titles,
  table_1.keywords,
  table_1.keywords_plus,
  table_1.abstract,
  table_1.meso_topics;

select * from `clarivate-datapipline-project.pbr_dataset.pbr_all_meso_citations`; #7043 records with citcount>0
# 7987 records in total including articles without citations
_________________________________________________________
# Analysis section
_________________________________________________________
#Taking in to account available classification from "wos_dynamic_citation_topics" table we will find number
# of articles that mention PBR that fall into a single MESO-category. Distribution of the documents
# by the categories with relevant number of articles and total amount of citations per category can be found as

CREATE OR REPLACE TABLE `clarivate-datapipline-project.pbr_dataset.pbr_meso_classification` AS
WITH topic_selected_articles AS (
    SELECT content,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1980' THEN wos_dynamic_citation_topics.id END) as wos_count_1980,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1981' THEN wos_dynamic_citation_topics.id END) as wos_count_1981,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1982' THEN wos_dynamic_citation_topics.id END) as wos_count_1982,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1983' THEN wos_dynamic_citation_topics.id END) as wos_count_1983,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1984' THEN wos_dynamic_citation_topics.id END) as wos_count_1984,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1985' THEN wos_dynamic_citation_topics.id END) as wos_count_1985,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1986' THEN wos_dynamic_citation_topics.id END) as wos_count_1986,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1987' THEN wos_dynamic_citation_topics.id END) as wos_count_1987,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1988' THEN wos_dynamic_citation_topics.id END) as wos_count_1988,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1989' THEN wos_dynamic_citation_topics.id END) as wos_count_1989,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1990' THEN wos_dynamic_citation_topics.id END) as wos_count_1990,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1991' THEN wos_dynamic_citation_topics.id END) as wos_count_1991,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1992' THEN wos_dynamic_citation_topics.id END) as wos_count_1992,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1993' THEN wos_dynamic_citation_topics.id END) as wos_count_1993,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1994' THEN wos_dynamic_citation_topics.id END) as wos_count_1994,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1995' THEN wos_dynamic_citation_topics.id END) as wos_count_1995,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1996' THEN wos_dynamic_citation_topics.id END) as wos_count_1996,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1997' THEN wos_dynamic_citation_topics.id END) as wos_count_1997,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1998' THEN wos_dynamic_citation_topics.id END) as wos_count_1998,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '1999' THEN wos_dynamic_citation_topics.id END) as wos_count_1999,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2000' THEN wos_dynamic_citation_topics.id END) as wos_count_2000,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2001' THEN wos_dynamic_citation_topics.id END) as wos_count_2001,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2002' THEN wos_dynamic_citation_topics.id END) as wos_count_2002,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2003' THEN wos_dynamic_citation_topics.id END) as wos_count_2003,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2004' THEN wos_dynamic_citation_topics.id END) as wos_count_2004,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2005' THEN wos_dynamic_citation_topics.id END) as wos_count_2005,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2006' THEN wos_dynamic_citation_topics.id END) as wos_count_2006,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2007' THEN wos_dynamic_citation_topics.id END) as wos_count_2007,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2008' THEN wos_dynamic_citation_topics.id END) as wos_count_2008,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2009' THEN wos_dynamic_citation_topics.id END) as wos_count_2009,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2010' THEN wos_dynamic_citation_topics.id END) as wos_count_2010,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2011' THEN wos_dynamic_citation_topics.id END) as wos_count_2011,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2012' THEN wos_dynamic_citation_topics.id END) as wos_count_2012,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2013' THEN wos_dynamic_citation_topics.id END) as wos_count_2013,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2014' THEN wos_dynamic_citation_topics.id END) as wos_count_2014,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2015' THEN wos_dynamic_citation_topics.id END) as wos_count_2015,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2016' THEN wos_dynamic_citation_topics.id END) as wos_count_2016,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2017' THEN wos_dynamic_citation_topics.id END) as wos_count_2017,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2018' THEN wos_dynamic_citation_topics.id END) as wos_count_2018,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2019' THEN wos_dynamic_citation_topics.id END) as wos_count_2019,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2020' THEN wos_dynamic_citation_topics.id END) as wos_count_2020,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2021' THEN wos_dynamic_citation_topics.id END) as wos_count_2021,
           COUNT(DISTINCT CASE WHEN wos_summary.pubyear = '2022' THEN wos_dynamic_citation_topics.id END) as wos_count_2022,
           COUNT(distinct wos_dynamic_citation_topics.id) as total_count
    FROM `clarivate-datapipline-project.bq_wosraw_data.wos_dynamic_citation_topics` wos_dynamic_citation_topics
    inner join `clarivate-datapipline-project.bq_wosraw_data.wos_summary` wos_summary
        on wos_summary.id = wos_dynamic_citation_topics.id
    WHERE content_type = 'meso'
    AND content IN (SELECT distinct meso_topics
                    FROM `clarivate-datapipline-project.pbr_dataset.pbr_all_meso_citations`)
    group by wos_dynamic_citation_topics.content
)
Select pbr_all_meso_citations.meso_topics,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1980' THEN pbr_all_meso_citations.id END) AS pbr_count_1980,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1980' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1980,0),0) AS share_in_1980,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1981' THEN pbr_all_meso_citations.id END) AS pbr_count_1981,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1981' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1981,0),0) AS share_in_1981,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1982' THEN pbr_all_meso_citations.id END) AS pbr_count_1982,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1982' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1982,0),0) AS share_in_1982,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1983' THEN pbr_all_meso_citations.id END) AS pbr_count_1983,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1983' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1983,0),0) AS share_in_1983,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1984' THEN pbr_all_meso_citations.id END) AS pbr_count_1984,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1984' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1984,0),0) AS share_in_1984,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1985' THEN pbr_all_meso_citations.id END) AS pbr_count_1985,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1985' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1985,0),0) AS share_in_1985,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1986' THEN pbr_all_meso_citations.id END) AS pbr_count_1986,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1986' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1986,0),0) AS share_in_1986,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1987' THEN pbr_all_meso_citations.id END) AS pbr_count_1987,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1987' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1987,0),0) AS share_in_1987,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1988' THEN pbr_all_meso_citations.id END) AS pbr_count_1988,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1988' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1988,0),0) AS share_in_1988,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1989' THEN pbr_all_meso_citations.id END) AS pbr_count_1989,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1989' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1989,0),0) AS share_in_1989,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1990' THEN pbr_all_meso_citations.id END) AS pbr_count_1990,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1990' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1990,0),0) AS share_in_1990,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1991' THEN pbr_all_meso_citations.id END) AS pbr_count_1991,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1991' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1991,0),0) AS share_in_1991,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1992' THEN pbr_all_meso_citations.id END) AS pbr_count_1992,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1992' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1992,0),0) AS share_in_1992,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1993' THEN pbr_all_meso_citations.id END) AS pbr_count_1993,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1993' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1993,0),0) AS share_in_1993,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1994' THEN pbr_all_meso_citations.id END) AS pbr_count_1994,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1994' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1994,0),0) AS share_in_1994,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1995' THEN pbr_all_meso_citations.id END) AS pbr_count_1995,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1995' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1995,0),0) AS share_in_1995,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1996' THEN pbr_all_meso_citations.id END) AS pbr_count_1996,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1996' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1996,0),0) AS share_in_1996,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1997' THEN pbr_all_meso_citations.id END) AS pbr_count_1997,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1997' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1997,0),0) AS share_in_1997,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1998' THEN pbr_all_meso_citations.id END) AS pbr_count_1998,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1998' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1998,0),0) AS share_in_1998,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1999' THEN pbr_all_meso_citations.id END) AS pbr_count_1999,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '1999' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_1999,0),0) AS share_in_1999,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2000' THEN pbr_all_meso_citations.id END) AS pbr_count_2000,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2000' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2000,0),0) AS share_in_2000,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2001' THEN pbr_all_meso_citations.id END) AS pbr_count_2001,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2001' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2001,0),0) AS share_in_2001,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2002' THEN pbr_all_meso_citations.id END) AS pbr_count_2002,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2002' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2002,0),0) AS share_in_2002,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2003' THEN pbr_all_meso_citations.id END) AS pbr_count_2003,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2003' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2003,0),0) AS share_in_2003,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2004' THEN pbr_all_meso_citations.id END) AS pbr_count_2004,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2004' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2004,0),0) AS share_in_2004,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2005' THEN pbr_all_meso_citations.id END) AS pbr_count_2005,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2005' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2005,0),0) AS share_in_2005,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2006' THEN pbr_all_meso_citations.id END) AS pbr_count_2006,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2006' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2006,0),0) AS share_in_2006,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2007' THEN pbr_all_meso_citations.id END) AS pbr_count_2007,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2007' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2007,0),0) AS share_in_2007,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2008' THEN pbr_all_meso_citations.id END) AS pbr_count_2008,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2008' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2008,0),0) AS share_in_2008,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2009' THEN pbr_all_meso_citations.id END) AS pbr_count_2009,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2009' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2009,0),0) AS share_in_2009,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2010' THEN pbr_all_meso_citations.id END) AS pbr_count_2010,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2010' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2010,0),0) AS share_in_2010,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2011' THEN pbr_all_meso_citations.id END) AS pbr_count_2011,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2011' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2011,0),0) AS share_in_2011,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2012' THEN pbr_all_meso_citations.id END) AS pbr_count_2012,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2012' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2012,0),0) AS share_in_2012,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2013' THEN pbr_all_meso_citations.id END) AS pbr_count_2013,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2013' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2013,0),0) AS share_in_2013,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2014' THEN pbr_all_meso_citations.id END) AS pbr_count_2014,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2014' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2014,0),0) AS share_in_2014,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2015' THEN pbr_all_meso_citations.id END) AS pbr_count_2015,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2015' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2015,0),0) AS share_in_2015,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2016' THEN pbr_all_meso_citations.id END) AS pbr_count_2016,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2016' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2016,0),0) AS share_in_2016,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2017' THEN pbr_all_meso_citations.id END) AS pbr_count_2017,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2017' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2017,0),0) AS share_in_2017,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2018' THEN pbr_all_meso_citations.id END) AS pbr_count_2018,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2018' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2018,0),0) AS share_in_2018,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2019' THEN pbr_all_meso_citations.id END) AS pbr_count_2019,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2019' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2019,0),0) AS share_in_2019,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2020' THEN pbr_all_meso_citations.id END) AS pbr_count_2020,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2020' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2020,0),0) AS share_in_2020,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2021' THEN pbr_all_meso_citations.id END) AS pbr_count_2021,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2021' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2021,0),0) AS share_in_2021,
        COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2022' THEN pbr_all_meso_citations.id END) AS pbr_count_2022,
            IFNULL(COUNT(DISTINCT CASE WHEN pbr_all_meso_citations.pubyear = '2022' THEN pbr_all_meso_citations.id END)/NULLIF(topic_selected_articles.wos_count_2022,0),0) AS share_in_2022,
       Count(distinct pbr_all_meso_citations.id) as occurence,
       sum(pbr_all_meso_citations.citations) as citations,
       ROUND (sum(pbr_all_meso_citations.citations)/Count(distinct pbr_all_meso_citations.id),1) as citations_per_article
from `clarivate-datapipline-project.pbr_dataset.pbr_all_meso_citations` pbr_all_meso_citations
inner join topic_selected_articles
    on topic_selected_articles.content = pbr_all_meso_citations.meso_topics
group by pbr_all_meso_citations.meso_topics,
topic_selected_articles.wos_count_1980,
topic_selected_articles.wos_count_1981,
topic_selected_articles.wos_count_1982,
topic_selected_articles.wos_count_1983,
topic_selected_articles.wos_count_1984,
topic_selected_articles.wos_count_1985,
topic_selected_articles.wos_count_1986,
topic_selected_articles.wos_count_1987,
topic_selected_articles.wos_count_1988,
topic_selected_articles.wos_count_1989,
topic_selected_articles.wos_count_1990,
topic_selected_articles.wos_count_1991,
topic_selected_articles.wos_count_1992,
topic_selected_articles.wos_count_1993,
topic_selected_articles.wos_count_1994,
topic_selected_articles.wos_count_1995,
topic_selected_articles.wos_count_1996,
topic_selected_articles.wos_count_1997,
topic_selected_articles.wos_count_1998,
topic_selected_articles.wos_count_1999,
topic_selected_articles.wos_count_2000,
topic_selected_articles.wos_count_2001,
topic_selected_articles.wos_count_2002,
topic_selected_articles.wos_count_2003,
topic_selected_articles.wos_count_2004,
topic_selected_articles.wos_count_2005,
topic_selected_articles.wos_count_2006,
topic_selected_articles.wos_count_2007,
topic_selected_articles.wos_count_2008,
topic_selected_articles.wos_count_2009,
topic_selected_articles.wos_count_2010,
topic_selected_articles.wos_count_2011,
topic_selected_articles.wos_count_2012,
topic_selected_articles.wos_count_2013,
topic_selected_articles.wos_count_2014,
topic_selected_articles.wos_count_2015,
topic_selected_articles.wos_count_2016,
topic_selected_articles.wos_count_2017,
topic_selected_articles.wos_count_2018,
topic_selected_articles.wos_count_2019,
topic_selected_articles.wos_count_2020,
topic_selected_articles.wos_count_2021,
topic_selected_articles.wos_count_2022
order by occurence DESC;

select * from `clarivate-datapipline-project.pbr_dataset.pbr_meso_classification`; # 206 categories

# Count number of keywords in meso category. Plot a map of concepts from concepts frequency.
CREATE OR REPLACE TABLE `clarivate-datapipline-project.pbr_dataset.pbr_meso_classification_singecolumn` AS
SELECT
  meso_topics,
  CONCAT(
    STRING_AGG(COALESCE(LOWER(keywords), ''), ','),
    ',',
    STRING_AGG(COALESCE(LOWER(keywords_plus), ''), ',')
  ) AS combined_keywords
FROM
  `clarivate-datapipline-project.pbr_dataset.pbr_all_meso_citations`
WHERE
  keywords IS NOT NULL OR keywords_plus IS NOT NULL
GROUP BY
  meso_topics;

select * from `clarivate-datapipline-project.pbr_dataset.pbr_meso_classification_singecolumn` limit 10;


CREATE OR REPLACE TABLE `clarivate-datapipline-project.pbr_dataset.pbr_meso_keyword_frequency` AS
WITH SplitKeywords AS (
  SELECT
    meso_topics,
    SPLIT(combined_keywords, ',') AS KeywordArray
  FROM
    `clarivate-datapipline-project.pbr_dataset.pbr_meso_classification_singecolumn`
)

SELECT
  meso_topics,
  TRIM(keyword) AS Keyword,
  COUNT(*) AS Frequency
FROM
  SplitKeywords,
  UNNEST(KeywordArray) AS keyword
WHERE
  TRIM(keyword) != '' -- Filter out empty strings
GROUP BY
  meso_topics, Keyword
ORDER BY
  meso_topics, Frequency DESC;

-- To compare the two meso-topics based on common keywords and select thoose common keywords and distinct
-- keywords for each meso-topic

WITH KeywordsCTE AS (
    SELECT
        meso_topics,
        keyword
    FROM
        (select meso_topics, combined_keywords from `clarivate-datapipline-project.pbr_dataset.pbr_meso_classification_singecolumn`
        where
        REGEXP_CONTAINS(meso_topics, r'(?i) Education & Educational Research|Management')
        ),
        UNNEST(SPLIT(combined_keywords, ',')) AS keyword
)

SELECT
    keyword,
    COUNT(DISTINCT meso_topics) AS num_topics
FROM
    KeywordsCTE
GROUP BY
    keyword
HAVING
    COUNT(DISTINCT meso_topics) > 1; -- Common Keywords


WITH KeywordsCTE AS (
    SELECT
        meso_topics,
        keyword
    FROM
        (select meso_topics, combined_keywords from `clarivate-datapipline-project.pbr_dataset.pbr_meso_classification_singecolumn`
        where
        REGEXP_CONTAINS(meso_topics, r'(?i) Education & Educational Research|Management')
        ),
        UNNEST(SPLIT(combined_keywords, ',')) AS keyword
)
SELECT
    keyword,
    COUNT(DISTINCT meso_topics) AS num_topics
FROM
    KeywordsCTE
GROUP BY
    keyword
HAVING
    COUNT(DISTINCT meso_topics) = 1; -- Unique Keywords

