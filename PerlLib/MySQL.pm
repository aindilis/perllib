package PerlLib::MySQL;

use Data::Dumper;
use DBI;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / Host Username DBName DBH TableInformation Debug /

  ];

sub init {
  my ($self,%args) = @_;
  $self->Host($args{Host} || "localhost");
  $self->Username($args{Username} || "root");
  $self->DBName($args{DBName});

  $args{Password} ||= `cat /etc/myfrdcsa/config/perllib`;
  chomp $args{Password};

  if ($self->DBName) {
    $self->DBH
      (DBI->connect
       (
        "DBI:mysql:database=".$self->DBName.";host=".$self->Host,
        $self->Username,
        $args{Password},
        {
         'RaiseError' => 1,
        },
       ));
    $self->DBH->{'mysql_auto_reconnect'} = 1;
  }
  $self->TableInformation({});
  if (0) {
    $self->Debug(1);
  } else {
    $self->Debug($args{Debug} || 0);
  }
}

sub Do {
  my ($self, %args) = @_;
  return $self->MySQLDo(%args);
}

sub MySQLDo {
  my ($self,%args) = @_;
  my $statement = $args{Statement};
  print "$statement\n" if ($args{Debug} || $self->Debug);
  if ($statement =~ /^(select|show|describe)/i) {
    if ($statement =~ / (from|where) /i and !($args{Array} or $args{AOH})) {
      $sth = $self->DBH->prepare($statement);
      $sth->execute();
      return $sth->fetchall_hashref($args{KeyField} || "ID");
    } elsif ($args{AOH}) {
      $sth = $self->DBH->prepare($statement);
      $sth->execute();
      my @list;
      while ( $ref = $sth->fetchrow_hashref ) {
	push @list, $ref;
      }
      return \@list;
    } else {
      $sth = $self->DBH->prepare($statement);
      $sth->execute();
      return $sth->fetchall_arrayref();
    }
  } else {
    # print "<".$statement.">\n";
    $self->DBH->do($statement);
  }
}

# "done" are temp comments with new dev. can be reverted
sub Lookup { ########## done in SQLDatabase
  my ($self,%args) = @_;
  my $table = $args{Table};
  my $key = $args{Key};
  my $value = $args{Value};
  my $c = "select * from $table where $key=".$self->DBH->quote($value).";";
  # print "$c\n";
  my $ref = $self->MySQLDo
    (Statement => $c,
     KeyField => "ID");
  my $ret = {};
  foreach my $key (keys %$ref) {
    $ret->{$key} = $ref->{$key};
  }
  return $ret;
}

sub Quote {
  my ($self,$text) = @_;
  return $self->DBH->quote($text);
}

sub InsertID {
  my ($self,%args) = @_;
  # return $self->DBH->mysql_insertid;
  my $s = "select last_insert_id()";
  my $sth = $self->DBH->prepare($s);
  $sth->execute();
  my $ret = $sth->fetchall_arrayref;
  return $ret->[0]->[0];
}

sub MaxID {
  my ($self,%args) = @_;
  my $s = "select max(ID) from ".$args{Table};
  my $sth = $self->DBH->prepare($s);
  $sth->execute();
  my $ret = $sth->fetchall_arrayref;
  return $ret->[0]->[0];
}

sub GetHighestID {
  my ($self,%args) = @_;
  my $s = "select max(ID) from ".$args{Table};
  my $sth = $self->DBH->prepare($s);
  $sth->execute();
  my $ret = $sth->fetchall_arrayref;
  return $ret->[0]->[0];
}

sub InsertContents {
  my ($self,%args) = @_;
  # return $self->DBH->mysql_insertid;
  my $id = $self->InsertID(Table => $args{Table});
  my $s = "select * from $args{Table} where id='$id'";
  my $ret = $self->Do
    (
     Statement => $s,
     KeyField => $args{KeyField},
    );
  my @list = (values %$ret);
  return $list[0];
}

  # moreover, it could actually do a lookup on the table information
  # to issue defaults, i.e. Date would get Now()

sub SetTableDefaults {
  my ($self,%args) = @_;
  # override the default values for a table
}

sub Insert {
  my ($self,%args) = @_;
  # get table information
  if (! exists $self->TableInformation->{$args{Table}}) {
    # check that the table really exists in the DB
    if (1) {
      # assume it does for now
      # give it nonsense information
      $self->TableInformation->{$args{Table}} = 1;
    }
  }
  my @values;
  if (ref $args{Values} eq "ARRAY") {
    my $i = 0;
    foreach my $value (@{$args{Values}}) {
      if (! defined $value) {
	push @values, $self->TableInformation->{$args{Table}}->{ColumnList}->[$i]
	  || "NULL";
      } else {
	push @values, $self->QuoteIfNecessary
	  (Value => $value);
      }
    }
  } elsif (ref $args{Values} eq "HASH") {
    my $i = 0;
    while (exists $self->TableInformation->{$args{Table}}[$i]) {
      $column = $self->TableInformation->{$args{Table}}[$i][0];
      my $value = $args{Values}->{$column};
      if (! defined $value) {
	push @values, $value
	  || "NULL";
      } else {
	push @values, $self->QuoteIfNecessary
	  (Value => $value);
      }
      ++$i;
    }
  }
  my $statement = join(" ",
       ("insert into",
	$args{Table},
	"values",
	"(".join(",",@values).");"));
  if (0) {
    print $statement."\n";
  } else {
    $self->Do
      (Statement => $statement);
  }
}

sub QuoteIfNecessary {
  my ($self,%args) = @_;
  my $v = $args{Value};
  if ($v =~ /\W/) {
    if ($v =~ /^(now|from_unixtime)\s*\(.*\)$/i) {
      return $v;
    } else {
      return $self->Quote($v);
    }
  } else {
    return $self->Quote($v);
  }
}

# routines to access the structure of the databases

sub GetListOfTables {
  my ($self,%args) = @_;
  my @t;
  my $ret = $self->Do
    (Statement => "show tables",
     KeyField => "Tables_in_".$self->DBName);
  foreach my $e (@$ret) {
    push @t, $e->[0];
  }
  return \@t;
}

sub GetTableInformation {
  my ($self,%args) = @_;
  return $self->Do(Statement => "describe ".$args{Table});
}

sub GetDatabaseInformation {
  my ($self,%args) = @_;
  my $tables = {};
  foreach my $table (@{$self->GetListOfTables}) {
    next if $table eq 'order';
    $tables->{$table} =
      $self->GetTableInformation
	(Table => $table);
  }
  return $tables;
}

1;
