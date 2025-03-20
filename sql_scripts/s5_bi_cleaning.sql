-- Consolidated Clean-Up Query for bigrams Table in BigQuery

-- Stage 1 Create a copy of a table for cleaning
CREATE OR REPLACE TABLE `clarivate-datapipline-project.lg_jstor.bigrams_cleaned` AS
SELECT * FROM `clarivate-datapipline-project.lg_jstor.bigrams_deduplicated`;

-- Stage 2 Update to remove extra symbols at the beginning and end of the bigram
UPDATE `clarivate-datapipline-project.lg_jstor.bigrams_cleaned`
SET ngram = REGEXP_REPLACE(
    REGEXP_REPLACE(ngram, r"(?i)^[`'’”“.,;()\s]+", ""),  -- Remove unwanted characters at the start of the first word
    r"(?i)[`'’”“.,;()\s]+$", ""                          -- Remove unwanted characters at the end of the second word
)
WHERE REGEXP_CONTAINS(ngram, r"(?i)(^[`'’”“.,;()\s]+\w+\s\w+)|(\w+\s\w+[`'’”“.,;()\s]+$)");

-- removes quotes "" around the bigrams
UPDATE `clarivate-datapipline-project.lg_jstor.bigrams_cleaned`
SET ngram = REGEXP_REPLACE(ngram, r"^['\"]([a-zA-Z]+ [a-zA-Z]+)['\"]$", r'\1')
WHERE REGEXP_CONTAINS(
  ngram,
  r"^['\"][a-zA-Z]+ [a-zA-Z]+['\"]$"
);

-- Stage 3 Deleting the rare bigrams
DELETE FROM `clarivate-datapipline-project.lg_jstor.bigrams_cleaned`
WHERE LOWER(ngram) IN (
    SELECT ngram
    FROM (
        SELECT LOWER(ngram) AS ngram,
               SUM(count) AS sumcount
        FROM `clarivate-datapipline-project.lg_jstor.bigrams_cleaned`
        GROUP BY ngram
        HAVING SUM(count) < 10
    )
);


--############################### cleaning #####################################

