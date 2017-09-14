package System::Shalmaneser;

use PerlLib::Lingua::Util;

use Data::Dumper;
use File::Slurp;
use IO::File;
use Lingua::EN::Sentence qw(get_sentences);
use String::ShellQuote;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;

}

sub StartServer {
  my ($self,%args) = @_;
}

sub StopServer {
  my ($self,%args) = @_;
}

sub RestartServer {
  my ($self,%args) = @_;
}

sub ApplyShalmaneserToText {
  my ($self,%args) = @_;
  # get the sentences
  my $sentences = GetSentences(Text => $args{Text});
  print Dumper($sentences);
  my $fh = IO::File->new;
  my $inputfile = "/tmp/shal.input";
  my $outputfile = "/tmp/shal.output";
  my $quotedinputfile = shell_quote($inputfile);
  my $quotedoutputfile = shell_quote($outputfile);
  if ($fh->open(">$inputfile")) {
    print $fh join("\n",@$sentences);
    my $command = "cd /var/lib/myfrdcsa/sandbox/shalmaneser-1.1.160307/shalmaneser-1.1.160307/shal_1.1_160307/shalmaneser1.1/program/ && ".
      "./shalmaneser.sh -i $quotedinputfile -o $quotedoutputfile -l en -p collins";
    print $command;
    system $command;
    $fh->close;
    my $result = read_file($outputfile);
    return {
	    Success => 1,
	    Result => $result,
	   };
  }
  return {
	  Success => 0,
	 };
}

1;
