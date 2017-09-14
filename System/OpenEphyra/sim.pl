#!/usr/bin/perl -w

my $initstring = '+++++ Initializing engine (2008-06-23 04:29:51) +++++
Creating tokenizer...
Creating sentence detector...
Creating stemmer...
Creating POS tagger...
Creating chunker...
Creating syntactic parser...
Creating NE taggers...
  ...loading lists
    ...for NEacademicTitle
    ...for NEactor
    ...for NEairport
    ...for NEanimal
    ...for NEanthem
    ...for NEauthor
    ...for NEaward
    ...for NEbacteria
    ...for NEbird
    ...for NEbirthstone
    ...for NEbodyPart
    ...for NEbook
    ...for NEcanal
    ...for NEcapital
    ...for NEcauseOfDeath
    ...for NEchemicalElement
    ...for NEcolor
    ...for NEcompetition
    ...for NEconflict
    ...for NEcontinent
    ...for NEcountry
    ...for NEcrime
    ...for NEcurrency
    ...for NEdaytime
    ...for NEdirector
    ...for NEdisease
    ...for NEdrug
    ...for NEeducationalInstitution
    ...for NEethnicGroup
    ...for NEfestival
    ...for NEfilm
    ...for NEfilmType
    ...for NEfirstName
    ...for NEflower
    ...for NEfruit
    ...for NEhemisphere
    ...for NEhour
    ...for NEisland
    ...for NElake
    ...for NElanguage
    ...for NEmaterial
    ...for NEmathematician
    ...for NEmedicalTreatment
    ...for NEmedicinal
    ...for NEmetal
    ...for NEmilitaryRank
    ...for NEmineral
    ...for NEministry
    ...for NEmonth
    ...for NEmountain
    ...for NEmountainRange
    ...for NEmusicType
    ...for NEmusical
    ...for NEmusicalInstrument
    ...for NEnarcotic
    ...for NEnationalPark
    ...for NEnationality
    ...for NEnewspaper
    ...for NEnobleTitle
    ...for NEocean
    ...for NEopera
    ...for NEorganization
    ...for NEpathogen
    ...for NEpeninsula
    ...for NEplanet
    ...for NEplant
    ...for NEplaywright
    ...for NEpoliceRank
    ...for NEpoliticalParty
    ...for NEprofession
    ...for NEprovince
    ...for NEradioStation
    ...for NErelation
    ...for NEreligion
    ...for NEriver
    ...for NEscientist
    ...for NEsea
    ...for NEseason
    ...for NEshow
    ...for NEshowType
    ...for NEsocialTitle
    ...for NEsport
    ...for NEstadium
    ...for NEstate
    ...for NEstone
    ...for NEstyle
    ...for NEteam
    ...for NEtherapy
    ...for NEtimezone
    ...for NEtvChannel
    ...for NEusPresident
    ...for NEvaccine
    ...for NEvirus
    ...for NEwater
    ...for NEzodiacSign
  ...loading patterns
    ...for NEproperName
    ...for NEacronym
    ...for NEangle
    ...for NEarea
    ...for NEcentury
    ...for NEcounty
    ...for NEdate
    ...for NEday
    ...for NEdayMonth
    ...for NEdays
    ...for NEdecade
    ...for NEduration
    ...for NEeducationalInstitution
    ...for NEfeet
    ...for NEfrequency
    ...for NEgallons
    ...for NEgrams
    ...for NElegalSentence
    ...for NElength
    ...for NEliters
    ...for NEmiles
    ...for NEmoney
    ...for NEmph
    ...for NEnumber
    ...for NEordinal
    ...for NEounces
    ...for NEpercentage
    ...for NEphoneNumber
    ...for NEpounds
    ...for NErange
    ...for NErate
    ...for NEreef
    ...for NEscore
    ...for NEsize
    ...for NEspeed
    ...for NEsquareMiles
    ...for NEstreet
    ...for NEtemperature
    ...for NEtime
    ...for NEtons
    ...for NEurl
    ...for NEvolume
    ...for NEweekday
    ...for NEweight
    ...for NEyear
    ...for NEyears
    ...for NEzipcode
  ...loading models
  ...done
