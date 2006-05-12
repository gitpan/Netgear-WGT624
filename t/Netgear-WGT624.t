# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl Netgear-WGT624.t'

#########################

use Test::More tests => 6;
BEGIN { use_ok('Netgear::WGT624') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $ng = Netgear::WGT624->new();
$ng->address('router-int');

print "retval is " . $ng->make_url . "\n";

is($ng->make_url, 'http://router-int/RST_stattbl.htm', 'make_url test 1');
is($ng->make_url, 'http://router-int/RST_stattbl.htm', 'make_url test 2');

$ng->address('router-int/');

is($ng->make_url, 'http://router-int/RST_stattbl.htm', 'make_url test 3');

is($ng->get_server_address, 'router-int:80', 'get_server_address test 1');

$ng->address('router-int');
is($ng->get_server_address, 'router-int:80', 'get_server_address test 2');
