-- Consolidated Clean-Up Query for `int_bi` Table in BigQuery

-- Update to remove extra symbols at the beginning and end of the bigram
UPDATE `clarivate-datapipline-project.jstor_international.int_bi`
SET ngram = REGEXP_REPLACE(
    REGEXP_REPLACE(ngram, r"(?i)^[`'’”“.,;()\s]+", ""),  -- Remove unwanted characters at the start of the first word
    r"(?i)[`'’”“.,;()\s]+$", ""                          -- Remove unwanted characters at the end of the second word
)
WHERE REGEXP_CONTAINS(ngram, r"(?i)(^[`'’”“.,;()\s]+\w+\s\w+)|(\w+\s\w+[`'’”“.,;()\s]+$)");

-- Remove entries with unwanted patterns, symbols, and special characters
DELETE FROM `clarivate-datapipline-project.jstor_international.int_bi_test`
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
  r'(?i)\b(the|staff|members|raises|questions|particularly|relevant|basic needs|much|greater|particularly|useful|chapter|concluding chapter|preferences|policy preferences|confidence|confidence intervals|world quarterly|behavior|political behavior|traced back|central argument|liberal democratic|deeply|divided|diff erent|different|diff|erent|one|two|three|four|five|six|seven|especially|since|past|decade|provide|provide evidence|four chapters|chapters|measured|using|consent|became|increasingly|rates|rate|urgent|need|coping strategies|social structure|varying|degrees|percentage|points|qualitative|methods|common|method|much|larger|involved|deeper|challenges faced|faced|material culture|matherial|only|through|examine|whether|mobile phone|phone|factors affecting|affecting|contextual|contextual factors|empirical|material|dependent variables|variables|variable|gross domestic|university medical|relatively|appendix|discriminant validity|border wall|wall|presented|here|significantly|lower|conference|abstracts|during world|during|lessons learned|national political|indirect effects|indirect|original|work|presidential poster|root|causes|turning point|turning|newly|arrived|civic|engagement|transnational social|positive|effects|nation states|challenges facing|should consider|intergroup contact|factors influencing|international social|welcome addition|negative consequences|social context|achieved through|central african|give rise|author|argues|peace process|european political|action plan|social status|foreign relations|state department|university hospital|destination countries|customer|satisfaction|levels|further reading|population growth|conflicting interests|evidence suggests|competitive advantage|analytical framework|foreign minister|worth noting|high degree|asia pacific|anonymous reviewers|contemporary political|congenital heart|program arranged|international humanitarian|short|public support|notices|critical discourse|high degree|york city|every|international legal|through social|social democratic|domestic political|european social|independent variables|determine|whether|control variables|international monetary|power|york times|english language|congress|increasingly|american sociological|copyright|abstracts|accuracy|including|online|look|forward|notable|within|offspring|outside|negative emotions|proposed|model|emotions|structured|around|year|good|taking|care|brand|shift|water|towards|example|direct|because|important|global|service delivery|delivery|significant|interests include|include|contribution|another|daily|life|positively|associated|bring|together|exchange|rate|family life|party system|important|fixed|practices|almost|best|exclusively|global social|camp|significant|effect|long|annual|meeting|well|term|known|police|aasld|denotes|general|assembly|officers|long|history|often|ocean|being|part|despite|river|lake|used|last|part|aspects|large|small|risk|various|particular|across|possible|first|made|least|squares|task|draws|attention|draw|level|lived|when|authors|argue|issues|anyone|final|food|once|or|if|next|near|far|close|impact|highly|small|natural|again|related|based|accordingly|dagestantsev|absolute|kodak|EASL|former|late|little|big|early|where|associate|news|some|cases|professor|errors|focus|cannot|them|are|wfx|Seven|vote|toiletries|acquire|Correspondence|challengers|hepatitis|them|help|afp|goes|brings|til|beyond|themselves|reflect|sample|role|mass|media|place|people|upon|find|emerald|such|takes|such|edited|light|book|offers|shed|insight|third|free|purpose|second|vast|literature|order|reprints|trade|published|comparative|analysis|full|everyday|corresponding|higher|under|distributed|deal|level|better|take|host|three|recent|these|what|extent|studies|other|forms|previous|after|years|theoretical|results|likely|types|different|findings|these|less|would|other|like|many|text|among|over|wide|other|local|each|toward|attitudes|wiley|toward|other|between|against|although|while|could|as|those|press|first|time|both|sense|make|able|early|visit|please|information|apart|think|very|number|about|abstract|issue|about|research|this|were|also|note|even|publishing|sons|data|from|away|from|there|which|most|review|reviews|paper|more|study|journal|article|with|been|than|rather|have|will|left|briefly|true|their|fried|must|folk|took|pencil|might|windows|into|that|they|came|and|is|of|in|to|for|with|on|by|at|an|a)\b'
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
  REGEXP_CONTAINS(ngram, r'(?i)\b\w+[.,;:!?\"\'”]+\s*\w+\b|\b\w+\s*[.,;:!?\"\'”]+\w+\b|\b[\p{Han}\p{Katakana}\p{Greek}−−−]+\s*\w+\b|\b\w+\s*[\p{Han}\p{Katakana}\p{Greek}−−−]+\b');



-- test for the most common bigrams

SELECT distinct LOWER(ngram) as ngram,
                sum(count) as sumcount
FROM `clarivate-datapipline-project.jstor_international.int_bi`
group by ngram
order by sumcount desc;