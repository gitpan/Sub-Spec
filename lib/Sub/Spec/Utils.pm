package Sub::Spec::Utils;
BEGIN {
  $Sub::Spec::Utils::VERSION = '0.12';
}

use 5.010;
use strict;
use warnings;

# currently we cheat by only parsing a limited subset of schema. this is because
# Data::Sah is not available yet.
sub _parse_schema {
    my ($schema) = @_;

    $schema = [$schema, {}] if !ref($schema);
    die "BUG: Can't parse hash-form schema yet" if ref($schema) ne 'ARRAY';

    my $type = $schema->[0];
    $type =~ s/\*$// and $schema->[1]{required} = 1;
    die "BUG: Can't handle type `$type` yet"
        unless $type =~ /^(int|float|bool|str|array|hash|any|code)$/;

    {type=>$type, attr_hashes=>[$schema->[1]]};
}

1;

__END__
=pod

=head1 NAME

Sub::Spec::Utils

=head1 VERSION

version 0.12

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

