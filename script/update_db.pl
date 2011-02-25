use strict;
use warnings;
use Redis;

my $r = Redis->new();

$r->set(total_robots => 0 );

$r->flushall();

