#!/usr/bin/perl -w

use KBS2::Util;

use KBS2::ImportExport;

use PerlLib::SwissArmyKnife;

my $datastructure = DeDumperFile('/var/lib/myfrdcsa/codebases/internal/perllib/scripts/convert-perl-data-to-prolog/barcode.dat');

my $res1 = PerlDataStructureToStringEmacs
  (
   DataStructure => $datastructure,
  );
print Dumper({Res1 => $res1});

my $importexport = KBS2::ImportExport->new();
my $res2 = $importexport->Convert
  (
   Input => $res1,
   InputType => 'Emacs String',
   OutputType => 'Prolog',
  );
print Dumper({Res2 => $res2});

if ($res2->{Success}) {
  my $res3 = $importexport->Convert
    (
     Input => $res2->{Output},
     InputType => 'Prolog',
     OutputType => 'Interlingua',
    );
  print Dumper({Res3 => $res3});
}
