-- same can be used in 'int_tri', 'int_bi' and 'int_uni' tables cleaning

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE

  -- 1. Punctuation or Special Characters Around or Between Words
  REGEXP_CONTAINS(
    ngram,
    r'(?i)(\b[[:alnum:]]+[.,;():?!\[\]–\-«»][[:space:]]*[[:alnum:]]+[[:space:]]*[[:alnum:]]+\b'  -- Punctuation following first word
    r'|\b[[:alnum:]]+[[:space:]]*[[:alnum:]]+[[:space:]]*[.,;():?!\[\]–\-«»]\b'                   -- Punctuation after second word
    r'|[.,;():?!\[\]–\-«»][[:space:]]*[[:alnum:]]+[[:space:]]*[[:alnum:]]+\b'                    -- Punctuation before first word
    r'|\b[[:alnum:]]+[[:space:]]*[[:alnum:]]+[[:space:]]*[.,;():?!\[\]–\-«»]$'                   -- Punctuation after third word
    r'|\b[[:alnum:]]+[[:space:]]*[‘’\'"«»][[:space:]]*[[:alnum:]]+\b'                            -- Special quotes around second word
    r'|\b[[:alnum:]]+,[[:space:]]*[‘’\'"«»][[:space:]]*[[:alnum:]]+\b)'                          -- Special quotes after first word
  )

  OR

  -- 2. Entries Containing Digits
  REGEXP_CONTAINS(ngram, r'\d')

  OR

  -- 3. Multiple Periods or Spaces Around Periods
  REGEXP_CONTAINS(
    ngram,
    r'\b[[:alnum:]]+[[:space:]]\.\.[[:space:]]*|'
    r'\b[[:alnum:]]+[[:space:]]*\.[[:space:]]*\.+'
  )

  OR

  -- 4. Brackets and Symbols in Percentages (e.g., "(%)" in a trigram)
  REGEXP_CONTAINS(
    ngram,
    r'\b[[:alnum:]]+[[:space:]]+\([[:alnum:]%]+\)'
  )

  OR

  -- 5. Ampersand (&) and Other Symbols (&, +, •) Around or Between Words
  REGEXP_CONTAINS(
    ngram,
    r'\b[[:alnum:]]+[[:space:]]*&[[:space:]]*[[:alnum:]]+\b'
    r'|\b[[:alnum:]]+[[:space:]]*[&+•][[:space:]]*[[:alnum:]]+\b'
  )

  OR

  -- 6. Accented Characters in Different Positions in Trigrams
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b([[:alnum:]]+[[:space:]]+[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]+[[:space:]]+[[:alnum:]]+'
    r'|[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]+[[:space:]]+[[:alnum:]]+[[:space:]]+[[:alnum:]]+'
    r'|[[:alnum:]]+[[:space:]]+[[:alnum:]]+[[:space:]]+[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý])\b'
  )

  OR

  -- 7. Stand-Alone Symbols (Dashes, Parentheses) in Trigram Positions
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\s+[[:alnum:]]+\s*[\)\(\%\]]+\s*[\%\)]?\b'
  )

  OR

  -- 8. Non-English Characters or Mixed Special Characters in Words
  REGEXP_CONTAINS(
    ngram,
    r'\b(?:[^\w\s]*[^\w\d\s]+[^\w\s]*)+\b'
  )

  OR

  -- 9. Entries with Parentheses and Special Characters like "%"
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\s*\([[:alnum:]]*\)%?\b'
  )

  OR

  -- 10. Patterns with Certain Symbols at End of Phrases
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w+(\s+\w+)*\s+—\s*\b(\w+)?\s*$'
  )

  OR

  -- 11. Invalid Trigram Format: Retain Only Valid Three-Word Format
  NOT REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\s*[[:alnum:]]+\s*[[:alnum:]]+\b'
  )
;

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE
  -- Entries with punctuation or special characters between or around words in trigrams
