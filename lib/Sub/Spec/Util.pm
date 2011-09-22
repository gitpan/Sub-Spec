package Sub::Spec::Util;

use 5.010;
use strict;
use warnings;

require Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(str_log_level parse_args_as);

my %str_log_levels = (
    fatal => 1,
    error => 2,
    warn  => 3,
    info  => 4,
    debug => 5,
    trace => 6,
);
my %int_log_levels = reverse %str_log_levels;
my $str_log_levels_re = join("|", keys %str_log_levels);
$str_log_levels_re = qr/(?:$str_log_levels_re)/;

# return undef if unknown
sub str_log_level {
    my ($level) = @_;
    return unless $level;
    if ($level =~ /^\d+$/) {
        return $int_log_levels{$level} // undef;
    }
    return unless $level =~ $str_log_levels_re;
    $level;
}

sub parse_args_as {
    my ($args_s) = @_;
    my $args_var;
    if ($args_s eq 'hash') {
        $args_var = '%args';
    } elsif ($args_s eq 'array') {
        $args_var = '@args';
    } elsif ($args_s =~ /\A(arrayref|hashref|object)\z/) {
        $args_var = '$args';
    } else {
        die "Invalid args_s value `$args_s`";
    }
    return {args_var => $args_var};
}

1;

__END__
=pod

=head1 NAME

Sub::Spec::Util

=head1 VERSION

version 1.0.4

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

