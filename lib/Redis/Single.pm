package Redis::Single;
use strict;
use warnings;
use Redis;
use Moose;
my $redis;

sub redis
{
	$redis ||= Redis->new();
	return $redis;
	
}

1;