REGEXP_CONTAINS(
    ngram,
    r'(?i)(\b[[:alnum:]]+[.,;():?!\[\]–\-«»][[:space:]]*[[:alnum:]]+[[:space:]]*[[:alnum:]]+\b|\b[[:alnum:]]+[[:space:]]*[[:alnum:]]+[[:space:]]*[.,;():?!\[\]–\-«»]\b|[.,;():?!\[\]–\-«»][[:space:]]*[[:alnum:]]+[[:space:]]*[[:alnum:]]+\b|\b[[:alnum:]]+[[:space:]]*[[:alnum:]]+[[:space:]]*[.,;():?!\[\]–\-«»]$|\b[[:alnum:]]+[[:space:]]*[‘’\'"«»][[:space:]]*[[:alnum:]]+\b|\b[[:alnum:]]+,[[:space:]]*[‘’\'"«»][[:space:]]*[[:alnum:]]+\b)'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)(\b[[:alnum:]]+[.,;():?!\[\]–\-«»][[:space:]]*[[:alnum:]]+[[:space:]]*[[:alnum:]]+\b|\b[[:alnum:]]+[[:space:]]*[[:alnum:]]+[[:space:]]*[.,;():?!\[\]–\-«»]\b|[.,;():?!\[\]–\-«»][[:space:]]*[[:alnum:]]+[[:space:]]*[[:alnum:]]+\b|\b[[:alnum:]]+[[:space:]]*[[:alnum:]]+[[:space:]]*[.,;():?!\[\]–\-«»]$|\b[[:alnum:]]+[[:space:]]*[‘’\'"«»][[:space:]]*[[:alnum:]]+\b|\b[[:alnum:]]+,[[:space:]]*[‘’\'"«»][[:space:]]*[[:alnum:]]+\b)'
)
  OR
  REGEXP_CONTAINS(ngram, r'\d')
  OR
  REGEXP_CONTAINS(
    ngram,
    r'\b[[:alnum:]]+[[:space:]]\.\.[[:space:]]*'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'\b[[:alnum:]]+[[:space:]]*\.[[:space:]]*\.+'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'\b[[:alnum:]]+[[:space:]]+\([[:alnum:]%]+\)'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'\b[[:alnum:]]+[[:space:]]*&[[:space:]]*[[:alnum:]]+\b'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'\b[[:alnum:]]+[[:space:]]*/[[:space:]]*[[:alnum:]]+\b'
    r'|\b[[:alnum:]]+[[:space:]]+[[:alnum:]]+[[:space:]]*/\b'
    r'|\b[[:alnum:]]+/[[:space:]]+[[:alnum:]]+[[:space:]]+[[:alnum:]]+\b'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+[[:space:]]*[:‘’"“”`´]+[[:space:]]*[[:alnum:]]+[[:space:]]*[[:alnum:]]+\b'
    r'|\b[[:alnum:]]+[[:space:]]+[[:alnum:]]+[[:space:]]*[:‘’"“”`´]+\b'
    r'|\b[[:alnum:]]+[:‘’"“”`´][[:space:]]*[[:alnum:]]+[[:space:]]+[[:alnum:]]+\b'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+[[:space:]]+[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]+[[:space:]]+[[:alnum:]]+\b'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)^\b[[:alnum:]]+[[:space:]]+[[:alnum:]]+[[:space:]]*[‘’\'"–-]+\b|\b[[:alnum:]]+[[:space:]]*[‘’\'"–-]\b'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b([a-zA-Z0-9]+[[:space:]]+[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]+[[:space:]]+[a-zA-Z0-9]+|'  -- Accented characters in the second word
    r'[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]+[[:space:]]+[a-zA-Z0-9]+[[:space:]]+[a-zA-Z0-9]+|'  -- Accented characters in the first word
    r'[a-zA-Z0-9]+[[:space:]]+[a-zA-Z0-9]+[[:space:]]+[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]+)\b'  -- Accented characters in the third word
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w+[.,:;?!]\s*—\s*\w+\b'
)
  OR
  -- Entries with digits in trigrams
  REGEXP_CONTAINS(ngram, r'\d')
  OR
  -- Single-letter, two-letter, or three-letter words within trigrams
  REGEXP_CONTAINS(ngram,r'(?i)\b[a-z]{1,2}\b')
  OR
  REGEXP_CONTAINS(ngram,r'(?i)\b[^a-z\s]{1,3}\b')
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w+(\s+\w+)*[.,:;?!]\s*—\s*$'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w+(\s+\w+)*\s+—\s*\b(\w+)?\s*$'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b\w+(\s+\w+)*\s+—\s*$'
)
  OR
  -- Non-English characters or words with mixed special characters
  REGEXP_CONTAINS(
    ngram,
    r'\b(?:[^\w\s]*[^\w\d\s]+[^\w\s]*)+\b'
  )
  OR
  -- Standalone dashes or entries with a dash followed by a word
  REGEXP_CONTAINS(
    ngram,
    r'\b—\b|\b—\s+\w+|\w+\s+—\b'
  )
  OR
  -- Empty or whitespace-only segment within the ngram between words
  REGEXP_CONTAINS(
    ngram,
    r'(^| )\s+($| )'
  )
  OR
  -- Entries with square brackets, hyphens, or multiple periods
  REGEXP_CONTAINS(
    ngram,
    r'\[.*\]|-|\.\s*\.\b'
  )
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)\b(?:[[:alnum:]]+[[:space:]]+[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]\b|[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]\b[[:space:]]+[[:alnum:]]+[[:space:]]+[[:alnum:]]+\b|[[:alnum:]]+[[:space:]]+[[:alnum:]]+[[:space:]]+[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]\b)'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)(\b[[:alnum:]]+\s+[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]\s+[[:alnum:]]+\b|\b[[:alnum:]]+\s+[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]\b|\b[àáâäæãåāçéèêëēėęîïíīįìôöòóœøōõüùúūñßÿý]\s+[[:alnum:]]+\b)'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)(^à\s+[[:alnum:]]+\s+[[:alnum:]]+$|^[[:alnum:]]+\s+à\s+[[:alnum:]]+$|^[[:alnum:]]+\s+[[:alnum:]]+\s+à$)'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)(\b[[:alnum:]]+\s+[[:alnum:]]+[[:space:]]*[&+•]\b|\b[[:alnum:]]+[[:space:]]*[&+•]\s+[[:alnum:]]+\b|\b[&+•]\s+[[:alnum:]]+\s+[[:alnum:]]+\b)'
)
  OR
  REGEXP_CONTAINS(
    ngram,
    r'(?i)(^[[:alnum:]]+\s+[[:alnum:]]+\s+[&+•]$|^[[:alnum:]]+\s+[&+•]\s+[[:alnum:]]+$|^[&+•]\s+[[:alnum:]]+\s+[[:alnum:]]+$)'
)
 OR
 REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\s+[[:alnum:]]+\s*[\)\(\%\]]+\s*[\%\)]?\b'
)
  OR
 REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\s*\([[:alnum:]]*\)%?\b|\b[[:alnum:]]+\s*[[:alnum:]]+\s*[\(\)\%]+\b|\b[[:alnum:]]+\s*\([\)\%]+\b'
)
 OR
 REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\b\s*[[:alnum:]]*\s*\(\s*%\s*\)'
)
  OR
  NOT REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\s*\(?\)?\s*[[:alnum:]]+\s*\(?\)?\s*[[:alnum:]]+\s*\(?\)?\b'
)
  OR
  NOT REGEXP_CONTAINS(
    ngram,
    r'(?i)^\(?[[:alnum:]]+\)?\s+[[:alnum:]]+\s+\(?[[:alnum:]]+\)?$|^[[:alnum:]]+\s+\(?[[:alnum:]]+\)?\s+[[:alnum:]]+$|^[[:alnum:]]+\s+[[:alnum:]]+\s+\(?[[:alnum:]]+\)?$'
);

