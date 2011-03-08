package Sub::Spec::Clause::features;
BEGIN {
  $Sub::Spec::Clause::features::VERSION = '0.08';
}
# ABSTRACT: Specify subroutine features

use 5.010;
use strict;
use warnings;

1;


=pod

=head1 NAME

Sub::Spec::Clause::features - Specify subroutine features

=head1 VERSION

version 0.08

=head1 SYNOPSIS

In your spec:

 features => {
     FEATURE => VALUE,
     ...
 }

=head1 DESCRIPTION

The 'features' clause allows subroutines to express their features. Current
known features are:

=head2 reverse => 1

Specifies that subroutine supports reverse operation. To reverse, caller can add
special argument '-reverse'. For example:

 $SPEC{triple} = {args=>{num=>'num*'}, features=>{reverse=>1}};
 sub triple {
     my %args = @_;
     my $num  = $args{num};
     [200, "OK", $args{-reverse} ? $num/3 : $num*3];
 }

 triple(num=>12);              # => 36
 triple(num=>12, -reverse=>1); # =>  4

=head2 undo => 1

Specifies that subroutine supports undo operation. Undo is like 'reverse', but
before doing undo you can save undo information first and then in the undo phase
you use the previously saved undo information.

To undo, caller will add special argument '-undo' => 1. Usually '-state' =>
$state will also be provided. $state is an state object which must support these
operations: save($key[, \%opts]) and load($key[, \%opts]).

Example:

 use Cwd qw(abs_path);
 use File::Slurp;

 $SPEC{lc_file} = {args=>{path=>'str*'}, features=>{undo=>1}};
 sub triple {
     my %args  = @_;
     my $path  = $args{path};
     my $undo  = $args{-undo};
     my $state = $args{-state};

     $path = abs_path($path)
         or return [500, "Can't get file absolute path"];

     if ($undo) {
         # we did not lc_file() the file previously
         my $st = $state->load($path)
             or return [412, "No undo information"]
         write_file $path, $st->{content};
         utime undef, $st->{mtime}, $path;
     } else {
         my @st = stat($path)
             or return [500, "Can't stat file"];
         my $content = read_file($path);
         $state->save($path=>{mtime=>$st[9], content=>$content});
         write_file $path, lc($content);
     }
     [200, "OK"];
 }

So if you perform a series of operations, where each operation is a call to a
subroutine which supports undo, all you need as an undo stack is just a list of
subroutine names and arguments. To perform undo, you just call each subroutine
in reverse order, and supplying -undo => 1 argument to each call:

To do stuffs:

 f1(\%args1, -undo=>0, -state=$state);
 f2(\%args2, -undo=>0, -state=$state);
 f3(\%args3, -undo=>0, -state=$state);
 ...

To undo:

 ...
 f3(\%args3, -undo=>1, -state=>$state);
 f2(\%args2, -undo=>1, -state=>$state);
 f1(\%args1, -undo=>1, -state=>$state);

=head2 dry_run => 1

Specify that subroutine supports dry-run (simulation) mode. Example:

 use Log::Any '$log';

 $SPEC{rmre} = {
     summary  => 'Delete files in curdir matching a regex',
     args     => {re=>'str*'},
     features => {dry_run=>1}
 };
 sub rmre {
     my %args    = @_;
     my $re      = qr/$args{re}/;
     my $dry_run = $args{-dry_run};

     opendir my($dir), ".";
     while (my $f = readdir($dir)) {
         next unless $f =~ $re;
         $log->info("Deleting $f ...");
         next if $dry_run;
         unlink $f;
     }
     [200, "OK"];
 }

=head1 TODO

Some features which might benefit from standardization: transaction/atomicity,
i18n (is translatable, supported languages, locales), whether it has side
effects/modifies resources (modify_fs=>1, modify_db=>1, etc).

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

