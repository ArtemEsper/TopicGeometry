-- to reduce the number of rows we can clean the uni_, bi_ and trigram data tables using stopwords

-- remove all words that have from 1 fo 5 characters and numbers since we do not have words of this length in
-- the collection of keywords. The number of characters in the stop-words can be adjusted.
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_uni`
WHERE
  REGEXP_CONTAINS(
    ngram,
    r'[^\w\s]+|(^|\s)\w(\s|$)|(^|\s)\w\w(\s|$)|(^|\s)\w\w\w(\s|$)|(^|\s)\w\w\w\w(\s|$)|(^|\s)\w{5}(\s|$)|\d'
  )
  OR ngram = '';

-- find the most common 6 letter words and selectively delete them
SELECT distinct LOWER(ngram) as ngram, sum(count) as sumcount
FROM `clarivate-datapipline-project.jstor_international.int_uni`
WHERE REGEXP_CONTAINS(ngram, r'\b\w{6}\b')
group by ngram
order by sumcount desc;


DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(the|levels|every|power|negative emotions|proposed|model|emotions|structured|around|year|good|taking|care|brand|shift|water|towards|example|direct|because|important|global|service delivery|delivery|significant|interests include|include|contribution|another|daily|life|positively|associated|bring|together|exchange|rate|family life|party system|important|fixed|practices|almost|best|exclusively|global social|camp|significant|effect|long|annual|meeting|well|term|known|police|aasld|denotes|general|assembly|officers|long|history|often|ocean|being|part|despite|river|lake|used|last|part|aspects|large|small|risk|various|particular|across|possible|first|made|least|squares|task|draws|attention|draw|level|lived|when|authors|argue|issues|anyone|final|food|once|or|if|next|near|far|close|impact|highly|small|natural|again|related|based|accordingly|dagestantsev|absolute|kodak|EASL|former|late|little|big|early|where|associate|news|some|cases|professor|errors|focus|cannot|them|are|wfx|Seven|vote|toiletries|acquire|Correspondence|challengers|hepatitis|them|help|afp|goes|brings|til|beyond|themselves|reflect|sample|role|mass|media|place|people|upon|find|emerald|such|takes|such|edited|light|book|offers|shed|insight|third|free|purpose|second|vast|literature|order|reprints|trade|published|comparative|analysis|full|everyday|corresponding|higher|under|distributed|deal|level|better|take|host|three|recent|these|what|extent|studies|other|forms|previous|after|years|theoretical|results|likely|types|different|findings|these|less|would|other|like|many|text|among|over|wide|other|local|each|toward|attitudes|wiley|toward|other|between|against|although|while|could|as|those|press|first|time|both|sense|make|able|early|visit|please|information|apart|think|very|number|about|abstract|issue|about|research|this|were|also|note|even|publishing|sons|data|from|away|from|there|which|most|review|reviews|\n|paper|more|study|journal|article|with|been|than|rather|have|will|left|briefly|true|their|fried|must|folk|took|pencil|might|windows|into|that|they|came|and|is|of|in|to|for|with|on|by|at|an|a)\b'
);

-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cleaning the bigram table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
-- we delete all the entries where there is a period (.), comma (,), or semicolon (;), (:) or '(' or ')' or "?" or ").,"
-- between two words with space followed before or after
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(\b\w+[\.,;():”¿¡“?!]+\s*\w+\b)|(\b\w+\s*[\.,;():”¿¡“?!]+\w+\b)|([\.,;():”¿¡“?!]+\s*\w+\b)|(\b\w+\s*[\.,;():”¿¡“?!]+$)'
);

--remove all the entries with digits
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(ngram, r'\d');

-- remove all entries where any of the words are single, two or three letter words
DELETE
FROM
  `clarivate-datapipline-project.jstor_international.int_bi`
WHERE
  REGEXP_CONTAINS(
    ngram,
    r'\b\w{1,3}\b\s+\b\w+\b|\b\w+\b\s+\b\w{1,3}\b'
  );

-- removes entries with special characters found in any of the words (deletes mostly non english entries)
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
  ngram,
  r'\b(?:[^\w\s]*[^\w\d\s]+[^\w\s]*)+\b'
);


-- removes the entries where "—" is a standalone word
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
  ngram,
  r'\b—\b|\b—\s+\w+|\w+\s+—\b'
);

-- deletes entries there is an empty or whitespace-only segment within the ngram between words, but only
-- if the entire entry or one of the two words is blank or whitespace
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(^| )\s+($| )'
);

-- this pattern
-- \[.*\]: Matches any sequence within square brackets, like [was].
-- -: Matches entries containing hyphens without specifying spacing around them.
-- \.\s*\.: Matches cases with one or more periods followed by whitespace and another period, like "quest. .".
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
  ngram,
  r'\[.*\]|-|\.\s*\.'  -- Matches patterns with square brackets, hyphens, or multiple periods
);

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(the|when|based|EASL|errors|focus|cannot|them|are|wfx|Seven|vote|toiletries|acquire|Correspondence|challengers|hepatitis|them|help|afp|goes|brings|til|beyond|themselves|upon|find|emerald|such|takes|such|edited|light|book|offers|shed|insight|third|free|purpose|second|vast|literature|order|reprints|trade|published|comparative|analysis|full|everyday|corresponding|higher|under|distributed|deal|level|better|take|host|three|recent|these|what|extent|studies|other|forms|previous|after|years|theoretical|results|likely|types|different|findings|these|less|would|other|like|many|text|among|over|wide|other|local|each|toward|attitudes|wiley|toward|other|between|against|although|while|could|as|those|press|first|time|both|sense|make|able|early|visit|please|information|apart|think|very|number|about|abstract|issue|about|research|this|were|also|note|even|publishing|sons|data|from|away|from|there|which|most|review|reviews|\n|paper|more|study|journal|article|with|been|than|rather|have|will|left|briefly|true|their|fried|must|folk|took|pencil|might|windows|into|that|they|came|and|is|of|in|to|for|with|on|by|at|an|a)\b'
);

-- this will delete entries with various special symbols
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)(\b\n\s*\n\b|\bp\s*<\b|\b\*\*\s*\*\b|\bm\.,\s*&\b|\b–\s*–\b)'
);

-- this will delete entries with various special symbols
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)(\b\n\s*\n\b|\bp\s*<\b|\b\*\*\s*\*\b|\bm\.,\s*&\b|\b–\s*–\b|^\s*\[.*?\]\s*$|^\s*\w\s*\W\s*$)'
);

-- this will delete entries with various special symbols
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)(\b\n\s*\n\b|^\s*p\s*<\s*$|^\s*\*\*\s*\*\s*$|^\s*m\.,\s*&\s*$|^\s*–\s*–\s*$|^\s*\[.*?\]\s*$|^\s*\w{1,2}\s*[\W_]+\s*\w{1,2}\s*$|^\s*quest\.\s*\.\s*$|^\s*te\s*-\s*im\s*$|^\s*\[was\]\s*to\s*$)'
);

-- this will delete entries with various special symbols and with non english words
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE
  -- Matches entries that are entirely whitespace, including multiple spaces, tabs, and newlines
  TRIM(REGEXP_REPLACE(ngram, r'[\s\n]+', '')) = ''
  OR
  -- Matches specific unwanted patterns: `p <`, `** *`, `m., &`, `– –`, and similar
  REGEXP_CONTAINS(ngram, r'(?i)^\s*p\s*<\s*$|^\s*\*\*\s*\*\s*$|^\s*m\.,\s*&\s*$|^\s*–\s*–\s*$')
  OR
  -- Matches additional cases like `\n \n`, or entries with only punctuation or symbols
  REGEXP_CONTAINS(ngram, r'^[^\w]*$')
  OR
  -- Matches sequences with multiple spaces or newlines (catches `\n \n` specifically) (NOT WORKING!!!!)
  REGEXP_CONTAINS(ngram, r'^\s*[\n\r]+\s*$');

-- (\n \n): Targets exactly \n \n.
-- (\bp\b\s*<): Matches cases like p < where p is followed by < after optional whitespace.
-- (\*\s*\*): Finds ** *, matching any spacing between * symbols.
-- \s+–\s+: Finds dash patterns surrounded by spaces.
-- ^[^a-zA-Z0-9]+$: Matches entries that consist only of non-alphanumeric characters.
-- \s{2,} matches two or more whitespace characters (\s includes spaces, tabs, and newlines).


Delete
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(ngram, r'(\n \n)|(\bp\b\s*<)|(\*\s*\*)')
OR REGEXP_CONTAINS(ngram, r'\s+–\s+')
OR REGEXP_CONTAINS(ngram, r'^[^a-zA-Z0-9]+$')
OR REGEXP_CONTAINS(ngram, r'\s{2,}');

-- deletes some unwanted strings
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE ngram LIKE '%\\t\\n\\n%';

-- removes  the " abr.] [see" and "c., &" and "r., &" entries and something like "c© royal" and "(© afp"

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w,\s&|[\w\s\]]+\.\]\s\[\w+|[a-z]\.,\s&|c©\sroyal|\(©\safp'
);

-- cleaning the patterns like "– but" or "hemasphere |"
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\p{Pd}\s?\w+|\w+\s?\|'
);

-- delete "theory ©" patterns

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w+\s?©'
);

-- removes patterns like "business &" and "– it" and "implications –"

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w+\s*[&=©|–]\s*\w+\b|\b\w+\s*–|©\s*\w+\b|\b\w+\s*='
);

-- captures patterns like "guanqiu 鲁せ球" or "鲁せ球 guanqiu" and "α −i" and also "conundrum," dora"
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w+[.,;:!?\"\'”]+\s*\w+\b|\b\w+\s*[.,;:!?\"\'”]+\w+\b|\b[\p{Han}\p{Katakana}\p{Greek}−−−]+\s*\w+\b|\b\w+\s*[\p{Han}\p{Katakana}\p{Greek}−−−]+\b'
);

-- this deletes
-- \b\w+\s*[.,;:!?\"\'””‘“—–-]+\s*\w+\b: Matches words that have any punctuation (including various types of dashes –, —, and hyphens -) in between, possibly with spaces around the punctuation.
-- \b[.,;:!?\"\'””‘“—–-]+\s*\w+\b: Matches entries where punctuation precedes a word.
-- \b\w+\s*[.,;:!?\"\'””‘“—–-]+\b: Matches entries where punctuation follows a word
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w+\s*[.,;:!?\"\'””‘“—–-]+\s*\w+\b|\b[.,;:!?\"\'””‘“—–-]+\s*\w+\b|\b\w+\s*[.,;:!?\"\'””‘“—–-]+\b'
);

-- this deletes
-- [—–-]: Matches any of the dash characters (—, –, or -).
-- \s*: Allows for optional spaces between the dash and the word.
-- \b\w+\b: Matches a whole word following the dash (or preceding the dash in the alternative).
-- (?: ... ): A non-capturing group to match either pattern.
-- (?i): Makes the pattern case-insensitive.

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)(?:[—–-]\s*\b\w+\b|\b\w+\b\s*[—–-])'
);

-- delete patterns like "à la" and "& business" or "business &"

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)(?:\b\w+\b\s*[—–&-]\s*\b\w+\b|\b\w+\b\s*[—–&-]|[—–&-]\s*\b\w+\b|à\s+la)'
);

-- delete patterns like: "libraries \n", "• september", or "science &" also captures som of the "\n \n" entries

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)(\b\w+\s*\\n\b|\b•\s+\w+\b|\b\w+\s*&\b|\b&\s*\w+\b)'
);

-- delete patterns like ""• september" and others lake `word' word` and `word'" word`

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)(\b•\s+\w+\b|\b\w+\s*•\b|\b\w+\s*&\b|\b&\s*\w+\b|\b\w+\s+[^\w\s]+\b|[^\w\s]+\s+\w+\b)'
);

