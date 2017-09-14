package PerlLib::NLP;

# the most complete known NLP library

# given an object what can we do with it or transform it to

# aspects of functions


my $c = [
	 Text => {
		  ""
		 },
	 QuestionAnswering => {
			       "",
			      },
	 Extraction => {
			"Named Entities",
			"N-Grams",
			"Rhymes",
			"",
		       },
	 Phrase => {
		    "Dictionary Lookup",
		    "Encyclopedia Lookup",
		    "Wordnet Lookup",
		    "Rhyming",
		    "Connotations",
		    "Associations",
		   },
	 Question => {
		     },
	];

my $capabilities =
  {
   "Question Answering" => {
			    "TextMine" => [qw(QuestionP ClassifyQuestionType AnswerQuestion)],
			   },
   "NamedEntityExtraction" => {},
   "Topic Detection and Tracking" => {},
   "LanguageModelling" => {},
   "AffectiveClassification" => {
				 "Conceptnet" => [],
				}

   "English Predicate Parser" => {
				 },
   "Formalization" => {},
   

