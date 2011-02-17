package Laser::Battle::Controller::Root;
use Moose;
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

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

	my $r_id = $self->get_robot_id($c);
	my $robot;
	if( $r_id )
	{
	
		$robot = $c->model('DB::Robot')->find( $r_id );

	}
	
	unless ($robot)
	{

	   	# Create a robot 
		my $x = int(rand() * 600);
		my $y = int(rand() * 480);

		my $health = 100;
		my $xp = 0;


		$robot = $c->model('DB::Robot')->create(
		{
			x => $x, y => $y, health => $health, xp => $xp,

		});

		$self->add_robot_id( $c, $robot->id() );
	}
	$c->stash->{bot} = $robot;	
	
	
}

sub get_robot_id :Local {
	my ($self, $c) = @_;

		return $c->session->{robot} 
}

sub add_robot_id :Local {
	my ($self, $c, $robot_id) = @_;

		$c->session->{robot} = $robot_id;

}

sub warp :Chained('/') PathPart('warp') Args(0) {
	my($self, $c) = @_;

		my $r_id = $self->get_robot_id($c);
	my $robot;
	if( $r_id )
	{
	
		$robot = $c->model('DB::Robot')->find( $r_id );

	}
		   	# Create a robot 
		my $x = int(rand() * 600);
		my $y = int(rand() * 480);

	if( $robot )
	{
		$robot->update(
		{ x=> $x, y => $y }
		);

	$c->stash->{x} = $x;
	$c->stash->{y} = $y;
	


	}

	$c->forward('View::JSON');


}

sub attack :Chained('/') PathPart('attack') Args(0) {
	my ($self, $c) = @_;
	
	

}

sub status :Chained('/') PathPart('status') Args(0) {
	my ($self, $c) = @_;

	my @robots = $c->model('DB::Robot')->all();

	my @send_bots; 
	foreach( @robots )
	{
		my $x = $_->x; my $y = $_->y; my $h = $_->health; my $xp = $_->xp;
		
		push( @send_bots, 	{
			x => $x, y => $y, health => $h, xp => $xp,
				} );
	}

	$c->stash->{robots} = \@send_bots;

	$c->stash->{message} = 'test';
	
	$c->forward('View::JSON');

}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Kartik Thakore,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
