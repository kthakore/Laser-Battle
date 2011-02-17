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

   	# Create a robot 
	my $x = int(rand() % 600);
	my $y = int(rand() % 480);

	my $health = 100;
	my $xp = 0;

	my $robot = $c->model('DB::Robot')->search(
		{ ipaddress => $c->request->{ipaddress} }
		)->single();

	unless ($robot)
	{
		$robot =	$c->model('DB::Robot')->create(
		{
			x => $x, y => $y, health => $health, xp => $xp,
			ipaddress => $c->request->{ipaddress}
		});
	}
	$c->stash->{bot} = $robot;	
	
	
}

sub status :Chained('/') PathPart('status') Args(0) {
	my ($self, $c) = @_;

	my @robots = $c->model('DB::Robot')->all();

	$c->stash->{robots} = \@robots;
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
