package Sub::Spec::Clause::depends;
BEGIN {
  $Sub::Spec::Clause::depends::VERSION = '0.05';
}
# ABSTRACT: Specify subroutine dependency

1;


=pod

=head1 NAME

Sub::Spec::Clause::depends - Specify subroutine dependency

=head1 VERSION

version 0.05

=head1 SYNOPSIS

In your spec:

 depends => {
     DEPCLAUSE => DEPVALUE,
     ...,
     all => [
         {DEPCLAUSE=>DEPVALUE, ...},
         ...,
     },
     any => [
         {DEPCLAUSE => DEPVALUE, ...},
         ...,
     ],
     none => [
         {DEPCLAUSE => DEPVALUE, ...},
         ....,
     ],
 }

=head1 DESCRIPTION

Th 'depends' clause adds information about subroutine dependency. It is
extensible so you can specify anything as a dependency, be it another
subroutine, Perl version and modules, environment variables, etc. It is up to
some implementor to make use of this information.

The 'depends' clause is used, for example, by L<Sub::Spec::Runner::Orderly> to
run subroutine in dependency order (among others). Sub::Spec::Runner::Orderly
cares only about dependencies to other subroutines. Another module which
utilizes the 'depends' clause is Spanel::Setup::Runner (a subclass of
Sub::Spec::Runner, currently not available on CPAN), which in addition to
running setup functions in dependency order, also reads 'deb' depend clause to
install Debian packages required by the respective setup functions.

Dependency is specified as a hash of clauses:

 {
    DEPCLAUSE     => DEPVALUE,
    ANOTHERCLAUSE => VALUE,
    ...
  }

All of the clauses must be satisfied in order for the dependency to be declared
a success.

Below is the list of defined dependency clauses. New dependency clause may be
defined by the implementor.

=head2 sub => STR

Declare dependency to another subroutine. It is up to the implementor to decide
how to check and satisfy this dependency. For example, in
L<Sub::Spec::SetRunner>, it will call the subroutine and expect a success result
(2xx and 3xx code).

Example:

 sub => 'Package::foo'

=head2 module => STR

Declare dependency to a module. Usually this means the module exists and is
require()-able, but the exact meaning is up to the implementor to decide.
Example:

 module => 'Moo'

=head2 env => STR

Declare dependency to the an environment variable being true (the notion of true
following that of Perl). Example:

 env => 'HTTPS'

=head2 all => [DEPCLAUSES, ...]

A "meta" clause that allows several dependencies to be joined together in a
logical-AND fashion. All dependencies must be satisfied. For example, to declare
a dependency to several subroutines:

 all => [
     {sub => 'Package::foo1'},
     {sub => 'Package::foo2'},
     {sub => 'Another::Package::bar'},
 ],

=head2 any => [DEPCLAUSES, ...]

Like 'all', but specify a logical-OR relationship. Any one of the dependencies
will suffice. For example, to specify requirement to alternative modules:

 or => [
     {module => 'HTTP::Daemon'},
     {module => 'HTTP::Daemon::SSL'},
 ],

=head2 none => [DEPCLAUSES, ...]

Specify that none of the dependencies must be satisfied for this clause to be
satisfied. Example, to specify that the subroutine not run under SUDO or by
root:

 none => [
     {env  => 'SUDO_USER'},
     {code => sub {$> != 0} },
 ],

Note that the above is not equivalent to below:

 none => [
     {env => 'SUDO_USER', code => sub {$> != 0} },
 ],

which means that if none or only one of 'env'/'code' is satisfied, the whole
dependency becomes a success (since it is negated by 'none'). Probably not what
you want.

=head1 SEE ALSO

L<Sub::Spec>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

