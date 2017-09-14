#!/usr/bin/perl -w

use System::Liferea;

my $lr = System::Liferea->new();

$lr->LoadFeeds;
