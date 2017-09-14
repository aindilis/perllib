package System::OLLIE;

# FIXME: FINISH STUFF IN
# /var/lib/myfrdcsa/codebases/internal/perllib/System/OLLIE/ directory

use Capability::SentenceSplitting;
use Capability::Tokenize;
use PerlLib::SwissArmyKnife;

# Capability::TextAnalysis

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(ProcessText);

sub ProcessText {
  my (%args) = @_;
  my ($f,$filename) = tempfile();
  my $res1 = SplitSentences(Text => $args{Text});
  print $f join("\n",@$res1);
  my $command = 'cd /var/lib/myfrdcsa/sandbox/ollie-20160516/ollie-20160516 && java -Xmx512m -jar ollie-app-latest.jar '.shell_quote($filename);
  my $res = `$command`;
  return {
	  Success => 1,
	  Result => $res,
	 };
}

1;
