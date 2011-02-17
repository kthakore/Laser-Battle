use strict;
use warnings;
use SDL;
use SDLx::App;
use SDLx::Surface;

use LWP::Simple;
use JSON::Any;

my $uri = $ARGV[0];
   $uri = 'http://localhost:3000' unless $uri;

# Create our SDL application, tell it to exit when we trigger a quit event
my $app = SDLx::App->new( title => 'Evil Cloud Robots', eoq => 1);

my $robot_img = SDLx::Surface::load( name => 'sdl_client/robot.png' );

# Our callback to get the current game status
my $game_status = { message => 'Connecting' };

my $timed_update = 0;
my $update_status_content =
sub 
{
	my( $step, $app, $t) = @_;

	if(($t - $timed_update) < 0.6)
	{
		return;	
	}

	$timed_update = $t;
	my $json_status = get($uri.'/status');

	if( $json_status )
	{
		my $status = JSON::Any->from_json($json_status) ;

		if( $status)
		{
			$game_status = $status;
		$app->draw_rect([0,0,$app->w, $app->h], 0xFFFFFFFF);

			foreach( @{$game_status->{robots}} )
			{
				$app->blit_by( $robot_img, [0,0,$robot_img->w, $robot_img->h], [$_->{x}, $_->{y}, 100, 100] );
			}

				$app->draw_gfx_text([10,10],0xff0000ff, "message: ".$game_status->{message} );
			$app->update();

		}
	}

};

$app->add_move_handler( $update_status_content );

$app->run();

