package Laser::Battle::Schema::Result::Robot;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use namespace::autoclean;
extends 'DBIx::Class::Core';

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 NAME

Laser::Battle::Schema::Result::Robot

=cut

__PACKAGE__->table("Robot");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 session_id

  data_type: 'text'
  is_nullable: 1

=head2 x

  data_type: 'integer'
  is_nullable: 1

=head2 y

  data_type: 'integer'
  is_nullable: 1

=head2 health

  data_type: 'integer'
  is_nullable: 1

=head2 xp

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "session_id",
  { data_type => "text", is_nullable => 1 },
  "x",
  { data_type => "integer", is_nullable => 1 },
  "y",
  { data_type => "integer", is_nullable => 1 },
  "health",
  { data_type => "integer", is_nullable => 1 },
  "xp",
  { data_type => "integer", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("id");


# Created by DBIx::Class::Schema::Loader v0.07002 @ 2011-02-17 01:10:32
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fBI4Clqq2oMaEb6Mkk+MzQ


# You can replace this text with custom content, and it will be preserved on regeneration
__PACKAGE__->meta->make_immutable;
1;