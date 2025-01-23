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