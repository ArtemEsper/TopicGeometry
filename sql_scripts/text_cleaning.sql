-- Update `nations` to `national`, `traffi cking` to `trafficking`, `internat ional` to `international`, and `polit ical` to `political` in the int_bi table
UPDATE `clarivate-datapipline-project.jstor_international.int_bi`
SET ngram = REGEXP_REPLACE(
    ngram,
    r'(?i)\b(nations|traffi cking|internat ional|polit ical)\b',
    CASE
        WHEN REGEXP_CONTAINS(ngram, r'(?i)nations') THEN 'national'
        WHEN REGEXP_CONTAINS(ngram, r'(?i)traffi cking') THEN 'trafficking'
        WHEN REGEXP_CONTAINS(ngram, r'(?i)internat ional') THEN 'international'
        WHEN REGEXP_CONTAINS(ngram, r'(?i)polit ical') THEN 'political'
    END
)
WHERE REGEXP_CONTAINS(ngram, r'(?i)\b(nations|traffi cking|internat ional|polit ical)\b');

-- Update `nations` to `national`, `traffi cking` to `trafficking`, `internat ional` to `international`, and `polit ical` to `political` in the int_tri table
UPDATE `clarivate-datapipline-project.jstor_international.int_tri`
SET ngram = REGEXP_REPLACE(
    ngram,
    r'(?i)\b(nations|traffi cking|internat ional|polit ical)\b',
    CASE
        WHEN REGEXP_CONTAINS(ngram, r'(?i)nations') THEN 'national'
        WHEN REGEXP_CONTAINS(ngram, r'(?i)traffi cking') THEN 'trafficking'
        WHEN REGEXP_CONTAINS(ngram, r'(?i)internat ional') THEN 'international'
        WHEN REGEXP_CONTAINS(ngram, r'(?i)polit ical') THEN 'political'
    END
)
WHERE REGEXP_CONTAINS(ngram, r'(?i)\b(nations|traffi cking|internat ional|polit ical)\b');

