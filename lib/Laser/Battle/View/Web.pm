package Laser::Battle::View::Web;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    render_die => 1,
);

=head1 NAME

Laser::Battle::View::Web - TT View for Laser::Battle

=head1 DESCRIPTION

TT View for Laser::Battle.

=head1 SEE ALSO

L<Laser::Battle>

=head1 AUTHOR

Kartik Thakore,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