--%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE
  -- Matches sequences where words are surrounded by punctuation or contain adjacent punctuation sequences
  REGEXP_CONTAINS(
    ngram,
    r'(?i)(\b[[:punct:]]{1,}\s+[[:alnum:]]+\s+[[:punct:]]{1,}\b|\b[[:alnum:]]+\s*[[:punct:]]{2,}\s*[[:alnum:]]+\b)'
  )
  OR
  -- Captures cases with punctuation sequences between or around words, excluding cases where the second word is "and"
  (REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:punct:]]{1,2}\s*[[:alnum:]]+\s*[[:punct:]]{1,2}\b'
  ) AND NOT REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\s+and\s+[[:alnum:]]+\b'
  ))
  OR
  -- Matches entries with symbols like "word (.", "(. word)", or symbols like "[%]" without surrounding context, excluding "and"
  (REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\s*\(\W{1,2}\)|\(\W{1,2}\)\s*[[:alnum:]]+\b'
  ) AND NOT REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\s+and\s+[[:alnum:]]+\b'
  ))
  OR
  -- Finds cases with isolated punctuation or symbol-only sequences, excluding sequences with "and"
  (REGEXP_CONTAINS(
    ngram,
    r'\b[[:punct:]]{2,}\b|\b\W+\b'
  ) AND NOT REGEXP_CONTAINS(
    ngram,
    r'(?i)\b[[:alnum:]]+\s+and\s+[[:alnum:]]+\b'
  ));

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE
  -- Common stopwords and short function words
  REGEXP_CONTAINS(ngram, r'(?i)\b(the|than|our|ties|contain|for|from|a|and|is|to|of|in|it|on|as|at|by|an|be|or|one|two|three|more|most|several|each|either|neither|his|her|their|this|which|has|have|do|does|did)\b')

  OR

  -- Words specific to metrics, data analysis, and results
  REGEXP_CONTAINS(ngram, r'(?i)\b(publication|research|survey|study|data|analysis|results|findings|figure|table|chart|statistics|percent|years|months|days|hours|times|rate|increase|decrease|variable|sample|mean|average|summary|conclusion)\b')

  OR

  -- Words related to methodology and process
  REGEXP_CONTAINS(ngram, r'(?i)\b(system|goal|objective|criteria|parameter|procedure|formula|concept|model|framework|evaluation|testing|validation|example|illustration|case|factor|context|background|approach|strategy|project|initiative)\b')

  OR

  -- Organizational and structural terms
  REGEXP_CONTAINS(ngram, r'(?i)\b(organization|institution|entity|company|firm|business|enterprise|agency|office|department|division|team|task|role|position|occupation|field|category|classification|type|class|kind|sort|group|subset|section|part|unit|element)\b')

  OR

  -- Contextual and location-based terms
  REGEXP_CONTAINS(ngram, r'(?i)\b(region|territory|zone|location|place|spot|point|area|environment|setting|scene|background|perspective|view|prospect|outlook|landscape|territory|country|state|province|city|town|neighborhood)\b')

  OR

  -- Relationship, connection, and interaction terms
  REGEXP_CONTAINS(ngram, r'(?i)\b(connection|association|relationship|bond|tie|partnership|collaboration|cooperation|interaction|communication|dialogue|exchange|discussion|agreement|alliance|organization)\b')

  OR

  -- General abstract terms and concepts
  REGEXP_CONTAINS(ngram, r'(?i)\b(support|benefit|asset|resource|opportunity|potential|possibility|value|importance|significance|worth|meaning|purpose|insight|understanding|awareness|knowledge|perception|recognition|sensitivity)\b');

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(the|and|is|to|of|in|it|on|as|at|by|an|be|this|which|or|one|two|three|more|many|some|most|several|each|either|neither|own|has|have|do|does|did)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(about|over|between|through|during|after|before|since|until|now|then|when|always|never|today|tomorrow|yesterday|hour|minute|second|day|week|month|year)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(while|where|whose|can|cannot|will|would|should|could|may|might|must|shall|just|all|very|such|much|so|only|even|same|other|another|further|least|less|few|but|or|nor|yet|though|although|despite|however|moreover|therefore|thus|meanwhile|consequently|otherwise|because|due)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(rate|increase|decrease|variable|group|sample|mean|average|standard|deviation|range|summary|conclusion|scope|function|goal|objective|criteria|parameter|method|factor|aspect|element|level|degree|rank|proportion|percentage|balance|density|volume|weight|length|area|space|size|distance)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(organization|company|corporation|business|agency|department|division|team|task|role|position|career|occupation|industry|sector|entity|institution|field|discipline|type|class|format|template|layout|framework|methodology|technique|system|project|initiative|plan|strategy|model|approach|topic|theme|context|background)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(textual|available|used|support|research|study|survey|data|results|findings|figure|table|chart|statistics|sample|example|illustration|concept|principle|guideline|policy|regulation|rule|law|procedure|process|practice|assessment|evaluation|testing|validation|case|context|setting|framework|environment|system|resource|material|equipment|device|mechanism|network|structure|configuration|composition|layout|arrangement|organization|entity)\b'
);

