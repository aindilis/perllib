#!/usr/bin/perl -w

use PerlLib::SwissArmyKnife;

use HTML::TreeBuilder;
use HTML::PrettyPrinter;

if (0) {
  # generate a HTML syntax tree
  my $tree = new HTML::TreeBuilder;
  $tree->parse_file('/var/lib/myfrdcsa/codebases/minor/auto-builder/scripts/res.html');
  # modify the tree if you want

  my $hpp = new HTML::PrettyPrinter ('linelength' => 130,
				     'quote_attr' => 1);
  # configure
  $tree->address("0.1.0")->attr(_hpp_indent,0);	# for an individual element
  $hpp->set_force_nl(1,qw(body head));		# for tags
  $hpp->set_force_nl(1,qw(@SECTIONS));		# as above
  $hpp->set_nl_inside(0,'default!');		# for all tags

  # format the source
  my $linearray_ref = $hpp->format($tree);
  print @$linearray_ref;

  # # alternative: print directly to filehandle
  # use FileHandle;
  # my $fh = new FileHandel ">$filenaem2";
  # if (defined $fh) {
  #   $hpp->select($fh);
  #   $hpp->format();
  #   undef $fh;
  #   $hpp->select(undef),
  # }
}

my $c = read_file('/var/lib/myfrdcsa/codebases/minor/auto-builder/scripts/res.html');
my $results =
  {
   Success => 1,
   Res2 => $c,
  };

my $res = ParseDuckDuckGoResults(Results => $results);
print Dumper($res);

sub ParseDuckDuckGoResults {
  my (%args) = @_;
  my @results;
  if ($args{Results}{Success}) {
    my $html = $args{Results}{Res2};
    my @res1 = $html =~ /<div data-nir=(.*?)<\/div><\/div><\/div>/sg;
    foreach my $res2 (@res1) {
      my $hash = {};
      if ($res2 =~ /\<a href=\"([^"]+?)\" rel/sm) {
	$hash->{url} = $1;
      }
      if ($res2 =~ /class="result__a">(.+?)<\/a>/sm) {
      	$hash->{title} = $1;
      }
      if ($res2 =~ /<div class="result__snippet">(.+?)<\/div>/sm) {
      	$hash->{content} = $1;
      }
      push @results, $hash;
    }
  }
  return \@results;
}
