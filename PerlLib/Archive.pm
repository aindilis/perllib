package PerlLib::Archive;

use PerlLib::SwissArmyKnife;

use File::Temp;
use String::ShellQuote;

use utf8;
use Text::Unidecode;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw( RejectList Table InverseTable)

  ];

sub init {
  my ($self,%args) = @_;
  $self->RejectList($args{RejectList} || []);
  $self->Table
    ({
      # "jar" => '',
      # "gz" => '',
      # rpm => '',
      tar => 'tar tvf ORIGFILENAME > TEMPFILENAME',
      'tar.gz' => 'tar tzf ORIGFILENAME > TEMPFILENAME',
      tgz => 'tar tzf ORIGFILENAME > TEMPFILENAME',
      zip => 'unzip -l ORIGFILENAME > TEMPFILENAME',
     });

  $self->InverseTable
    ({});
  foreach my $command (keys %{$self->InverseTable}) {
    foreach my $type (@{$self->InverseTable->{$command}}) {
      $self->Table->{$type} = $command;
    }
  }
}

sub GetListing {
  my ($self,%args) = @_;
  my $file = $args{File};
  my $quotedfile = shell_quote $file;
  if ($args{File} and -f $args{File}) {
    if (scalar @{$self->RejectList}) {
      my $regex = "\.(".join("|",@{$self->RejectList}).")\$";
      if ($file =~ /$regex/) {
	return {
		Failed => 1,
		FailureReason => "InRejectList",
	       };
      }
    }
    my $fh = File::Temp->new(DIR => "/tmp");
    my $tempfilename = shell_quote $fh->filename;
    $command = "";
    my $success = 0;
    foreach my $regex (keys %{$self->Table}) {
      if ($file =~ /\.$regex$/i) {
	$command = $self->Table->{$regex};
	See($command) if $UNIVERSAL::debug;
	$success = 1;
      }
    }
    if ($success) {
      $command =~ s/ORIGFILENAME/$quotedfile/;
      $command =~ s/TEMPFILENAME/$tempfilename/;
      print "<COMMAND: $command>\n" if $UNIVERSAL::debug;
      system $command;
      $contents = read_file($tempfilename);
      return {
	      Success => 1,
	      Listing => $contents,
	     };
    }
    return {
	    Failure => 1,
	    FailureReason => $result,
	   };

  }
}

sub ListTypes {
  my ($self,%args) = @_;
  print join("\n", sort keys %{$self->Table})."\n";
}

1;
