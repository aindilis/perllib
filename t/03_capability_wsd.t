#!/usr/bin/perl -w

use Test::More no_plan;

use_ok('Capability::WSD');

# use_ok('IO::Socket::INET');
# use_ok('Socket');
# 
# my $port = "10000";
# 
# my $nmap;
# eval {$nmap = System::Nmap->new()};
# plan skip_all => 'System::Nmap required for testing' if $@;
# isa_ok( $nmap, 'System::Nmap' );
# 
# is
#   (
#    $nmap->OpenPortP
#    (
#     Host => "localhost",
#     Port => $port,
#    ),
#    0,
#    "Checking that the port is closed before starting server",
#   );
# 
# my $server;
# eval {$server = IO::Socket::INET->new
# 	(
# 	 Proto     => 'tcp',
# 	 LocalPort => $port,
# 	 Listen    => SOMAXCONN,
# 	 Reuse     => 1,
# 	)};
# plan skip_all => 'IO::Socket::INET required for testing' if $@;
# isa_ok( $server, 'IO::Socket::INET' );
# 
# is
#   (
#    $nmap->OpenPortP
#    (
#     Host => "localhost",
#     Port => $port,
#    ),
#    1,
#    "Port is open when server is running",
#   );

1;
