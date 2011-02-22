use strict;
use warnings;
use Redis;
use Redis::Hash;
use Data::Dumper;

my $redis = Redis->new();

$redis->ping() or die ('Crap');

unless ($redis->exists('test') )
{
	$redis->set('test' => 'only text' );
	print 'Key test doesnt exist ';
}
print $redis->get('test')." \n";
$redis->del('test');

sub create_robot
{
	my $redis = shift;
	my $id = shift;

	$redis->setnx( 'r_'.$id.':x' => 0 );
	$redis->setnx( 'r_'.$id.':y' => 0 );
}

sub get_robot 
{
	my $redis = shift;
	my $id = shift;

	my %test;
	tie %test, 'Redis::Hash', 'r_'.$id;
	return \%test;
}


my $s = get_robot($redis, 2);
$s->{x} = 10;
print Dumper $s;

