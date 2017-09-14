#!/usr/bin/perl -w

use Data::Dumper;

use URI::Escape;

my $string = '404 ProxyServlet%3A+%2Fservices%2FTextAnalyticsService';

print uri_unescape($string);

