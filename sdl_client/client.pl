use strict;
use warnings;
use SDL;
use SDLx::App;
use SDLx::Surface;
use Coro;
use Coro::Channel;
use LWP::Simple;
#use LWP::Simple::Post qw(post);
use JSON::Any;

use lib 'lib';
use Hero;

my $q1 = Coro::Channel->new(10);

my $uri = $ARGV[0];
$uri = 'http://localhost:5000' unless $uri;

# Create our SDL application, tell it to exit when we trigger a quit event
my $app = SDLx::App->new( title => 'Evil Cloud Robots', eoq => 1);

my $hero = Hero->new( app => $app );

my $robot_img = SDLx::Surface::load( name => 'robot.png' );

# Our callback to get the current game status
my $game_status = { message => 'Connecting' };

my $timed_update = 0;
	async{

		while(1)
		{

			my $msg = get($uri.'/status');
			$hero->send_to_server($uri);

		$q1->put($msg);

		cede;
		}
	};


my $update_status_content =
sub 
{
	my( $step, $app, $t) = @_;

	if(($t - $timed_update) < 0.6)
	{
		return;	
	}

	$timed_update = $t;
	
	my $json_status = $q1->get();

	if( $json_status )
	{
		my $status = JSON::Any->from_json($json_status) ;

		if( $status)
		{
			warn 'Processing message';
			$game_status = $status;

		}
	}

		cede;


};

$hero->attach();
$app->add_move_handler( $update_status_content );
$app->add_show_handler( sub {
			$app->draw_rect([0,0,$app->w, $app->h], 0xFFFFFFFF);
			$app->draw_gfx_text([10,10],0xff0000ff, "message: ".$game_status->{message} );

			if( $game_status )
			{
			foreach( @{$game_status->{robots}} )
			{
					$app->blit_by( $robot_img, [0,0,$robot_img->w, $robot_img->h], [$_->{x}, $_->{y}, 100, 100] );
			}
			}
			$hero->draw();

			$app->update();
		}
);


$app->run();

