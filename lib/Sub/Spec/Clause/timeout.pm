package Sub::Spec::Clause::timeout;
BEGIN {
  $Sub::Spec::Clause::timeout::VERSION = '0.06';
}
# ABSTRACT: Limit subroutine execution

1;


=pod

=head1 NAME

Sub::Spec::Clause::timeout - Limit subroutine execution

=head1 VERSION

version 0.06

=head1 SYNOPSIS

NOT IMPLEMENTED YET.

In your caller:

 use Sub::Spec;
 use MyModule qw(mysub);

 # limit execution to 5 seconds
 my $res = func(arg1=>val, arg2=>val, ..., -timeout => 5);

 die "Function timed out"
     if $res->[0] == 504;

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

