package Sub::Spec::Exporter;
BEGIN {
  $Sub::Spec::Exporter::VERSION = '0.11';
}
# ABSTRACT: Flexible and painless exporting for your subs

1;


=pod

=head1 NAME

Sub::Spec::Exporter - Flexible and painless exporting for your subs

=head1 VERSION

version 0.11

=head1 DESCRIPTION

If your module does not have an "import" subroutine, Sub::Spec will install one
for you. This exporter is pretty flexible. You can import individual
subroutines:

 use MyModule qw(foo bar);

All subroutines which has a spec will be exportable (unless they are set with
private=>1).

You can also import Import sets of subroutines via tags. These tags are gathered
from the spec's B<export_tags>.

 use MyModule qw(:sometag);

You can import into another name:

 use MyModule foo => { as => newfoo }, bar => { as => foo };

You can add extra clauses into a sub:

 use MyModule foo => { -as => newfoo, add => {timeout => 5} };

You can also add extra clauses to all imported subs:

 use MyModule 'foo', 'bar', ':sometag', -add => {timeout => 5};

=head1 SYNTAX

 use MyModule 'SUBNAME', 'SUBNAME', ...;
 use MyModule ':TAGNAME', ...;
 use MyModule -EXPORT_CLAUSE => ARG, ...;
 use MyModule SUBNAME => { -EXPORT_CLAUSE => ARG, ...}, ':TAGNAME'=>{...}, ...;

Inside { ... }, you can leave out the dash (C<->) prefix, but it's okay if you
still use it.

=head1 EXPORT CLAUSES

=head2 -as

Export to another name.

=head2 -add

Add sub spec clauses.

=head2 -remove

Remove sub spec clauses.

=head2 -set

Replace sub spec clauses.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

