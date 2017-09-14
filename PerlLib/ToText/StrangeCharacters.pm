package PerlLib::ToText::StrangeCharacters;

use PerlLib::SwissArmyKnife;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw (from_strange_characters list_strange_characters);
# to_strange_characters

# to add more items here, see list_strange_characters

our $debug = 0;
my $strangecharacters =
  {
   'ﬁ' => 'fi',
   '–' => '-',
   '’' => '\'',
   '•' => '+',
   '‘' => '\'',
   '”' => '"',
   '“' => '"',
   'ﬂ' => 'fl',
   '´' => '\'',
   '∞' => 'inf',
   '' => '(c)',
   '−' => '-',
   '→' => '->',
   '¨' => '"',
   '' => 'TM',
   '…' => '...',
   '∼' => '~',
   '»' => '>>',
   'ß' => 'ss',
   '′' => '\'',
   '‘ﬁ' => '\'fi',
   '×' => 'x',
   '«' => '<<',
   '˜' => '~',
   'ﬀ' => 'ff',
   'ﬃ' => 'ffi',
  };

sub from_strange_characters {
  my (%args) = @_;
  print Dumper($strangecharacters) if $debug;
  foreach my $key (keys %$strangecharacters) {
    my $value = $strangecharacters->{$key};
    if ($debug) {
      print $key."\n";
      print "\t".$args{Text}."\n";
    }
    $args{Text} =~ s/($key)/$value/sg;
    if ($debug) {
      print "\t".$args{Text}."\n";
    }
  }
  return {
	  Text => $args{Text},
	 };
}

# sub to_strange_characters {
#   my (%args) = @_;
#   foreach my $key (keys %$strangecharacters) {
#     my $value = $strangecharacters->{$key};
#     my $regex = join ("", map {"\\".$_} split //, $value);
#     $args{Text} =~ s/($regex)/$key/sg;
#   }
#   return {
# 	  Text => $args{Text},
# 	 };
# }

sub list_strange_characters {
  my (%args) = @_;

  my $text = $args{Text};
  my @matches = $text =~ /([^[:ascii:]]+)/sg;
  my $seen = {};
  foreach (@matches) {
    $seen->{$_}++;
  }
  if ($debug) {
    foreach my $key (sort {$seen->{$b} <=> $seen->{$a}} keys %$seen) {
      print "'".$key."' => '',\n";
    }
  }
}

1;
