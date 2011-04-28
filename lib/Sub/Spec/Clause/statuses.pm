package Sub::Spec::Clause::statuses;
BEGIN {
  $Sub::Spec::Clause::statuses::VERSION = '0.13';
}
# ABSTRACT: Specify possible return status codes

1;


=pod

=head1 NAME

Sub::Spec::Clause::statuses - Specify possible return status codes

=head1 VERSION

version 0.13

=head1 SYNOPSIS

NOT YET FLESHED OUT.

 # result is an integer
 statuses => {
     200 => { summary => ..., description => ..., result => SCHEMA, ... },
     500 => { ... },
     # ...
 }

=head2 DESCRIPTION

=head1 SEE ALSO

L<Sub::Spec>

L<Data::Sah>

L<Sub::Spec::Clause::result>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