DELETE
FROM `clarivate-datapipline-project.jstor_international.int_tri`
WHERE REGEXP_CONTAINS(
  ngram,
  r'(?i)\b(undocumented migrants are|eastern europe are|smart|street|light|asian americans are|maximum|likelihood|estimation|norsk|statsvitenskapelig|tidsskrift|ireneusz|pawel|karolewski|bmc|emerg infect dis|presented here are|international relations are|asian countries are|migration policies are|primarily|concerned|xinjiang|uyghur|autonomous|mit|sloan|management|border crossers are|holy|roman|empire|expert|mit|blick|auf|cox|proportional|hazards|immigration policies are|are good reasons|public policies are|inside networks are|undocumented immigrants are|att|clin|infect|dis|tel|kin|helped|ferry|eastern americans are|currently|being|literature|readers|involved|actors|makes|emerald|whilst|every|makes|online|likely|rural areas|held|accountable|issued|copying|competitive elections are|philosopher|press|included|sudden|changes|way|towards|restoring|receive|repeated|calls|tribal|art|alone|dreams|crushed|implicit|threads|almost|entirely|elude|himself|recorded|various|implicit|threads|provides|rare|ethnographic|largest|archaeological|sites|Salvador|brings|together|measurements|across|different|metal|homes|along|contexts|highlights|parte|del|cambio|them|knew|personally|evolving|local|meanings|fieldwork|took|different|faith|traditions|represented|una|esperanza|que|vary|widely|depending|arrived|back|daily|amplia|para|decir|prides|itself|vary|widely|spending|actor|costs|Isolate|play|Expeditionary|partner|designated|collections|budgetary|single|induced|pratiques|Des|PPP|par|approches|infrastructures|primaires|doivent|transfert|eff|ectif|pratiques|depuis|les|approches|institutionnalistes|des|changements|signifi|vue|des|valeurs|potable|des|terrains|acteurs|aux|logiques|plus|importants|que|par|les|associations|important|reminders|seemingly|massive|together|weaves|artfully|privileged|left|accept|fully|continuously|compromising|going|around|successful|small|reaching|becomes|themselves|san|along|situated|limit|interests|overall|francisco|bay|see|supra|notes|natl|acad|sci|extreme|weather|events|border policies are|herefordshire|cain|particularly vulnerable|highly dependent|upon|per|cent|boehme|trinity|lutheran|missio|dei|theology|german chancellor|angela|equally|important|relat|ions|people|actively|politik|und|zeitgeschichte|temporary|materials|sine|qua|non|entries|authored|specific|causal|mechanisms|different|theoretical|approaches|errors|clustered|middle east are|refugee camps are|van|der|brug|power relations are|natural|language|processing|wiley|periodicals|llc|positively|associated|are positively associated|ion|those|left|behind|wrongful|conviction|cases|morning|unmanned|aerial|vehicles|torres|strait|islander|aus|politik|und|domestic workers are|amos|yong|regent|migration flows are|bates|based|upon|are based upon|great|leap|forward|particularly|important|are particularly important|religious|right|shaped|san|suu|kyi|gni|control|variables|control variables are|morb|mortal|wkly|developing countries are|closely|related|are closely related|ethnic groups are|against|relief|tijdschrift voor economische|syrian refugees are|rio|grande|valley|pay|particular|attention|needs|occupy|decisions|made|decisions are made|empirical|evidence|suggests|newly|elected|mps|newly elected mps|best|understood|are best understood|intellectual|property|intellectual property rights|both|books|both books are|logistic|regression|models|goes|far|beyond|european countries are|becoming|increasingly|are becoming increasingly|chapters|well|chapters are well|sons|ltd|medieval|determination|hematopoietic|factors|these|these factors are|significant|statistically|statistically significant difference|early childhood education|migrant workers are|former prime|minister|additional|supporting information|occup|environ|med|beings|human beings are|create|derivative|young people are|agents|negative|attitudes|toward|these|issues|these issues are|united nations general|girls|market|studies|published|attitudes|these|questions|these questions are|its|its member states|member states are|intimate|nineteenth|century|late|early|publishing|ltd|united states are|free|trade|asylum seekers are|human rights are|common|market|studies|abstracts|including|accuracy|science|royal|anthropological|institute|there|had|been|movement|they|able|abuses|had|already|been|divided|into|four|structural|equation|modeling|social|media|platforms|foreign|direct|investment|denotes|aasld|presidential|poster|they|had|been|creative|commons|attribution|out|carried|was|violations|contemporary|copyright|hybrid|reflect|exclusively|under|distributed|journal|book|responsible|authors|reviews|parties|third|allows|yes|money|off|the|for|not|united nations high|nations high commissioner|services|marketing|supply|chain|volume|that|limited|the|than|our|ties|contain|locus|explain|mutual|for|from|any|funding|also|not|make|you|recoil|came|half|with|united nations high|nations high commissioner|services|marketing|supply|chain|volume|that|a|and|is|to|of|in|it|on|as|at|by|an|be|this|which|or|one|two|three|more|many|some|most|several|each|either|neither|own|has|have|do|does|did|about|over|between|through|during|after|before|since|until|among|within|without|because|while|where|whose|can|cannot|will|would|should|could|may|might|must|shall|just|all|very|such|much|so|only|even|same|other|another|further|least|less|few|first|second|next|last|before|after|again|still|always|never|now|then|when|where|why|how|what|who|whom|whose|but|or|nor|yet|though|although|despite|however|moreover|therefore|thus|meanwhile|consequently|otherwise|whether|via|because|due to|based on|related to|associated with|depending on|independent of)\b'
);

SELECT distinct LOWER(ngram) as ngram,
                sum(count) as sumcount
FROM `clarivate-datapipline-project.jstor_international.int_tri`
group by ngram
order by sumcount desc;
