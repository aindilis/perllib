#!/usr/bin/perl -w

use System::EasyCCG;

use PerlLib::SwissArmyKnife;

#!/usr/bin/perl -w

use BOSS::Config;
use PerlLib::SwissArmyKnife;

$specification = q(
	-f <file>		File to parse.
	-t <text>		Text to parse.
);

my $config =
  BOSS::Config->new
  (Spec => $specification);
my $conf = $config->CLIConfig;
# $UNIVERSAL::systemdir = "/var/lib/myfrdcsa/codebases/minor/system";

my $easyccg = System::EasyCCG->new;
$easyccg->StartServer();

my $file = "/var/lib/myfrdcsa/codebases/internal/perllib/scripts/t/aioverview.txt";
my $c = '';
if ($conf->{'-f'} and -f $conf->{'-f'}) {
  $file = $conf->{'-f'};
  $c .= read_file($file)."\n";
}
if ($conf->{'-t'}) {
  $c .= $conf->{'-t'};
}

print Dumper($easyccg->GetCCG(Text => $c, N => 10));
