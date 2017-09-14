package System::Sensor::TEMPer;

use PerlLib::SwissArmyKnife;

use Class::MethodMaker
  new_with_init => 'new',
  get_set       =>
  [

   qw / /

  ];

sub init {
  my ($self,%args) = @_;

}

sub CheckTemperature {
  my ($self,%args) = @_;
  my $res1;

  if ($args{Location} eq 'downstairsComputerRoom') {
    $res1 =`/var/lib/myfrdcsa/sandbox/pcsensor-0.0.1/pcsensor-0.0.1/pcsensor`;
  } elsif ($args{Location} eq 'livingRoom') {
    $res1 = `/var/lib/myfrdcsa/codebases/minor/prolog-agent/scripts/remote-execution.pl -s 192.168.1.222 -u aindilis -c pcsensor`;
  } elsif ($args{Location} eq 'meredithsRoom') {
    $res1 = `/var/lib/myfrdcsa/codebases/minor/prolog-agent/scripts/remote-execution.pl -s 192.168.1.221 -u andrewdo -c pcsensor`;
  }
  chomp $res1;

  # 2017/05/16 21:44:15 Temperature 79.93F 26.62C
  if ($res1 =~ /^(\d+)\/(\d{2})\/(\d{2}) (\d{2}):(\d{2}):(\d{2}) Temperature ([\d\.]+)F ([\d\.]+)C/) {
    return
      {
       Success => 1,
       Date => [$1,$2,$3],
       Time => [$4,$5,$6],
       Temperature => {
		       F => $7,
		       C => $8,
		      },
      };
  }
  return
    {
     Success => 1,
     Result => $res1,
    };
}

1;