Creating WordNet dictionary...
Loading function verbs...
Loading prepositions...
Loading irregular verbs...
Loading word frequencies...
Loading query reformulators...
Loading question patterns...
Loading answer patterns...
  ...for ABBREVIATION
  ...for ACTOR
  ...for AGE
  ...for ANCESTOR
  ...for AUTHOR
  ...for AWARD
  ...for CAPITAL
  ...for CAUSE
  ...for CAUSEOFDEATH
  ...for COACH
  ...for COMPETITOR
  ...for CREATOR
  ...for DATE
  ...for DATEOFBIRTH
  ...for DATEOFCREATION
  ...for DATEOFDEATH
  ...for DATEOFDISCOVERY
  ...for DATEOFEND
  ...for DATEOFFOUNDATION
  ...for DATEOFINAUGURATION
  ...for DATEOFINVENTION
  ...for DATEOFLIVING
  ...for DATEOFMARRIAGE
  ...for DATEOFRETIREMENT
  ...for DATEOFSTART
  ...for DATEOFSTARTOFOPERATION
  ...for DATEOFWINNING
  ...for DEFINITION
  ...for DISCOVERER
  ...for DISCOVERY
  ...for DISTANCE
  ...for DURATION
  ...for ETHNICGROUP
  ...for FATHER
  ...for FOOD
  ...for FOUNDATION
  ...for FOUNDER
  ...for FUNCTION
  ...for FUNDER
  ...for FUNDING
  ...for GRADUATE
  ...for HABITAT
  ...for HEIGHT
  ...for IDENTITY
  ...for INSTRUMENT
  ...for INVENTOR
  ...for KILLER
  ...for LANGUAGE
  ...for LEADER
  ...for LEADERSHIP
  ...for LENGTH
  ...for LIFESPAN
  ...for LONGFORM
  ...for MEDICINE
  ...for MEMBER
  ...for MEMBERSHIP
  ...for MONEY
  ...for MOTHER
  ...for MOVIE
  ...for NAME
  ...for NAMER
  ...for NATIONALITY
  ...for NUMBER
  ...for NUMBEROFCHILDREN
  ...for NUMBEROFMEMBER
  ...for NUMBEROFVICTIMS
  ...for NUMBEROFVICTORIES
  ...for NUMBEROFVISITORS
  ...for OPPONENT
  ...for ORIGIN
  ...for OWNER
  ...for PLACE
  ...for PLACEOFBIRTH
  ...for PLACEOFDEATH
  ...for PLACEOFFOUNDATION
  ...for PLACEOFFUNERAL
  ...for PLACEOFLIVING
  ...for PLACEOFOCCURRENCE
  ...for PLACEOFORIGIN
  ...for POPULATION
  ...for PRODUCT
  ...for PROFESSION
  ...for PROVIDER
  ...for PUBLICATION
  ...for RESOURCE
  ...for SCHOOL
  ...for SIZE
  ...for SPECIALTY
  ...for SPECIES
  ...for SPEED
  ...for SPOUSE
  ...for SYMPTOM
  ...for SYNONYM
  ...for VALUE
  ...for WEIGHT
  ...for WIDTH
  ...for WINNER
  ...done
';

my $prompt = 'Question: ';

my $result = '+++++ Analyzing question (2008-06-23 04:31:11) +++++
Normalization: who kill kennedy

Answer types:
NEproperName->NEperson

Interpretations:
Property: KILLER
Target: Kennedy

Predicates:
-

+++++ Generating queries (2008-06-23 04:31:21) +++++
Query strings:
killed Kennedy
killed (Kennedy OR "John Fitzgerald Kennedy" OR JFK OR "President Kennedy" OR "Jack Kennedy" OR "President John F. Kennedy")
"Kennedy" killed Kennedy
"killed Kennedy"

+++++ Searching (2008-06-23 04:31:21) +++++

+++++ Selecting Answers (2008-06-23 04:31:24) +++++
Filter "AnswerTypeFilter" started, 353 Results (2008-06-23 04:31:24)
Filter "AnswerTypeFilter" finished, 464 Results (2008-06-23 04:31:31)
Filter "AnswerPatternFilter" started, 464 Results (2008-06-23 04:31:31)
Filter "AnswerPatternFilter" finished, 690 Results (2008-06-23 04:31:42)
Filter "WebDocumentFetcherFilter" started, 690 Results (2008-06-23 04:31:42)
Filter "WebDocumentFetcherFilter" finished, 690 Results (2008-06-23 04:31:42)
Filter "PredicateExtractionFilter" started, 690 Results (2008-06-23 04:31:42)
Filter "PredicateExtractionFilter" finished, 690 Results (2008-06-23 04:31:42)
Filter "FactoidsFromPredicatesFilter" started, 690 Results (2008-06-23 04:31:42)
Filter "FactoidsFromPredicatesFilter" finished, 690 Results (2008-06-23 04:31:42)
Filter "TruncationFilter" started, 690 Results (2008-06-23 04:31:42)
Filter "TruncationFilter" finished, 658 Results (2008-06-23 04:31:42)
Filter "StopwordFilter" started, 658 Results (2008-06-23 04:31:42)
Filter "StopwordFilter" finished, 616 Results (2008-06-23 04:31:42)
Filter "QuestionKeywordsFilter" started, 616 Results (2008-06-23 04:31:42)
Filter "QuestionKeywordsFilter" finished, 574 Results (2008-06-23 04:31:42)
Filter "ScoreNormalizationFilter" started, 574 Results (2008-06-23 04:31:42)
Filter "ScoreNormalizationFilter" finished, 574 Results (2008-06-23 04:31:42)
Filter "ScoreCombinationFilter" started, 574 Results (2008-06-23 04:31:42)
Filter "ScoreCombinationFilter" finished, 553 Results (2008-06-23 04:31:43)
Filter "FactoidSubsetFilter" started, 553 Results (2008-06-23 04:31:43)
Filter "FactoidSubsetFilter" finished, 553 Results (2008-06-23 04:31:44)
Filter "DuplicateFilter" started, 553 Results (2008-06-23 04:31:44)
Filter "DuplicateFilter" finished, 477 Results (2008-06-23 04:31:45)
Filter "ScoreSorterFilter" started, 477 Results (2008-06-23 04:31:45)
Filter "ScoreSorterFilter" finished, 477 Results (2008-06-23 04:31:45)

Answer:
[1]	John F
	Score: 1.195956
	Document: http://en.wikipedia.org/wiki/John_F._Kennedy_assassination
';

print $initstring."\n";
while (1) {
	print $prompt;
	my $question = <STDIN>;
	print $result."\n";
}
