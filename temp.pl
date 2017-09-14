#!/usr/bin/perl -w

use File::Which 'which';

print which('tesseract')."\n";
