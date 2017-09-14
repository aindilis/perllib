#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

print read_file
  (WriteToTempFile
   (
    Pattern => '/tmp/perllib-test-XXXXXXXX',
    Contents => 'hi',
   ))."\n";
