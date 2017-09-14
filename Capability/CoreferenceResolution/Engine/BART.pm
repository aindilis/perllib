package Capability::CoreferenceResolution::Engine::BART;

use System::BART;

use Acme::Damn;
use Data::Dumper;
use Net::Telnet;
use XML::Smart;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / MyBART /

  ];

sub init {
  my ($self,%args) = @_;
}

sub StartServer {
  my ($self,%args) = @_;
  if (! $self->MyBART) {
    $self->MyBART
      (System::BART->new);
  }
  $self->MyBART->StartServer;
}

sub StopServer {
  my ($self,%args) = @_;
  if ($self->MyBART) {
    $self->MyBART->StopServer;
  }
}

sub StartClient {
  my ($self,%args) = @_;

}

sub CoreferenceResolution {
  my ($self,%args) = @_;
  return $self->MyBART->CoreferenceResolution
    (Text => $args{Text});
}

sub ReplaceCoreferences {
  my ($self,%args) = @_;
  my $res = $self->CoreferenceResolution
    (Text => $args{Text});
  # now use xml::smart to do some operations on this stuff
  print $res."\n";
  my $xml = XML::Smart->new($res);
  my $ids = {};
  foreach my $item (@{$xml->{text}{s}}) {
    my $counter = {
		   "w" => 0,
		   "coref" => 0,
		  };
    foreach my $thing (@{$item->{'/order'}}) {
      # retrieve this item
      if ($thing eq "coref") {
	my @phrase;
	foreach my $token (@{$item->{"coref"}[$counter->{"coref"}]->{'w'}}) {
	  push @phrase, $token->content;
	}
	my $w = join(" ",@phrase);
	my $setid = $item->{"coref"}[$counter->{"coref"}]->{'set-id'}->content;
	$ids->{$setid}->{$w}++;
	++$counter->{"coref"};
      } else {
	my $w = $item->{"w"}[$counter->{"w"}++]->content;
	# do nothing with this
	$w = "";
      }
    }
  }

  my @tokens;
  foreach my $item (@{$xml->{text}{s}}) {
    my $counter = {
		   "w" => 0,
		   "coref" => 0,
		  };
    foreach my $thing (@{$item->{'/order'}}) {
      # retrieve this item
      if ($thing eq "coref") {
	my @phrase;
	foreach my $token (@{$item->{"coref"}[$counter->{"coref"}]->{'w'}}) {
	  push @phrase, $token->content;
	}
	my $w = join(" ",@phrase);
	my $setid = $item->{"coref"}[$counter->{"coref"}]->{'set-id'}->content;
	if ($args{WithEntities}) {
	  my $entity = $setid;
	  if ($entity =~ /set_(\d+)/) {
	    push @tokens, "coref_entity_".$self->NumberToLetters(Number => $1);
	  }
	} else {
	  push @tokens, "<<<".join("|", sort keys %{$ids->{$setid}}).">>>";
	}
	++$counter->{"coref"};
      } else {
	my $w = $item->{"w"}[$counter->{"w"}++]->content;
	# do nothing with this
	push @tokens, $w;
      }
    }
  }
  return {
	  Success => 1,
	  String => \@tokens,
	  Ids => $ids,
	 };
}

sub NumberToLetters {
  my ($self,%args) = @_;
  my $n = $args{Number};
  my $mapping = ["A".."Z"];
  my $letters = "";
  my $res = int($n / 26);
  if ($res > 0) {
    $letters .= $self->NumberToLetters(Number => ($res - 1));
  }
  my $rem = $n % 26;
  $letters .= $mapping->[$rem];
  return $letters;
}

1;
