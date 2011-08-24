package Sub::Spec::Clause::result_naked;
# ABSTRACT: Specify whether subroutine only returns result or full response

1;


=pod

=head1 NAME

Sub::Spec::Clause::result_naked - Specify whether subroutine only returns result or full response

=head1 VERSION

version 0.15

=head1 SYNOPSIS

 # the default, sub must return full HTTP-ish response
 result_naked => 0

 # sub only returns result, without being wrapped inside an HTTP-ish response
 result_naked => 1

=head1 DESCRIPTION

Setting 'result_naked' to 1 is useful if you have a 'legacy' sub which does not
return HTTP-ish response.

Example:

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
     args    => {str => 'str*'},
     result  => 'bool*',
     result_naked => 1,
 };
 sub is_palindrome {
     my %args = @_;
     my $str  = $args{str};
     $str eq reverse($str);
 }

When importing, you can also turn on this clause to make subs only return
result. This might be useful for subs that are expected to always return 200
status or some such.

Example:

 use My::Palindrome is_palindrome => {result_naked=>1};

 say is_palindrome(str => 'abc'); # 0
 say is_palindrome(str => 'aba'); # 1

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

