package Sub::Spec::Clause::depends;
BEGIN {
  $Sub::Spec::Clause::depends::VERSION = '0.04';
}
# ABSTRACT: Specify subroutine dependency

1;


=pod

=head1 NAME

Sub::Spec::Clause::depends - Specify subroutine dependency

=head1 VERSION

version 0.04

=head1 SYNOPSIS

In your spec:

 depends => 'SUBNAME1 | SUBNAME2 | ...',

 depends => 'SUBNAME1 & SUBNAME2 & ...',

 depends => {
     all => [{sub => 'SUBNAME1'}, {sub=>'SUBNAME2'}, ...],
 },

 depends => {
     any => [{sub => 'SUBNAME1'}, {sub=>'SUBNAME2'}, ...],
 },

=head1 DESCRIPTION

This clause adds information about subroutine dependency. This is used, for
example, by L<Sub::Spec::RunDepends> to run subroutine's dependencies
(recursively) before running the subroutine itself.

=head1 DEPENDENCY CLAUSES

=head2 subname

=head2 all

=head2 any

=head2 none

=head2 not_all

=head1 SEE ALSO

L<Sub::Spec>

L<Sub::Spec::>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

