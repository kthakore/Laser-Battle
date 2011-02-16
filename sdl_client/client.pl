use strict;
use warnings;
use SDL;
use SDLx::App;

use LWP::Simple;
use JSON::Any;

# Create our SDL application, tell it to exit when we trigger a quit event
my $app = SDLx::App->new( title => 'Evil Cloud Robots', eoq => 1);


# Our callback to get the current game status
my $game_status;
my $update_status_content =
sub 
{

	my $json_status = get("http://isuckatdomains.net:3000/status");

	my $status = JSON::Any->from_json($json_status);

	if( $status)
	{
		$game_status = $status;
	}

};

$app->add_move_handler( $update_status_content );

$app->add_show_handler( sub {

	$app->draw_rect([0,0,$app->w, $app->h], 0);
	$app->draw_gfx_text([10,10],0xFF0000FF, "Message: ".$game_status->{message} );
	$app->update();

}  );

$app->run();

