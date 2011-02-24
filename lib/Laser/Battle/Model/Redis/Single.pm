package Laser::Battle::Model::Redis::Single;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';
__PACKAGE__->config( class => 'Redis::Single' );
1;