----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(chance|prospect|hope|goal|objective|target|aim|ambition|dream|vision|mission|intention|direction|course)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(plan|agenda|program|initiative|project|scheme|proposal|suggestion|recommendation|advice|guidance|instruction|assistance)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(help|support|backing|aid|service|solution|product|offering|benefit|contribution|input|role|function|task|activity)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(measure|move|step|procedure|process|method|technique|strategy|approach|means|system|tool|device|resource|material|equipment|technology|instrument)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(apparatus|appliance|machine|gadget|contraption|contrivance|gimmick|gizmo|resource|facility|product|item|article|thing|object|material)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(substance|ingredient|element|component|part|piece|fragment|bit|portion|section|segment|division)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(slice|chunk|molecule|atom|grain|flake|chip|shard|sliver|splinter|trace|hint|drop|particle|crumb|speck)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(symbol|badge|label|tag|identity|name|title|brand|trademark|mark|emblem|crest|logo|icon|character|image|illustration)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(type|class|category|genre|species|breed|strain|line|stock|race|group|section|segment|part|division|category|kind|sort|fashion)\b'
);

DELETE FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(setting|environment|landscape|scenery|atmosphere|mood|tone|ambience|backdrop|scene|surroundings|locale|view|panorama)\b'
);

-----

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(undocumented migrants are|eastern europe are|smart|street|light|asian americans are|maximum|likelihood|estimation|norsk|statsvitenskapelig|tidsskrift|ireneusz|pawel|karolewski|bmc|emerg infect dis|presented here are|international relations are|asian countries are|migration policies are|primarily|concerned|xinjiang|uyghur|autonomous|mit|sloan|management|border crossers are|holy|roman|empire|expert|mit|blick|auf|cox|proportional|hazards|immigration policies are|are good reasons|public policies are|inside networks are|undocumented immigrants are|att|clin|infect|dis|tel|kin|helped|ferry|eastern americans are|currently|being|literature|readers|involved|actors|makes|emerald|whilst|every|makes|online|likely|rural areas|held|accountable|issued|copying|competitive elections are|philosopher|press|included|sudden|changes|way|towards|restoring|receive|repeated|calls|tribal|art|alone|dreams|crushed|implicit|threads|almost|entirely|elude|himself|recorded|various|implicit|threads|provides|rare|ethnographic|largest|archaeological|sites|Salvador|brings|together|measurements|across|different|metal|homes|along|contexts|highlights|parte|del|cambio|them|knew|personally|evolving|local|meanings|fieldwork|took|different|faith|traditions|represented|una|esperanza|que|vary|widely|depending|arrived|back|daily|amplia|para|decir|prides|itself|vary|widely|spending|actor|costs|Isolate|play|Expeditionary|partner|designated|collections|budgetary|single|induced|pratiques|Des|PPP|par|approches|infrastructures|primaires|doivent|transfert|eff|ectif|pratiques|depuis|les|approches|institutionnalistes|des|changements|signifi|vue|des|valeurs|potable|des|terrains|acteurs|aux|logiques|plus|importants|que|par|les|associations|important|reminders|seemingly|massive|together|weaves|artfully|privileged|left|accept|fully|continuously|compromising|going|around|successful|small|reaching|becomes|themselves|san|along|situated|limit|interests|overall|francisco|bay|see|supra|notes|natl|acad|sci|extreme|weather|events|border policies are|herefordshire|cain|particularly vulnerable|highly dependent|upon|per|cent|boehme|trinity|lutheran|missio|dei|theology|german chancellor|angela|equally|important|relat|ions|people|actively|politik|und|zeitgeschichte|temporary|materials|sine|qua|non|entries|authored|specific|causal|mechanisms|different|theoretical|approaches|errors|clustered|middle east are|refugee camps are|van|der|brug|power relations are|natural|language|processing|wiley|periodicals|llc|positively|associated|are positively associated|ion|those|left|behind|wrongful|conviction|cases|morning|unmanned|aerial|vehicles|torres|strait|islander|aus|politik|und|domestic workers are|amos|yong|regent|migration flows are|bates|based|upon|are based upon|great|leap|forward|particularly|important|are particularly important|religious|right|shaped|san|suu|kyi|gni|control|variables|control variables are|morb|mortal|wkly|developing countries are|closely|related|are closely related|ethnic groups are|against|relief|tijdschrift voor economische|syrian refugees are|rio|grande|valley|pay|particular|attention|needs|occupy|decisions|made|decisions are made|empirical|evidence|suggests|newly|elected|mps|newly elected mps|best|understood|are best understood|intellectual|property|intellectual property rights|both|books|both books are|logistic|regression|models|goes|far|beyond|european countries are|becoming|increasingly|are becoming increasingly|chapters|well|chapters are well|sons|ltd|medieval|determination|hematopoietic|factors|these|these factors are|significant|statistically|statistically significant difference|early childhood education|migrant workers are|former prime|minister|additional|supporting information|occup|environ|med|beings|human beings are|create|derivative|young people are|agents|negative|attitudes|toward|these|issues|these issues are|united nations general|girls|market|studies|published|attitudes|these|questions|these questions are|its|its member states|member states are|intimate|nineteenth|century|late|early|publishing|ltd|united states are|free|trade|asylum seekers are|human rights are|common|market|studies|abstracts|including|accuracy|science|royal|anthropological|institute|there|had|been|movement|they|able|abuses|had|already|been|divided|into|four|structural|equation|modeling|social|media|platforms|foreign|direct|investment|denotes|aasld|presidential|poster|they|had|been|creative|commons|attribution|out|carried|was|violations|contemporary|copyright|hybrid|reflect|exclusively|under|distributed|journal|book|responsible|authors|reviews|parties|third|allows|yes|money|off|the|for|not|united nations high|nations high commissioner|services|marketing|supply|chain|volume|that|limited|the|than|our|ties|contain|locus|explain|mutual|for|from|any|funding|also|not|make|you|recoil|came|half|with|united nations high|nations high commissioner|services|marketing|supply|chain|volume|that|a|and|is|to|of|in|it|on|as|at|by|an|be|this|which|or|one|two|three|more|many|some|most|several|each|either|neither|own|has|have|do|does|did|about|over|between|through|during|after|before|since|until|among|within|without|because|while|where|whose|can|cannot|will|would|should|could|may|might|must|shall|just|all|very|such|much|so|only|even|same|other|another|further|least|less|few|first|second|next|last|before|after|again|still|always|never|now|then|when|where|why|how|what|who|whom|whose|but|or|nor|yet|though|although|despite|however|moreover|therefore|thus|meanwhile|consequently|otherwise|whether|via|because|due to|based on|related to|associated with|depending on|independent of)\b'
);

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(the|his|brother|allowed|often|fame|lived|their|new|easily|meets|textual|manifold|available|used|were|new|easily|meets|textual|manifold|available|used|were|take|its|away|are|than|our|ties|contain|locus|explain|mutual|for|from|any|funding|also|not|make|you|recoil|came|half|with|united nations high|nations high commissioner|services|marketing|supply|chain|volume|that|a|and|is|to|of|in|it|on|as|at|by|an|be|this|which|or|one|two|three|more|many|some|most|several|each|either|neither|own|has|have|do|does|did|about|over|between|through|during|after|before|since|until|among|within|without|because|while|where|whose|can|cannot|will|would|should|could|may|might|must|shall|just|all|very|such|much|so|only|even|same|other|another|further|least|less|few|first|second|next|last|before|after|again|still|always|never|now|then|when|where|why|how|what|who|whom|whose|but|or|nor|yet|though|although|despite|however|moreover|therefore|thus|meanwhile|consequently|otherwise|whether|via|because|due to|based on|related to|associated with|depending on|independent of)\b'
);

