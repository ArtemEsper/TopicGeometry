-- Consolidated Clean-Up Query for trigram Table in BigQuery

-- Stage 1 Create a copy of a table for cleaning
CREATE OR REPLACE TABLE `clarivate-datapipline-project.lg_jstor.trigrams_cleaned` AS
SELECT * FROM `clarivate-datapipline-project.lg_jstor.trigrams_deduplicated`;

-- Stage 2 Delete the rare trigrams
DELETE FROM `clarivate-datapipline-project.lg_jstor.trigrams_cleaned`
WHERE LOWER(ngram) IN (
    SELECT ngram
    FROM (
        SELECT LOWER(ngram) AS ngram,
               SUM(count) AS sumcount
        FROM `clarivate-datapipline-project.lg_jstor.trigrams_cleaned`
        GROUP BY ngram
        HAVING SUM(count) < 20
    )
);


DELETE FROM `clarivate-datapipline-project.lg_jstor.trigrams_cleaned`
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

DELETE FROM `clarivate-datapipline-project.lg_jstor.trigrams_cleaned`
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

DELETE FROM `clarivate-datapipline-project.lg_jstor.trigrams_cleaned`
WHERE
  REGEXP_CONTAINS(ngram, r'(?i)\b(the|than|our|ties|contain|for|from|a|and|is|to|of|if|in|it|on|as|at|by|an|be|or|one|two|three|more|most|several|each|either|neither|his|her|their|this|which|has|have|do|does|did|publication|research|survey|study|data|analysis|results|findings|figure|table|chart|statistics|percent|years|months|days|hours|times|rate|increase|decrease|variable|sample|mean|average|summary|conclusion|system|goal|objective|criteria|parameter|procedure|formula|concept|model|framework|evaluation|testing|validation|example|illustration|case|factor|context|background|approach|strategy|project|initiative|organization|institution|entity|company|firm|business|enterprise|agency|office|department|division|team|task|role|position|occupation|field|category|classification|type|class|kind|sort|group|subset|section|part|unit|element|connection|association|relationship|bond|tie|partnership|collaboration|cooperation|interaction|communication|dialogue|exchange|discussion|agreement|alliance|support|benefit|asset|resource|opportunity|potential|possibility|value|importance|significance|worth|meaning|purpose|insight|understanding|awareness|knowledge|perception|recognition|sensitivity|about|over|between|through|during|after|before|since|until|now|then|when|always|never|today|tomorrow|yesterday|hour|minute|second|day|week|month|year|while|where|whose|can|cannot|will|would|should|could|may|might|must|shall|just|all|very|such|much|so|only|even|same|other|another|further|least|less|few|but|nor|yet|though|although|despite|however|moreover|therefore|thus|meanwhile|consequently|otherwise|because|due|no|john wiley|online|books|that|there|are|they|were|not|yes|x|we|find|that|had|who|many|po|liti|cal|been|review|sons|ltd|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|en|ti|journal|compilation|taking|into|account|full|text|archive|with|positively|associated|was|od|el|factors|©|et al. /|attribution|new|gdp|per|open|access|article|lth|ca|re|ea|lth|ca|publishing|blackwell|ef|fe|ct|quarterly|va|ri|ab|le|ar|ia|bl|equation|modeling|its|supply|total|nber|late|information|supporting|additional|history|see|supra|note|robert|wood|johnson|high|low|better|understand|how|you|know|what|also|out|pointed|nhs|trust|body|mass|older|among|imf|working|paper|good|shed|some|light|united nations general|use|disorders|disoders|bay|drug|forum|disorder|web|world|sloan|under|take|place|within|non|sine|qua|took|make|help|explain|why|quid|pro|quo|ann|intern|med|sigma|theta|tau|built|vol|rapid|prod|growth|innov|manag|index|along|these|lines|pay|close|attention|interviews|informant|key|morb|mortal|wkly|zero|lower|bound|medicine|gen|intern|she|said|she|higher|percentage|points|top|audit|mmwr|planning|these|answer|questions|staff|page|any|given|time|closed|doors|behind|chi|minh|suggest|studies|quality|any|form|without|maximum|likelihood|estimation|patients|patient|ill|terminally|aung|san|suu|volume|occup|environ|upper|theory|ratio|test|assoc|raises|important|questions|meeting|first|step|important|long|range|planning|get|things|done|excel|organizat|ional|russell|sage|almost|exclusively|version|using|spss|generally|accepted|accounting|applied|behavioral|birth|traditional|pain|symptom|well|goes|beyond|five|personality|infant|mortality|normed|fit|done|work|being|air|ibm|often|found|themselves|internet|imposed|upon|them|nursing|ols|exp|alcohol|clin|pushed|back|against|every|random|sampling|technique|estados|unidos|los|newly|pty|qsr|line|item|veto|order|entry|aan|den|alphen|esg|zur|beitrag|pdf|proof|sunday|once|again|become|rapidly|changing|turning|point|down|york university law|across|herald|ownership|stock|provide|strong|evidence|processing|language|natural|toxic|substances|exclusive|brain|injury|traumatic|control|those|bulla|cum|filo|des|gestion|soins|cognitive|denominator|lowest|hosp|viet|nam|ese|meetings|spinal|cord|ter|est|ing|burnout|inventory|maslach|therapy|papers|copy|editor|west south central|psy|chol|ogy|told|inside|epa|alien|tort|claims|auf|dem|weg|stem|cell|proton|pump|inhibitors|made|promoting|oil|living|making|needs|need|training|informed|give|consent|hospital|admission|rates|equal|opportunities|outer|shelf|view|commonly|held|allows|newborn|suggests|wisdom|common|police|offi|cers|postal|obtain|aus|politik|und|con|sul|tants|ruth|bader|ginsburg|alone|deep|vein|thrombosis|final|passage|themes|based|versus|informal|formal|provides|rank|sum|branch|ever|closer|nurse|types|phys|nutr|usa|like|change|paid|lip|signed|your|own|personal|manage|ment|white house central|main|themes|emerged|flood|sstt|ttuu|uudd|ttuu|uudd|ddii|perhaps|best|known|tin|maung|ccp|short|message|jun|jul|aug|sep|oct|nov|dec|jan|feb|mar|apr|may|used|lay|off|neonatal|iii|intensive|united states adopted|adopted|output|estimates|whether|draft|aff|airs|inpatient|mental|assets|old|used|widely|method|lives|matter|movement|black|maternal|vital|signs|overall|question|asked|whether|quick|tips|services|producer|niger|delta|york attorney general|used|qualitative|methods|fast|moving|consumer|fuzzy|set|qualitative|age|assistance|gain|deeper|insights|guiding|badan|pusat|cyan|magenta|yellow|dev|min|max|seems|worked|closely|together|nine|ngok|dinka|former|deputy|minister|waiting|homes|issues|amendment|rural urban rural|makes|intuitive|sense|accounts|sick|building|syndrome|video|game|later|meters|cubic|contra costa county|strategic international human|spent|sporting|lot|size|sci soc sci|proficient|limited|english|systemic|lupus|erythematosus|york economic policy|both|chama|cha|mapinduzi|classifying|improving|chronic|illness|pers|soc|psychol|railroad|urban rural urban|focus|groups|highly|competitive|global|mem|ber|women|attending|antenatal|fastest|growing|segment|human performance technology|international development community|hotel|join|uncertainty|holding|everything|else|illustrates|used|focus|groups|front|end|mixed|uses|outside|georg|thieme|verlag|uni|versity|having|mission|tool|obstet|gynecol|neonatal|positive|negative|ished|onl|ine|column|france|germany|italy|mode|symp|cloud|computing|adoption|stimulus|package|henk|schulte|nordholt|surrogate|sentencing|central bank digital|ieee computer society|include|individual|neck|surgery|sport|balance|amendments|herzegovina icg balkans|balkans|sentinel|event|phi|beta|kappa|draw|conclusions|syntax|aalto university school|internal combustion engine|islamic finance industry|islamic|myopic|loss|aversion|identified|assessing generalized anxiety|united methodist church|national equality bodies|die geschichte der|emission allowance trading|finland|home owners loan|jim crow era|dimensions|organisational citizenship behaviours|small bus econ|econ|saw|adam clayton|powell|alternative energy sources|donatella della porta|emergency operations center|international policy coordination|international trade administration|service operations management|transitional justice process)\b')
OR REGEXP_CONTAINS(ngram, r'\b\w*(aaa|bbb|ccc|ddd|eee|fff|ggg|hhh|iii|jjj|kkk|lll|mmm|nnn|ooo|ppp|qqq|rrr|sss|ttt|uuu|vvv|www|xxx|yyy|zzz)\w*\b');

