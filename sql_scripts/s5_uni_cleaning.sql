-- we can clean the uni_, bi_ and trigram data tables using stopwords

-- remove all words that have from 1 fo 2 characters and numbers since we do not want to have have words
-- of this length in the collection of concepts. The number of characters in the stop-words can be adjusted.
-- find the most common 3,4,5,6 letter words and exclude all of them but those present in an allow list

SELECT distinct ngram, sum(count) as sumcount
FROM `clarivate-datapipline-project.lg_jstor.unigrams_cleaned`
WHERE REGEXP_CONTAINS(ngram, r'\b\w{4}\b')
group by ngram
order by sumcount desc;



CREATE OR REPLACE TABLE `clarivate-datapipline-project.lg_jstor.unigrams_cleaned` AS
SELECT
  -- keep all columns except old `ngram`
  * EXCEPT(ngram),
  -- store trimmed + lowercased as the final `ngram`
  TRIM(LOWER(ngram)) AS ngram
FROM `clarivate-datapipline-project.lg_jstor.unigrams_deduplicated`
WHERE
  -- 1) Not a short word (1 or 2 letters)
  LENGTH(TRIM(ngram)) NOT BETWEEN 1 AND 2

  -- 2) If it’s 3 letters, it must be in the allowlist (like "the","and","for")
  AND NOT (
    LENGTH(TRIM(ngram)) = 3
    AND LOWER(TRIM(ngram)) NOT IN ("law", "job", "age", "tax", "war", "usa")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 4
    AND LOWER(TRIM(ngram)) NOT IN ("work", "city")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 5
    AND LOWER(TRIM(ngram)) NOT IN ("urban", "state", "grant", "japan", "spain", "trump", "egypt", "islam", "kenya", "local")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 6
    AND LOWER(TRIM(ngram)) NOT IN ("policy", "public", "region", "budget", "county", "zoning")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 7
    AND LOWER(TRIM(ngram)) NOT IN ("citizen", "service", "council", "finance", "charter")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 8
    AND LOWER(TRIM(ngram)) NOT IN ("election", "planning", "governor")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 9
    AND LOWER(TRIM(ngram)) NOT IN ("community", "democracy", "authority", "territory", "ordinance")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 10
    AND LOWER(TRIM(ngram)) NOT IN ("leadership", "compliance", "federalism")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 11
    AND LOWER(TRIM(ngram)) NOT IN ("bureaucracy")
  )

  AND NOT (
    LENGTH(TRIM(ngram)) = 12
    AND LOWER(TRIM(ngram)) NOT IN ("coordination", "constitution", "metropolitan", "unemployment", "bureaucratic")
  )

  -- 3) Exclude numeric, special chars, underscore, multi-token strings with a single regex
  AND NOT REGEXP_CONTAINS(
    TRIM(LOWER(ngram)),
    r'[^\w\s]|\d|^(?:_.*)|(?:_.*)$|\s'
  )

  -- 4) Exclude empty after trimming
  AND TRIM(LOWER(ngram)) <> '';

-- -- we use python to generate a list of
--
-- DELETE
-- FROM `clarivate-datapipline-project.jstor_international.int_bi`
-- WHERE REGEXP_CONTAINS(
--   ngram,
--   r'(?i)\b(the|levels|every|power|proposed|model|emotions|structured|around|year|good|taking|care|brand|shift|water|towards|example|direct|because|important|global|service|delivery|significant|interests|include|contribution|another|daily|life|positively|associated|bring|together|exchange|rate|life|important|fixed|practices|almost|best|exclusively|global|social|camp|significant|effect|long|annual|meeting|well|term|known|police|aasld|denotes|general|assembly|officers|long|history|often|ocean|being|part|despite|river|lake|used|last|part|aspects|large|small|risk|various|particular|across|possible|first|made|least|squares|task|draws|attention|draw|level|lived|when|authors|argue|issues|anyone|final|food|once|or|if|next|near|far|close|impact|highly|small|natural|again|related|based|accordingly|dagestantsev|absolute|kodak|EASL|former|late|little|big|early|where|associate|news|some|cases|professor|errors|focus|cannot|them|are|wfx|Seven|vote|toiletries|acquire|Correspondence|challengers|hepatitis|them|help|afp|goes|brings|til|beyond|themselves|reflect|sample|role|mass|media|place|people|upon|find|emerald|such|takes|such|edited|light|book|offers|shed|insight|third|free|purpose|second|vast|literature|order|reprints|trade|published|comparative|analysis|full|everyday|corresponding|higher|under|distributed|deal|level|better|take|host|three|recent|these|what|extent|studies|other|forms|previous|after|years|theoretical|results|likely|types|different|findings|these|less|would|other|like|many|text|among|over|wide|other|local|each|toward|attitudes|wiley|toward|other|between|against|although|while|could|as|those|press|first|time|both|sense|make|able|early|visit|please|information|apart|think|very|number|about|abstract|issue|about|research|this|were|also|note|even|publishing|sons|data|from|away|from|there|which|most|review|reviews|paper|more|study|journal|article|with|been|than|rather|have|will|left|briefly|true|their|fried|must|folk|took|pencil|might|windows|into|that|they|came|and|is|of|in|to|for|with|on|by|at|an|a)\b'
-- );