package Redis::Single;
use strict;
use warnings;
use Redis;
use Moose;
my $redis;

sub redis
{
	$redis ||= Redis->new( encoding => undef);
	return $redis;
	
}

1;
