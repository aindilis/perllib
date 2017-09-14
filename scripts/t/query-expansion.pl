#!/usr/bin/perl -w

use Capability::QueryExpansion;

use Data::Dumper;

while ($query = <STDIN>) {
  print Dumper(QueryExpansion(Query => $query));
}
