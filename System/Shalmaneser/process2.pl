# now go ahead and generate all the outputs
# for each frame
# push @kb, ["suppose", ["and", ["has-sense", $tokenterm, $sense], ["has-part-of-speech", $tokenterm, $pos]]];

# ("has-role" ("entity-refered-to-by" ("token" "I" "20_0")) "Arguer")
# ("has-role" ("entity-refered-to-by" ("token" "get" "20_3")) "Content")


# (frame "Reasoning")

foreach my $frame (keys %$frames) {
    
foreach my $formula (@kb) {
  my $res = $ie->Convert
    (
     Input => [$formula],
     InputType => "Interlingua",
     OutputType => "Emacs String",
    );
  if ($res->{Success}) {
    print $res->{Output}."\n";
  }
}

use KBS2::ImportExport;
use Capability::Tokenize;


  my $ie = KBS2::ImportExport->new;
