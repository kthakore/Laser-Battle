use strict;
use warnings;
use SDL;
use SDLx::App;

use LWP::Simple;
use JSON::Any;

# Create our SDL application, tell it to exit when we trigger a quit event
my $app = SDLx::App->new( title => 'Evil Cloud Robots', eoq => 1);


# Our callback to get the current game status
my $game_status = { message => 'Connecting' };

			$app->draw_rect([0,0,$app->w, $app->h], 0);
			$app->draw_gfx_text([10,10],0xff0000ff, "message: ".$game_status->{message} );
			$app->update();


my $timed_update = 0;
my $update_status_content =
sub 
{
	my( $step, $app, $t) = @_;

	if(($t - $timed_update) < 0.40)
	{
		return;	
	}

	$timed_update = $t;
	my $json_status = get("http://localhost:3000/status");

	if( $json_status )
	{
		my $status = JSON::Any->from_json($json_status) ;

		if( $status)
		{
			$game_status = $status;

			$app->draw_rect([0,0,$app->w, $app->h], 0);
			$app->draw_gfx_text([10,10],0xff0000ff, "message: ".$game_status->{message} );
			$app->update();

		}
	}

};

$app->add_move_handler( $update_status_content );

$app->run();

