package Laser::Battle::Controller::Root;
use Moose;
use Redis;
use Data::Dumper;
use Try::Tiny;
use JSON;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config( namespace => '' );

=head1 NAME

Laser::Battle::Controller::Root - Root Controller for Laser::Battle

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub auto : Private {
    my ( $self, $c ) = @_;

    my $redis = $c->model('Redis::Single')->redis();

    try{
    $redis->set( 'total_robots' => 0 ) unless $redis->exists('total_robots');
	}
    catch 
	 {
	$c->model('Redis::Single')->_refresh();
	$redis = $c->model('Redis::Single')->redis();
	$redis->set( 'total_robots' => 0 ) unless 
		$redis->exists('total_robots');
	};

}

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    my $r_id = $self->get_robot_id($c);
    my $robot;

    my $redis = $c->model('Redis::Single')->redis();

    if ( !($r_id) || !( $redis->get("r_$r_id:id") ) ) {

        # Create a robot
        my $x = int( rand() * 600 );
        my $y = int( rand() * 480 );

        my $health = 100;
        my $xp     = 0;

        $robot = init_robot( $redis, $c );
        $self->add_robot_id( $c, $robot->{id} );
    }
    else {
        $robot = get_robot( $redis, $r_id );
    }
    $c->stash->{bot} = $robot;
}

sub warp : Chained('/') PathPart('warp') Args(0) {
    my ( $self, $c ) = @_;

	my $r_id = $self->get_robot_id($c);
    my $redis = $c->model('Redis::Single')->redis();

    unless( $redis->get('r_'.$r_id.':warping') )
	{
		$redis->set('r_'.$r_id.':warping' => 1 );

		my $x = int( rand() * 600 );
		my $y = int( rand() * 480 );

		$redis->set( 'r_' . $r_id . ':x' => $x );
		$redis->set( 'r_' . $r_id . ':y' => $y );

		$c->stash->{x} = $x;
		$c->stash->{y} = $y;

		$redis->set('r_'.$r_id.':warping' => 0 );
		release_all_clients( $redis );


	}
	else
	{
		my $robot = get_robot($redis, $r_id) if $r_id;
		$c->stash->{x} = $robot->{x};
		$c->stash->{y} = $robot->{y};
	}

    $c->forward('View::JSON');

}

sub attack : Chained('/') PathPart('attack') Args(0) {
    my ( $self, $c ) = @_;

}

sub status : Chained('/') PathPart('status') Args(0) {
    my ( $self, $c ) = @_;

    my $redis = $c->model('Redis::Single')->redis();

    my $total_robots = $redis->get('total_robots');
    my @robots;
    foreach ( 0 .. ( $total_robots - 1 ) ) {
        push @robots, get_robot( $redis, $_ );
    }

    $c->stash->{robots}  = \@robots;
    $c->stash->{message} = 'Connected ...';
    my $hero = get_hero($redis);
    $c->stash->{hero} = $hero;
    $c->forward('View::JSON');

}

sub status_comet : Chained('/') PathPart('status_comet') Args(0) {
    my ( $self, $c ) = @_;

    my $redis = $c->model('Redis::Single')->redis();
    my $r_id = $self->get_robot_id($c);
    
while (1) {

        my $update = $redis->get('r_'.$r_id.':update');
        if ( $update && $update == 1 ) {

            my $total_robots = $redis->get('total_robots');

            my @robots;
            foreach ( 0 .. ( $total_robots - 1 ) ) {
                push @robots, get_robot( $redis, $_ );
            }

            my $hero = get_hero($redis);
            $c->stash->{robots} = \@robots;

            $c->stash->{message} = 'Connected ...';
            $c->stash->{hero}    = $hero;

            $c->forward('View::JSON');

            $redis->set( 'r_'.$r_id.':update'  => 0 );
            last;
        }
    }

}

sub post_hero : Chained('/') PathPart('post_hero') Args(0) {
    my ( $self, $c ) = @_;

    my $redis = $c->model('Redis::Single')->redis();

    my $params = $c->request->parameters;

    $redis->set( 'hero:x'      => $params->{x} );
    $redis->set( 'hero:y'      => $params->{y} );
    $redis->set( 'hero:health' => $params->{health} );

	release_all_clients( $redis );
    $c->response->body('done');

}

sub end : ActionClass('RenderView') {
}

=head2 default

Standard 404 error page

=cut

sub default : Path {
    my ( $self, $c ) = @_;
    $c->response->body('Page not found');
    $c->response->status(404);
}

=head1 FOO

=cut

sub get_robot_id : Local {
    my ( $self, $c ) = @_;

    return $c->session->{robot};
}

sub add_robot_id : Local {
    my ( $self, $c, $robot_id ) = @_;

    $c->session->{robot} = $robot_id;

}

sub get_robot {
    my $redis = shift;
    my $id    = shift;

    my $ro = {
        id     => $redis->get( 'r_' . $id . ':id' ),
        x      => $redis->get( 'r_' . $id . ':x' ),
        y      => $redis->get( 'r_' . $id . ':y' ),
        health => $redis->get( 'r_' . $id . ':health' ),
        xp     => $redis->get( 'r_' . $id . ':xp' ),
    };

    return $ro;
}

sub init_robot {
    my $redis = shift;
    my $c     = shift;
    my $id    = $redis->get('total_robots');

    $redis->incr('total_robots');

    warn "Making new $id robot";
    my $x = int( rand() * 600 );
    my $y = int( rand() * 480 );

    my $health = 100;
    my $xp     = 0;

    my $tag    = "r_$id:";
    my @keys   = qw/ x y health xp id/;
    my @values = ( $x, $y, 100, 0, $id );
    foreach ( 0 .. $#keys ) {
        $redis->set( $tag . $keys[$_] => $values[$_] );
    }
    return get_robot( $redis, $id );

}

sub get_hero {
    my $redis = shift;

    my $hero;

    if ( $redis->exists('hero:id') ) {

        $hero = {
            id     => 1,
            x      => 0,
            y      => 0,
            health => 100
        };

        my @keys = keys %$hero;
        foreach (@keys) {
            $redis->set( 'hero:' . $_ => $hero->{$_} );
        }

    }
    else {

        my $x = $redis->get('hero:x');

        my @keys = qw/ id x y health/;

        foreach (@keys) {
            $hero->{$_} = $redis->get( 'hero:' . $_ );
        }
    }

    return $hero;
}


sub release_all_clients{
my $redis = shift;
            my $total_robots = $redis->get('total_robots');

            my @robots;
            foreach ( 0 .. ( $total_robots - 1 ) ) {
				$redis->set('r_'.$_.':update' => 1 );
            }


}

=head1 AUTHOR

Kartik Thakore,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
