#!/usr/bin/env perl
use strict;
use warnings;
use Laser::Battle;

Laser::Battle->setup_engine('PSGI');
my $app = sub { Laser::Battle->run(@_) };

