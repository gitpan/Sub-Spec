package Sub::Spec::Clause::args_positional;
BEGIN {
  $Sub::Spec::Clause::args_positional::VERSION = '0.10';
}
# ABSTRACT: Specify whether sub accepts named or positional arguments

1;


=pod

=head1 NAME

Sub::Spec::Clause::args_positional - Specify whether sub accepts named or positional arguments

=head1 VERSION

version 0.10

=head1 SYNOPSIS

 # the default, sub must accept %args
 args_positional => 0

 # sub accept @args
 args_positional => 1,

=head1 DESCRIPTION

Setting 'args_positional' to 1 is useful if you have a 'legacy' sub which does
not accept named arguments in a hash.

 $SPEC{is_palindrome} = {
     summary => 'Check whether a string is a palindrome',
     args    => {str => 'str*'},
     result  => 'bool*',
 };
 sub is_palindrome {
     my %args = @_;
     my $str  = $args{str};
     [200, "OK", $str eq reverse($str) ? 1:0];
 }

versus:

 $SPEC{is_palindrome} = {
     summary => 'Check whether a string is a palindrome',
     args    => {str => ['str*'=>{arg_pos=>0}]},
     args_positional => 1,
     result  => 'bool*',
 };
 sub is_palindrome {
     my ($str) = @_;
     my $str  = $args{str};
     [200, "OK", $str eq reverse($str) ? 1:0];
 }

NOTE: Currently, args_positional=>1 is not supported yet by many other
Sub::Spec::* modules. So it's best if you write your subs using named arguments
style.

When importing, you can also choose to use args_positional or not.

 use My::Palindrome is_palindrome => {args_positional=>1, result_naked=>1};

 say is_palindrome('abc'); # 0
 say is_palindrome('aba'); # 1

=head1 SEE ALSO

L<Data::Sah>

L<Util::Timeout>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

