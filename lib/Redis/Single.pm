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

sub _refresh {

	$redis = Redis->new( encoding => undef );

}

1;
