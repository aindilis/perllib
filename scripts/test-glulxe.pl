#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;
use System::Inform7::GLULXE;

my $ulx = System::Inform7::GLULXE->new();

my $init = $ulx->Start
  (
   ULXFile =>
   '/var/lib/myfrdcsa/codebases/minor/normal-form/inform7/Normal-Form/Normal Form.inform/Build/output.ulx',
  );
print Dumper($init);

sub Execute {
  my ($cmd) = @_;
  print Dumper
    ({
      Command => $cmd,
      Result => $ulx->IssueCommand(Command => $cmd)->{Result},
     });
}

# Execute("showme");
# Execute("x computer desk");

while(my $it = <STDIN>) {
  chomp $it;
  Execute($it);
}