-- capture cases like "s. &" where we have a single-letter word or abbreviation followed by punctuation and an ampersand

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w{1,3}\.\s*&|\b\w{1,3},\s*&'
);

-- deletes patterns like "xiv +", "xiv =", "xiv <", "xiv >"

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w+\s*[\+\=\<\>]'
);

-- this deletes patterns where word is followed by a special character like "•"

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(ngram, r"\b\w+\s[•]");

-- delete various strings with `'’”“.,;()?! inbetween or ant the end of the words almost all are irrelevant
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(ngram, r"(?i)(^[`'’”“.,;()?!\[\]\s]+\w+)|(\w+[`'’”“.,;()?!\[\]\s]+$)");

--deletes entries with '’”“‘‘.,:; inbetween words
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(
    ngram,
    r"(?i)\b\w+[\s`'’”“‘‘.,:;()?!\[\]]+\w+\b"
)
AND NOT REGEXP_CONTAINS(
    ngram,
    r"(?i)\b\w+\s+\w+\b"
);

-- another pattern that captures words with unwanted symbols
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_bi`
WHERE REGEXP_CONTAINS(ngram, r"[^a-zA-Z0-9\s]{2,}");

-- update table to remove extra symbols at the beginning and at the end of the bigram
UPDATE `clarivate-datapipline-project.jstor_international.int_bi`
SET ngram = REGEXP_REPLACE(
    REGEXP_REPLACE(ngram, r"(?i)^[`'’”“.,;()\s]+", ""),  -- Remove unwanted characters at the start of the first word
    r"(?i)[`'’”“.,;()\s]+$", ""                          -- Remove unwanted characters at the end of the second word
)
WHERE REGEXP_CONTAINS(ngram, r"(?i)(^[`'’”“.,;()\s]+\w+\s\w+)|(\w+\s\w+[`'’”“.,;()\s]+$)");

east harlem/
    facilities since…
        eracy experience,"
        ‘virtual employee


-- %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% cleaning the trigram table %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'\b\w+[.,;():\s]*\w+\b'
);
--remove all the entries with digits
DELETE
FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(ngram, r'\d');