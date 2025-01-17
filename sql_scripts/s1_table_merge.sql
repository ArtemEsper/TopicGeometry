-- International sequrity JSTOR

-- merging separate tables into categories meta, uni, bi, tri -gramms

CREATE TABLE `clarivate-datapipline-project.jstor_international.int_meta`
AS
SELECT * FROM `clarivate-datapipline-project.jstor_international.meta_part1`
UNION ALL
SELECT * FROM `clarivate-datapipline-project.jstor_international.meta_part2`;

CREATE TABLE `clarivate-datapipline-project.jstor_international.int_uni`
AS
SELECT * FROM `clarivate-datapipline-project.jstor_international.uni_part1`
UNION ALL
SELECT * FROM `clarivate-datapipline-project.jstor_international.uni_part2`;

CREATE OR REPLACE TABLE `clarivate-datapipline-project.jstor_international.int_bi`
AS
SELECT * FROM `clarivate-datapipline-project.jstor_international.bi_part1`
UNION ALL
SELECT * FROM `clarivate-datapipline-project.jstor_international.bi_part2`;


CREATE OR REPLACE  TABLE `clarivate-datapipline-project.jstor_international.int_tri`
AS
SELECT * FROM `clarivate-datapipline-project.jstor_international.tri_part1`
UNION ALL
SELECT * FROM `clarivate-datapipline-project.jstor_international.tri_part2`;