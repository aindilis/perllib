#!/usr/bin/perl -w

use PerlLib::MySQL;
use PerlLib::SwissArmyKnife;

# my $mysql1 = PerlLib::MySQL->new
#   (
#    DBName => "test",
#   );
# print Dumper($mysql1->Do(Statement => "show tables"));

my $mysql2 = PerlLib::MySQL->new
  (
   DBName => "test",
   Host => "192.168.1.200",
   Username => "root",
   Password => "<REDACTED>",
  );
print Dumper($mysql2->Do(Statement => "show tables"));

# my $mysql3 = PerlLib::MySQL->new
#   (DBName => "test");
# print Dumper($mysql3->Do(Statement => "show tables"));
