package PerlLib::HTMLConverter;

use HTML::Parser;

use utf8;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       => [ qw / Parser String Inside / ];

sub init {
  my ($self,%args) = @_;
  $UNIVERSAL::_html_converter_string = "";
  $self->Parser
    (HTML::Parser->new
     (api_version => 3,
      handlers    => [start => [\&tag, "tagname, '+1'"],
		      end   => [\&tag, "tagname, '-1'"],
		      text  => [\&text, "dtext"],
		     ],
      marked_sections => 1,
     ));
  $self->Parser->utf8_mode(1);
}

sub ConvertToTxt {
  my ($self,%args) = @_;
  my $contents = $args{Contents};
  $UNIVERSAL::_html_converter_string = "";
  utf8::decode($contents);
  $contents =~ s/[^[:ascii:]]/ /g;
  $self->Parser->parse($contents);
  return $UNIVERSAL::_html_converter_string;
  $UNIVERSAL::_html_converter_string = "";
}

sub ConvertFileToTxt {
  my ($self,%args) = @_;
  my $input = $args{Input};
  my $output = $args{Output};
  if (-f $input) {
    my $contents = `cat "$input"`;
    $UNIVERSAL::_html_converter_string = "";
    utf8::decode($contents);
    $contents =~ s/[^[:ascii:]]/ /g;
    $self->Parser->parse($contents);
    my $result = $UNIVERSAL::_html_converter_string;
    $UNIVERSAL::_html_converter_string = "";
    if ($result) {
      my $OUT;
      open (OUT,">$output") or die "cannot open for wriitng output file <$output>\n";
      print OUT $result;
      close(OUT);
    }
  }
}

sub tag
  {
    my($tag, $num) = @_;
    $UNIVERSAL::_html_converter_inside->{$tag} += $num;
    $UNIVERSAL::_html_converter_string .= " ";
  }

sub text
  {
    return if $UNIVERSAL::_html_converter_inside->{script} || $UNIVERSAL::_html_converter_inside->{style};
    $UNIVERSAL::_html_converter_string .= shift;
  }

1;
