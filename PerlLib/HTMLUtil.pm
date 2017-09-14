package PerlLib::HTMLUtil;

use Data::Dumper;
use HTML::Parser ();

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw ( ExtractTitle );

my @results;

sub start_handler
  {
    return if shift ne "title";
    my $self = shift;
    $self->handler(text => sub { push @results, shift }, "dtext");
    $self->handler(end  => sub { shift->eof if shift eq "title"; },
		   "tagname,self");
  }

sub ExtractTitle {
  my $contents = shift;
  @results = ();
  my $p = HTML::Parser->new(api_version => 3);
  $p->handler( start => \&start_handler, "tagname,self");
  $p->parse($contents);
  my @copy = @results;
  return \@copy;
}

1;
