use strict;
use warnings;
use Redis;

my $redis = Redis->new();

$redis->ping() or die ('Crap');

unless ($redis->exists('test') )
{
	$redis->set('test' => 'only text' );
	print 'Key test doesnt exist ';
}
	print $redis->get('test')." \n";
	$redis->del('test');


	
