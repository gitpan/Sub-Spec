package Sub::Spec::Clause::args_as;
# ABSTRACT: Specify how sub accepts arguments

1;


=pod

=head1 NAME

Sub::Spec::Clause::args_as - Specify how sub accepts arguments

=head1 VERSION

version 1.0.1

=head1 SYNOPSIS

 # the default, sub accept %args ($args{arg1}, $args{arg2}, and so on)
 args_as => 'HASH'

 # sub accepts @args (($arg1, $arg2, ...))
 args_as => 'ARRAY'

 # sub accepts $args object ($args->arg1, $args->arg2, and so on)
 args_as => 'OBJECT'

=head1 DESCRIPTION

NOTE: Currently only args_as 'HASH' is supported by the various Sub::Spec
modules, as they can work without any wrapper.

=head2 args_as => ARRAY

Setting args_as to 'ARRAY' is useful if you have a "legacy" sub which accepts
arguments directly from @_, like most normal Perl subs.

 $SPEC{is_palindrome} = {
     summary => 'Check whether a string is a palindrome',
     args    => {str => 'str*', ci=>[bool=>{default=>0}]},
     args_as => 'ARRAY',
     result  => 'bool*',
 };
 sub is_palindrome {
     my ($str, $ci) = @_;
     $str = lc($str) if $ci;
     [200, "OK", $str eq reverse($str) ? 1:0];
 }

XXX How should special arguments be passed? Via localized %special_args?

When importing, you can select argument passing style (HASH, HASHREF, ARRAY,
ARRAYREF):

 # XXX use, say, args_passing? so it's not confused with args_as because they
 # are slightly different (as is result_naked from spec side and exporter side)
 use My::Palindrome is_palindrome => {args_as=>'ARRAY', result_naked=>1};

 say is_palindrome('abc');    # 0
 say is_palindrome('abA');    # 0
 say is_palindrome('abA', 1); # 1

=head2 args_as => OBJECT

Setting args_as to 'OBJECT' is useful if you want to catch typo mistakes in your
subs:

 package My::Palindrome;
 $SPEC{is_palindrome} = {
     summary => 'Check whether a string is a palindrome',
     args    => {str => 'str*', ci=>[bool=>{default=>0}]},
     args_as => 'OBJECT',
     result  => 'bool*',
 };
 sub is_palindrome {
     # XXX or should it even like in Dancer? args->str et al?
     my $args = shift;
     my $str  = $args->str;
     $str = lc($str) if $args->ci;
     [200, "OK", $str eq reverse($str) ? 1:0];
 }

How this works: An argument class will be created for this sub (say
Sub::Spec::__arg::My::Palindrome::is_palindrome) which has accessors for every
defined argument in the specification (as well as special arguments).

Special arguments are accessed via _NAME (like $args->_undo, $args->_reverse,
etc) so make sure you do not define arguments with those names if you want to
use object argument passing.

=head1 SEE ALSO

L<Sub::Spec>

L<Sub::Spec::Exporter>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

