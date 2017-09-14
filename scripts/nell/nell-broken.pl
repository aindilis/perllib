#!/usr/bin/perl -w

use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;

use Text::CSV;

# okay put this into a prolog function

my $importexport = KBS2::ImportExport->new();

my @rows;
my $csv = Text::CSV->new ( { binary => 1 } ) # should set binary attribute.
  or die "Cannot use CSV: ".Text::CSV->error_diag ();
open my $fh, "<:encoding(utf8)", "test.csv" or die "test.csv: $!";
my $titlerow;
while ( my $row = $csv->getline( $fh ) ) {
  if (! defined $titlerow) {
    $titlerow = $row;
  } else {
    my $res1 = PerlDataDedumperToStringEmacs(String => $row);
    my $res2 = $importexport->Convert(InputType => "Emacs String", OutputType => "Prolog", Input => $res1);
    print Dumper($res2);
    push @rows, $res2;
  }
}
$csv->eof or $csv->error_diag();
close $fh;



