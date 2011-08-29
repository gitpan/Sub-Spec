package Sub::Spec::Clause::features;
# ABSTRACT: Specify subroutine features

use 5.010;
use strict;
use warnings;

1;


=pod

=head1 NAME

Sub::Spec::Clause::features - Specify subroutine features

=head1 VERSION

version 1.0.1

=head1 SYNOPSIS

In your spec:

 features => {
     FEATURE => VALUE,
     ...
 }

=head1 DESCRIPTION

The 'features' clause allows subroutines to express their features. It is
extensible so you can specify more features.

Below is the list of defined features. New feature clause may be defined by
providing Sub::Spec::Clause::features::check_<CLAUSE>().

=head2 reverse => BOOL|HASHREF

Default is false. If set to true, specifies that subroutine supports reverse
operation. To reverse, caller can add special argument '-reverse'. For example:

 $SPEC{triple} = {args=>{num=>'num*'}, features=>{reverse=>1}};
 sub triple {
     my %args = @_;
     my $num  = $args{num};
     [200, "OK", $args{-reverse} ? $num/3 : $num*3];
 }

 triple(num=>12);              # => 36
 triple(num=>12, -reverse=>1); # =>  4

DRAFT: Conditional reversibility: if set to hashref, sub can declare partial
reversibility. Caller can call with special argument '-reverse_action' set to
'test' and sub must return a bool result indicating if the particular action is
reversible. Example:

 $SPEC{multiply_by} = {args     => {num=>'num*', multiplier=>'num*'},
                       features => {reverse=>{...}}};
 sub multiply_by {
     my %args = @_;
     my $n    = $args{num};
     my $m    = $args{multiplier};
     if ($args{-reverse_action} && $args{-reverse_action} eq 'test') {
         # we can only reverse if multiplier is not zero
         return [200, "OK", $m == 0 ? 1:0];
     }
     [200, "OK", $args{-reverse} ? $n/$m : $n*$m];
 }

=head2 undo => BOOL|HASHREF

Default is false. If set to true, specifies that subroutine supports undo
operation. Undo is similar to 'reverse' but needs some state to be saved and
restored for do/undo operation, while reverse can work solely from the
arguments.

Caller must provide one or more special arguments: -undo_action, -undo_hint,
-undo_data when dealing with do/undo stuffs.

To perform normal operation, caller must set -undo_action to 'do' and optionally
pass -undo_hint for hints on how to save undo data. You should consult each
function's documentation as undo hint depends on each function (e.g. if
undo_data is to be saved on a file, -undo_hint can contain filename or base
directory). Function must save undo data, perform action, and return result
along with saved undo data in the response metadata (4th argument of response),
example:

 return [200, "OK", $result, {undo_data=>$undo_data}];

Undo data should contain information (or reference to information) to restore to
previous state later. This information should be persistent (e.g. in a
file/database) when necessary. For example, if undo data is saved in a file,
undo_data can contain the filename. If undo data is saved in a memory structure,
undo_data can refer to this memory structure, and so on. Undo data should be
serializable. Caller should store this undo data in the undo stack (note: undo
stack management is the caller's task).

If -undo_action is false/undef, sub must assume caller want to perform action
but without saving undo data.

To perform an undo, caller must set -undo_action to 'undo' and pass back the
undo data in -undo_data. Sub must restore previous state using undo data (or
return 412 if undo data is invalid/unusable). After a successful undo, sub must
return 200. Sub should also return undo_data, to undo the undo (effectively,
redo):

 return [200, "OK", undef, {undo_data=>...}];

Example (in this example, undo data is only stored in memory):

 use Cwd qw(abs_path);
 use File::Slurp;

 $SPEC{lc_file} = {
     summary  => 'Convert the *content* of file into all-lowercase',
     args     => {path=>'str*'},
     features => {undo=>1},
 };
 sub lc_file {
     my %args        = @_;
     my $path        = $args{path};
     my $undo_action = $args{-undo_action} // '';
     my $undo_data   = $args{-undo_data};

     $path = abs_path($path)
         or return [500, "Can't get file absolute path"];

     if ($undo_action eq 'undo') {
         write_file $path, $undo_data->{content}; # restore original content
         utime undef, $undo_data->{mtime}, $path; # as well as original mtime
         return [200, "OK"];
     } else {
         my @st = stat($path)
             or return [500, "Can't stat file"];
         my $content = read_file($path);
         my $undo_data = {mtime=>$st[9], content=>$content};
         write_file $path, lc($content);
         return [200, "OK", undef, {undo_data=>$undo_data}];
     }
 }

To perform action, caller calls lc_file() and store the undo data:

 my $res = lc_file(path=>"/foo/bar", -undo_action=>"do");
 die "Failed: $res->[0] - $res->[1]" unless $res->[0] == 200;
 my $undo_data = $res->[3]{undo_data};

To perform undo:

 $res = lc_file(path=>"/foo/bar", -undo_action=>"undo", -undo_data=>$undo_data);
 die "Can't undo: $res->[0] - $res->[1]" unless $res->[0] == 200;

=head2 dry_run => 1

Specifies that subroutine supports dry-run (simulation) mode. Example:

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

=head2 pure => 1

Specifies that subroutine is "pure" and has no "side effects" (these are terms
from functional programming / computer science). Having a side effect means
changing something, somewhere (e.g. setting the value of a global variable,
modifies its arguments, writing some data to disk, changing system date/time,
etc.) Specifying a function as pure means, among others:

=over 4

=item * the function needs not be involved in undo operation;

=item * you can safely include it during dry run;

=back

=head1 TODO

transaction/atomicity

i18n (is translatable, supported languages, locales)

progress bar/estimated duration (we can query each sub how long would an action
takes beforehand, or caller pas a callback that gets called multiple times to
update progress bar)

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

