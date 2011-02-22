package Laser::Battle::Controller::Root;
use Moose;
use Redis;
use Redis::Hash;
use Data::Dumper;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }



#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Laser::Battle::Controller::Root - Root Controller for Laser::Battle

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub auto : Private {
	my ($self, $c) = @_;

	my $redis = Redis->new( encoding => undef );

	$redis->setnx('total_robots' => 0 ) unless $redis->exists('total_robots');

	$c->stash->{'redis'} = $redis;


}

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

	my $r_id = $self->get_robot_id($c);
	my $robot;

	my $redis = $c->stash->{redis};
	
	if( !($r_id) && !( $redis->exists('r_'.$r_id.':id') ) )
	{

	   	# Create a robot 
		my $x = int(rand() * 600);
		my $y = int(rand() * 480);

		my $health = 100;
		my $xp = 0;


		$robot = init_robot( $redis, $r_id );
		$self->add_robot_id( $c, $robot->{id} );
	}
	$c->stash->{bot} = $robot;	

	$c->stash->{view} = 'root/index.tt';	
	
}

sub get_robot_id :Local {
	my ($self, $c) = @_;

		return $c->session->{robot} 
}

sub add_robot_id :Local {
	my ($self, $c, $robot_id) = @_;

		$c->session->{robot} = $robot_id;

}

sub get_robot {
	my $redis = shift;
	my $id = shift;

	my %robot;
	tie %robot, 'Redis::Hash', 'r_'.$id;

	return \%robot;
}

sub init_robot{
	my $redis = shift;

	my $id = $redis->get('total_robots');
	$redis->incr('total_robots');

	my $r = get_robot( $redis, $id ) ;
			my $x = int(rand() * 600);
		my $y = int(rand() * 480);

		my $health = 100;
		my $xp = 0;


	$r->{x} = $x; $r->{y} = $y; $r->{health} = 100; 
	$r->{xp} = 0; $r->{id} = $id; 
	
	return $r

}

sub get_hero {
	my $redis = shift;

	my %hero;
	tie %hero, 'Redis::Hash', 'hero';

	unless( $redis->exists( 'hero:id' ) )
	{
		$hero{id} = 0;
		$hero{x} = 0;
		$hero{y} = 0;
		$hero{health} = 100;

	}
	
	return \%hero;
}

sub warp :Chained('/') PathPart('warp') Args(0) {
	my($self, $c) = @_;

	my $r_id = $self->get_robot_id($c);
	my $robot;

	my $redis = $c->stash->{redis};
	

	if( $r_id )
	{
		$robot = get_robot($redis, $r_id);
	}
		my $x = int(rand() * 600);
		my $y = int(rand() * 480);
		$robot->{x} = $x;
		$robot->{y} = $y;
	$c->stash->{x} = $x;
	$c->stash->{y} = $y;
	
	$c->forward('View::JSON');


}

sub attack :Chained('/') PathPart('attack') Args(0) {
	my ($self, $c) = @_;
	
	

}

sub status :Chained('/') PathPart('status') Args(0) {
	my ($self, $c) = @_;

	my $redis = $c->stash->{redis};

	my $total_robots = $redis->get('total_robots');

	my @robots;
	foreach( 0..$total_robots)
		{ push @robots, get_robot( $redis, $_ ); }
	
	my $hero = get_hero($redis);
	$c->stash->{robots} = \@robots;

	$c->stash->{message} = 'Connected ...';
	$c->stash->{hero} = $hero;

	$c->stash->{redis} = undef;
	
	$c->forward('View::JSON');

}

sub post_hero :Chained('/') PathPart('post_hero') Args(0) {
my ($self, $c) = @_;
	$c->log->debug( Dumper $c->request->parameters );   

	my $hero = get_hero( $c->stash('redis') );
	
	$hero->{x} = $c->request->parameters->{x};
	$hero->{y} = $c->request->parameters->{y};
	$hero->{heath} = $c->request->parameters->{health};


	$c->response->body('done');

}


sub end : ActionClass('RenderView') {}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}


=head1 AUTHOR

Kartik Thakore,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