-- Stage 4 Remove entries with unwanted patterns, symbols, and special characters
DELETE FROM `clarivate-datapipline-project.lg_jstor.bigrams_cleaned`
WHERE
  -- Entries with punctuation or special characters between or around words
  REGEXP_CONTAINS(ngram, r'(?i)\b\w+[\.,;():”¿¡“?!]+\s*\w+\b|\b\w+\s*[\.,;():”¿¡“?!]+\w+\b|[\.,;():”¿¡“?!]+\s*\w+\b|\b\w+\s*[\.,;():”¿¡“?!]+$')
  OR
  -- Entries with digits
  REGEXP_CONTAINS(ngram, r'\d')
  OR
  -- Single-letter, two-letter, or three-letter words within bigrams
  REGEXP_CONTAINS(ngram, r'\b\w{1,3}\b\s+\b\w+\b|\b\w+\b\s+\b\w{1,3}\b')
  OR
  -- Non-English characters or words with mixed special characters
  REGEXP_CONTAINS(ngram, r'\b(?:[^\w\s]*[^\w\d\s]+[^\w\s]*)+\b')
  OR
  -- Standalone dashes or entries with a dash followed by a word
  REGEXP_CONTAINS(ngram, r'\b—\b|\b—\s+\w+|\w+\s+—\b')
  OR
  -- Empty or whitespace-only segment within the ngram between words
  REGEXP_CONTAINS(ngram, r'(^| )\s+($| )')
  OR
  -- Entries with square brackets, hyphens, or multiple periods
  REGEXP_CONTAINS(ngram, r'\[.*\]|-|\.\s*\.\b')
  OR
  -- Common stopwords and filler words
  REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(the|staff|members|raises|questions|particularly|relevant|basic needs|much|greater|particularly|useful|chapter|concluding chapter|preferences|policy preferences|confidence|confidence intervals|world quarterly|behavior|political behavior|traced back|central argument|liberal democratic|deeply|divided|diff erent|different|diff|erent|one|two|three|four|five|six|seven|especially|since|past|decade|provide|provide evidence|four chapters|chapters|measured|using|consent|became|increasingly|rates|rate|urgent|need|coping strategies|social structure|varying|degrees|percentage|points|qualitative|methods|common|method|much|larger|involved|deeper|challenges faced|faced|material culture|matherial|only|through|examine|whether|mobile phone|phone|factors affecting|affecting|contextual|contextual factors|empirical|material|dependent variables|variables|variable|gross domestic|university medical|relatively|appendix|discriminant validity|border wall|wall|presented|here|significantly|lower|conference|abstracts|during world|during|lessons learned|national political|indirect effects|indirect|original|work|presidential poster|root|causes|turning point|turning|newly|arrived|civic|engagement|transnational social|positive|effects|nation states|challenges facing|should consider|intergroup contact|factors influencing|international social|welcome addition|negative consequences|social context|achieved through|central african|give rise|author|argues|peace process|european political|action plan|social status|foreign relations|state department|university hospital|destination countries|customer|satisfaction|levels|further reading|population growth|conflicting interests|evidence suggests|competitive advantage|analytical framework|foreign minister|worth noting|high degree|asia pacific|anonymous reviewers|contemporary political|congenital heart|program arranged|international humanitarian|short|public support|notices|critical discourse|high degree|york city|every|international legal|through social|social democratic|domestic political|european social|independent variables|determine|whether|control variables|international monetary|power|york times|english language|congress|increasingly|american sociological|copyright|abstracts|accuracy|including|online|look|forward|notable|within|offspring|outside|negative emotions|proposed|model|emotions|structured|around|year|good|taking|care|brand|shift|water|towards|example|direct|because|important|global|service delivery|delivery|significant|interests include|include|contribution|another|daily|life|positively|associated|bring|together|exchange|rate|family life|party system|important|fixed|practices|almost|best|exclusively|global social|camp|significant|effect|long|annual|meeting|well|term|known|police|aasld|denotes|general|assembly|officers|long|history|often|ocean|being|part|despite|river|lake|used|last|part|aspects|large|small|risk|various|particular|across|possible|first|made|least|squares|task|draws|attention|draw|level|lived|when|authors|argue|issues|anyone|final|food|once|or|if|next|near|far|close|impact|highly|small|natural|again|related|based|accordingly|dagestantsev|absolute|kodak|EASL|former|late|little|big|early|where|associate|news|some|cases|professor|errors|focus|cannot|them|are|wfx|Seven|vote|toiletries|acquire|Correspondence|challengers|hepatitis|them|help|afp|goes|brings|til|beyond|themselves|reflect|sample|role|mass|media|place|people|upon|find|emerald|such|takes|such|edited|light|book|offers|shed|insight|third|free|purpose|second|vast|literature|order|reprints|trade|published|comparative|analysis|full|everyday|corresponding|higher|under|distributed|deal|level|better|take|host|three|recent|these|what|extent|studies|other|forms|previous|after|years|theoretical|results|likely|types|different|findings|these|less|would|other|like|many|text|among|over|wide|other|local|each|toward|attitudes|wiley|toward|other|between|against|although|while|could|as|those|press|first|time|both|sense|make|able|early|visit|please|information|apart|think|very|number|about|abstract|issue|about|research|this|were|also|note|even|publishing|sons|data|from|away|from|there|which|most|review|reviews|paper|more|study|journal|article|with|been|than|rather|have|will|left|briefly|true|their|fried|must|folk|took|pencil|might|windows|into|that|they|came|and|is|of|in|to|for|with|on|by|at|an|a|thus|open|down|today|fail|inner|outer|before|after|help|helps|digit|held|older|century|quarterly|sage|oaks|open access|logistic regression|substance abuse|market share|mentioned above|minimum wage|rights reserved|signifi cant|statistical significance|international human|high quality|discussed above|control group|described above|potential conflicts|noted above|chronic disease|economic conditions|dynamic capabilities|international financial|likert scale|vice versa|same period|physical health|regression models|adverse events|current account|management science|offi cials|health needs|listed companies|services provided|strongly disagree|affirmative action|infl uence|value added|technical assistance|economic theory|heart failure|blood pressure|broad range|human beings|agency theory|success factors|personal communication|business models|heart disease|emphasis added|total quality|health conditions|international political|development process|family member|leadership style|york university|ownership structure|following section|case management|prescription drug|several times|planning process|supply chains|behavioral health|infectious diseases|continuous improvement|cultural heritage|grounded theory|american indian|negative relationship|clinical trial|business process|controlled trial|inter alia|government should|laid down|gender differences|political weekly|population health|cash flow|young women|standard deviations|bottom line|campaign finance|government printing|relative importance|publicly available|null hypothesis|great depression|developing world|political elites|turnover intention|advanced nursing|financial times|dispute settlement|accessed july|	limited resources|electronic health|rapid growth|robust standard|health nurses|allied health|york state|social identity|european public|middle managers|selection process|political influence|state institutions|doing business|accessed march|basic books|current state|diffi cult|project team|civil wars|real world|social relationships|several reasons|helpful comments|leadership development|printing office|accessed june|training program|school board|international economic|months later|real interest|international criminal|british medical|discussed below|oecd countries|joint venture|london school|select committee|older workers|board size|strategic change|accessed january|drug abuse|nursing management|accessed april|social marketing|middle ages|noted earlier|political systems|equation modeling|chronic diseases|infection control|university college|educational attainment|standard error|odds ratio|medical records|mentioned earlier|come back|private health|accessed february|knowledge base|knowledge base|sixteenth century|readily available|resources available|stakeholder groups|randomized controlled|clearly defined|clearly|value chain|steady state|accessed august|multinational corporations|social inclusion|environmental health|without having|without|having|monetary union|offi cial|high performance|shareholder value|cancer patients|leadership styles|properly cited|medical record|digital technologies|health serv|accessed october|capital stock|until recently|continuing education|internal consistency|outcome measures|decision support|health plans|quality control|englewood cliffs|accessed november|accessed|external stakeholders|external|business case|adverse drug|driving force|puerto rican|executive officer|randomly selected|young children|medical treatment|several factors|political leadership|australian national|participants reported|agenda setting|individual rights|several decades|summary statistics|private equity|external factors|impor tant|social interactions|successful implementation|family caregivers|health management|structural change|regression analyses|interaction terms|improve patient|pain management|strong support)\b'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)(\b[[:alnum:]]+[.,;():?!\[\]–\-«»][[:space:]]*[[:alnum:]]+[[:space:]]*[[:alnum:]]+\b|\b[[:alnum:]]+[[:space:]]*[[:alnum:]]+[[:space:]]*[.,;():?!\[\]–\-«»]\b|[.,;():?!\[\]–\-«»][[:space:]]*[[:alnum:]]+[[:space:]]*[[:alnum:]]+\b|\b[[:alnum:]]+[[:space:]]*[[:alnum:]]+[[:space:]]*[.,;():?!\[\]–\-«»]$|\b[[:alnum:]]+[[:space:]]*[‘’\'"«»][[:space:]]*[[:alnum:]]+\b|\b[[:alnum:]]+,[[:space:]]*[‘’\'"«»][[:space:]]*[[:alnum:]]+\b)'
)
  OR
  -- Entries with \n, *, & m., or dash-dash patterns
  REGEXP_CONTAINS(ngram, r'(?i)\b\n\s*\n\b|\bp\s*<\b|\b\*\*\s*\*\b|\bm\.,\s*&\b|\b–\s*–\b')
  OR
  -- Entries with non-informative symbols or patterns
  REGEXP_CONTAINS(ngram, r'^[^\w]*$')
  OR
  -- Sequences of square brackets or empty brackets around words
  REGEXP_CONTAINS(ngram, r'^\s*\[.*?\]\s*$|^\s*\w\s*\W\s*$')
  OR
  -- Extra punctuation or whitespace at the start or end of bigrams
  REGEXP_CONTAINS(ngram, r"(?i)(^[`'’”“.,;()?!\[\]\s]+\w+)|(\w+[`'’”“.,;()?!\[\]\s]+$)")
  OR
  -- Entries with non-letter characters within words or two non-alphanumeric symbols
  REGEXP_CONTAINS(ngram, r'[^a-zA-Z0-9\s]{2,}')
  OR
  -- Patterns with mixed symbols and international characters like Katakana, Han, or Greek
  REGEXP_CONTAINS(ngram, r'(?i)\b\w+[.,;:!?\"\'”]+\s*\w+\b|\b\w+\s*[.,;:!?\"\'”]+\w+\b|\b[\p{Han}\p{Katakana}\p{Greek}−−−]+\s*\w+\b|\b\w+\s*[\p{Han}\p{Katakana}\p{Greek}−−−]+\b')
  -- (\n \n): Targets exactly \n \n.
  -- (\bp\b\s*<): Matches cases like p < where p is followed by < after optional whitespace.
  -- (\*\s*\*): Finds ** *, matching any spacing between * symbols.
  -- \s+–\s+: Finds dash patterns surrounded by spaces.
  -- ^[^a-zA-Z0-9]+$: Matches entries that consist only of non-alphanumeric characters.
  -- \s{2,} matches two or more whitespace characters (\s includes spaces, tabs, and newlines).
  OR REGEXP_CONTAINS(ngram, r'(\n \n)|(\bp\b\s*<)|(\*\s*\*)')
  OR REGEXP_CONTAINS(ngram, r'\s+–\s+')
  OR REGEXP_CONTAINS(ngram, r'^[^a-zA-Z0-9]+$')
  OR REGEXP_CONTAINS(ngram, r'\s{2,}')
  OR ngram LIKE '%\\t\\n\\n%'
  -- removes  the " abr.] [see" and "c., &" and "r., &" entries and something like "c© royal" and "(© afp"
  OR REGEXP_CONTAINS(ngram,r'(?i)\b\w,\s&|[\w\s\]]+\.\]\s\[\w+|[a-z]\.,\s&|c©\sroyal|\(©\safp')
  -- cleaning the patterns like "– but" or "hemasphere |"
  OR REGEXP_CONTAINS(ngram,r'(?i)\b\p{Pd}\s?\w+|\w+\s?\|')
  -- delete "theory ©" patterns
  OR REGEXP_CONTAINS(ngram,r'(?i)\b\w+\s?©')
  -- removes patterns like "business &" and "– it" and "implications –"
  OR REGEXP_CONTAINS(ngram,r'(?i)\b\w+\s*[&=©|–]\s*\w+\b|\b\w+\s*–|©\s*\w+\b|\b\w+\s*=')
  -- \b\w+\s*[.,;:!?\"\'””‘“—–-]+\s*\w+\b: Matches words that have any punctuation (including various types of dashes –, —, and hyphens -) in between, possibly with spaces around the punctuation.
  -- \b[.,;:!?\"\'””‘“—–-]+\s*\w+\b: Matches entries where punctuation precedes a word.
  -- \b\w+\s*[.,;:!?\"\'””‘“—–-]+\b: Matches entries where punctuation follows a word
  OR REGEXP_CONTAINS(ngram,r'(?i)\b\w+\s*[.,;:!?\"\'””‘“—–-]+\s*\w+\b|\b[.,;:!?\"\'””‘“—–-]+\s*\w+\b|\b\w+\s*[.,;:!?\"\'””‘“—–-]+\b')
  -- [—–-]: Matches any of the dash characters (—, –, or -).
  -- \s*: Allows for optional spaces between the dash and the word.
  -- \b\w+\b: Matches a whole word following the dash (or preceding the dash in the alternative).
  -- (?: ... ): A non-capturing group to match either pattern.
  -- (?i): Makes the pattern case-insensitive.
  OR REGEXP_CONTAINS(ngram,r'(?i)(?:[—–-]\s*\b\w+\b|\b\w+\b\s*[—–-])')
  -- delete patterns like "à la" and "& business" or "business &"
  OR REGEXP_CONTAINS(ngram,r'(?i)(?:\b\w+\b\s*[—–&-]\s*\b\w+\b|\b\w+\b\s*[—–&-]|[—–&-]\s*\b\w+\b|à\s+la)')
  -- delete patterns like: "libraries \n", "• september", or "science &" also captures som of the "\n \n" entries
  OR REGEXP_CONTAINS(ngram,r'(?i)(\b\w+\s*\\n\b|\b•\s+\w+\b|\b\w+\s*&\b|\b&\s*\w+\b)')
  -- delete patterns like ""• september" and others lake `word' word` and `word'" word`
  OR REGEXP_CONTAINS(ngram,r'(?i)(\b•\s+\w+\b|\b\w+\s*•\b|\b\w+\s*&\b|\b&\s*\w+\b|\b\w+\s+[^\w\s]+\b|[^\w\s]+\s+\w+\b)')
  -- capture cases like "s. &" where we have a single-letter word or abbreviation followed by punctuation and an ampersand
  OR REGEXP_CONTAINS(ngram,r'(?i)\b\w{1,3}\.\s*&|\b\w{1,3},\s*&')
  -- deletes patterns like "xiv +", "xiv =", "xiv <", "xiv >"
  OR REGEXP_CONTAINS(ngram,r'(?i)\b\w+\s*[\+\=\<\>]')
  -- this deletes patterns where word is followed by a special character like "•"
  OR REGEXP_CONTAINS(ngram, r"\b\w+\s[•]")
  --deletes entries with '’”“‘‘.,:; inbetween words
  OR REGEXP_CONTAINS(ngram,r"(?i)\b\w+[\s`'’”“‘‘.,:;()?!\[\]]+\w+\b") AND NOT REGEXP_CONTAINS(ngram,r"(?i)\b\w+\s+\w+\b")
  -- similar to "demands: "international"
  OR REGEXP_CONTAINS(ngram,r'\b[A-Za-z]+:\s*"[A-Za-z]+')
  -- removes entries like => word word" or word word* or word word! or word word? if it still present
  OR REGEXP_CONTAINS(ngram,r"\b\w+\b\s+\b\w+['\"*.,!?]")
  -- removes bigrams with a symbol instead of secons word
  OR REGEXP_CONTAINS(ngram,r'^[a-zA-Z]+ \S$')
  -- for pattern like: < recalled* "Sure >
  OR REGEXP_CONTAINS(ngram,r'^[a-zA-Z0-9_]+[*] [\"\'”’][a-zA-Z0-9_]+$')
  -- the first word ends with punctuation and the second word is a special character like •,& or other
  OR REGEXP_CONTAINS(ngram, r"\b\w+[[:punct:]]\s[[:punct:]]")
  -- bigrams like ', Power' or ': Power' and other similar
  OR REGEXP_CONTAINS(ngram, r"^\,\s\w+")
  OR REGEXP_CONTAINS(ngram, r"^\:\s\w+")
  OR REGEXP_CONTAINS(ngram, r"^\;\s\w+")
  OR REGEXP_CONTAINS(ngram, r"^\!\s\w+")
  OR REGEXP_CONTAINS(ngram, r"^\?\s\w+")
  OR REGEXP_CONTAINS(ngram, r"^\'\s\w+")
  OR REGEXP_CONTAINS(ngram, r"^\"\s\w+")
  OR REGEXP_CONTAINS(ngram, r"^\`\s\w+")
  OR REGEXP_CONTAINS(ngram, r"^\``\s\w+")
  OR REGEXP_CONTAINS(ngram, r"^\''\s\w+")
  -- bigram starts with double quote like ("visibly apparent)
  OR REGEXP_CONTAINS(ngram, r'^["\']')
;


-- ################################## Dev queries ###################################

-- SELECT *
-- FROM `clarivate-datapipline-project.lg_jstor.bigrams_cleaned`
-- WHERE REGEXP_CONTAINS(ngram, r"^[^\w\s]\s\w+");
--
--
--
-- SELECT distinct LOWER(ngram) as ngram,
--                 sum(count) as sumcount
-- FROM `clarivate-datapipline-project.lg_jstor.bigrams_cleaned`
-- group by ngram
-- order by sumcount desc;
