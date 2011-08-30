package Sub::Spec::Schema;

use 5.010;
use strict;
use warnings;

our $VERSION = '1.0.2'; # VERSION

our $SCHEMA = ['hash*', {keys => {}}];

sub add_clause {
    my ($name, $schema) = @_;
    $SCHEMA->[1]{keys}{$name} = $schema;
}

add_clause type => ['str*', {
    in => [qw/sub method class_method/],
    default => 'sub',
}];

add_clause scope => ['str*', {
    in => [qw/public private/],
    default => 'public',
}];

add_clause name => ['str*', {}];

add_clause description => ['str*', {}];

add_clause timeout => ['num*', {}];

add_clause args => ['hash*' => {
    keys_of => 'str*', # XXX varname
    values_of => 'schema*',
}];

add_clause required_args => ['array*' => {
    of => 'str*', # XXX varname, mentioned in args' keys
}];

add_clause args_as => ['str*' => {
    in => [qw/hash hashref array arrayref object/],
    default => 'hash',
}];

add_clause result => 'schema*';

add_clause result_naked => ['bool*' => {
    default => 0,
}];

add_clause retry => ['int*' => {}];

add_clause features => ['hash*' => {
    keys_in => [qw/reverse undo dry_run pure/],
}];

add_clause deps => ['hash*' => {
    keys_in => [qw/sub mod /],
}];

1;
# ABSTRACT: Sah schema for Sub::Spec spec


__END__
=pod

=head1 NAME

Sub::Spec::Schema - Sah schema for Sub::Spec spec

=head1 VERSION

version 1.0.2

=head1 SYNOPSIS

 use Sub::Spec::Schema;
 # Schema is in $Sub::Spec::Schema::SCHEMA;

=head1 DESCRIPTION

Extensions which adds spec clauses or other stuffs (e.g. add a new dep clause,
or feature) should update the schema to reflect it.

=head1 SEE ALSO

L<Sub::Spec>

L<Data::Sah>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

