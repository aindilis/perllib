#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use PerlLib::ServerManager::UniLang::Client;



# a few issues, need to make the allresults variable reset between
# invocations, or something, as it's giving too many results.

# also need it to be able to succeed on the second input, and not just
# return whatever it got on the very first input

# use System::FactualStatementExtractor;

# $UNIVERSAL::factualstatementextractor = System::FactualStatementExtractor->new;

$UNIVERSAL::factualstatementextractor = PerlLib::ServerManager::UniLang::Client->new
  (
   AgentName => "Org-FRDCSA-System-FactualStatementExtractor",
  );

# my @res = $UNIVERSAL::factualstatementextractor->FactualStatementExtractor
#   (
#    Text => "Prime Minister Vladimir V. Putin, the country's paramount leader, cut short a trip to Siberia, ".
#    "returning to Moscow to oversee the federal response. Mr. Putin built his reputation in part on his ".
#    "success at suppressing terrorism, so the attacks could be considered a challenge to his stature.",
#   );


while (1) {
  my $input = QueryUser("Input?");
  my @res = $UNIVERSAL::factualstatementextractor->FactualStatementExtractor
    (
     Text => $input,
    );
  print Dumper(\@res);
}
