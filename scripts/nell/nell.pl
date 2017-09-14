#!/usr/bin/perl -w

use KBS2::ImportExport;
use KBS2::Util;
use PerlLib::SwissArmyKnife;

use Text::CSV;

# okay put this into a prolog function

my $importexport = KBS2::ImportExport->new();

my @rows;
my $c = read_file("test.csv");
my $titlerow;
foreach my $line (split /\n/, $c) {
  my $row = [split /\t/, $line];
  if (! defined $titlerow) {
    $titlerow = $row;
  } else {
    my $res1 = PerlDataDedumperToStringEmacs(String => Dumper($row));
    my $res2 = $importexport->Convert(InputType => "Emacs String", OutputType => "Prolog", Input => $res1);
    print Dumper($res2);
    push @rows, $res2;
  }
}

# See about automatically learning information extraction patterns by
# using databases of strings which are assigned types from a
# hierarchy, in order to develop patterns for extraction from text and
# web documents.

# So basically, we use the type information as features, and use
# information we already know the type for, in order to figure out
# what are likely textual patterns around these types of information.
# Use subsumption.  Then we can apply these learned patterns to
# extracting more individuals of these types.

# Can probably use this to extract information about software from
# websites.  That is probably why I came up with this idea.

# See about using existing NELL software for this.
