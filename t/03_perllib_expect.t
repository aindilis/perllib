#!/usr/bin/perl -w

use Test::More no_plan;

use_ok('PerlLib::ServerManager');

use_ok('System::Nmap');
use_ok('Time::HiRes', qw(usleep));

my $port = 3600;

my $nmap;
eval {$nmap = System::Nmap->new()};
plan skip_all => 'System::Nmap required for testing' if $@;
isa_ok( $nmap, 'System::Nmap' );

is
  (
   $nmap->OpenPortP
   (
    Host => "localhost",
    Port => $port,
   ),
   0,
   "Checking that the cyc server hasn't started just yet",
  );

my $server1;
eval {
  $server1 = PerlLib::ServerManager->new
    (
     Command => "cd /var/lib/myfrdcsa/sandbox/researchcyc-1.0/researchcyc-1.0/scripts && ./run-cyc.sh",
     Debug => 1,
     Initialized => "CYC(1):",
    );
  };
plan skip_all => 'PerlLib::ServerManager failed' if $@;
isa_ok( $server1, 'PerlLib::ServerManager' );

is
  (
   $nmap->OpenPortP
   (
    Host => "localhost",
    Port => $port,
   ),
   1,
   "Port is open when cyc server is running",
  );

$server1->Stop;

if (0) {
  sub Watch {
    my %args = @_;
    my $delay = $args{Delay} || 1000;
    while (! defined ${$args{Data}}) {
      usleep($delay);
    }
    return ${$args{Data}};
  }

  # now shut down the server and try with the callback
  my $data;
  my $server2;
  eval {
    $server2 = PerlLib::ServerManager->new
      (
       Command => "cd /var/lib/myfrdcsa/sandbox/researchcyc-1.0/researchcyc-1.0/scripts && ./run-cyc.sh",
       Debug => 1,
       Initialized => "CYC(1):",
       CallBack => sub {$data = 1},
      );
    };
  plan skip_all => 'PerlLib::ServerManager failed' if $@;
  my $res = Watch(Data => \$data);
  print Dumper($res);

  isa_ok( $server2, 'PerlLib::ServerManager' );
}

1;
