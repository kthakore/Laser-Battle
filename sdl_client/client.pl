use strict;
use warnings;
use SDL;
use SDLx::App;

use LWP::Simple;
use JSON;

my $app = SDLx::App->new( title => 'Evil Cloud Robots', eoq => 1);

$app->add_show_handler(
sub 
{
	my $content = get("http://isuckatdomains.net:3000/status");

	warn $content;

}

);

$app->run();

