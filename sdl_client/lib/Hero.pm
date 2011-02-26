package Hero;
use strict;
use warnings;

use SDL;
use JSON;
use LWP::Simple; 
use SDL::Event;
use SDL::Events;
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
	 $self->{pressed} = {};

	 $app->add_event_handler( sub { $self->event_handle(@_) } );
	 $app->add_move_handler ( sub { $self->move_handle(@_) } );

  }
  else
  {
	die 'Need app';
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

sub pressed :lvalue 
{
 return $_[0]->{pressed}
}


# METHODS
sub attach {
	my $self = shift;
	my $app = $self->{app};
	 $app->add_event_handler( sub { $self->event_handle(@_) } );
	 $app->add_move_handler ( sub { $self->move_handle(@_) } );
	warn 'Attached';

}
sub event_handle {
	my $self = shift;
	my ($event,$app) = @_;

	my $key = $event->key_sym;
	my $name = SDL::Events::get_key_name($key) if $key;
	    if ( $event->type == SDL_KEYDOWN ) {
            $self->pressed->{$name} = 1;
        }
        elsif ( $event->type == SDL_KEYUP ) {
            $self->pressed->{$name} = 0;
        }


}

sub move_handle {
	my $self = shift;
	my ($dt, $app, $time) = @_;

	my $vel = 10*$dt;

	if( $self->pressed->{left} )
	{
		$self->{x} = $self->{x} - $vel;
	}	
	if( $self->pressed->{right} )
	{
		$self->{x} = $self->{x} + $vel;
	}
	if( $self->pressed->{up} )
	{
		$self->{y} = $self->{y} - $vel;
	}	
	if( $self->pressed->{down} )
	{
		$self->{y} = $self->{y} + $vel;
	}

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
