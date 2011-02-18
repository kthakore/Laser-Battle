package Hero;
use strict;
use warnings;

use SDL;
use JSON;
use LWP::Simple; 
use SDLx::App;

sub new {
my $class =shift;
   my $self = bless { @_ }, $class;

  my $app = $self->{app};
  if ( $app )
  {
  	 $self->{x} = rand() * $app->w;
 	 $self->{y} = rand() * $app->h;
	 $self->{hp} = 100;
  }

  return $self
}

# ATTRIBUTES

sub x :lvalue {
 return $_[0]->{x}
}

sub y :lvalue {
 return $_[0]->{y}
}

sub hp :lvalue {
 return $_[0]->{hp}
}


# METHODS
sub move {
my $self = shift;
my ($event, $dist) = @_;


}

sub draw {
my $self = shift;

	$self->{app}->draw_rect([$self->x, $self->y,10,10], 0xFF0000FF);

}

sub attack {
my $self = shift;

} 

sub serialized_to_json {
my $self = shift;

	my $serialized = { x => $self->x, y => $self->y, hp => $self->hp };	

	return encode_json $serialized;

}


sub send_to_server {
my $self = shift;
my $uri = shift;

	get( $uri.'/post_hero?x='.$self->x.'&y='.$self->y.'&health='.$self->hp );

}
 

1;
