#!/usr/bin/perl -w

use PerlLib::Util;

use Data::Dumper;

print Dumper
  (PidsForProcess
   (Process => "/usr/bin/mysql"));
