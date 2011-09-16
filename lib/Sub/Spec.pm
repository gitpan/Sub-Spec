package Sub::Spec;

our $VERSION = '1.0.3'; # VERSION

our $SPEC_VERSION = [1, 0];

1;
# ABSTRACT: Subroutine metadata specification


__END__
=pod

=head1 NAME

Sub::Spec - Subroutine metadata specification

=head1 VERSION

version 1.0.3

=head1 SPEFICATION VERSION

 [1, 0]

=head1 ABSTRACT

This document specifies Sub::Spec metadata for subroutines (and methods).
Sub::Spec is a language-neutral specification to describe various aspects of a
subroutine. The goal is to make subroutine, which is the unit of reuse in many
programming languages, more reusable and powerful.

=head1 SPECIFICATION

=head2 Sub spec

A sub spec (short for specification) is a hash containing certain keys, the keys
being called clauses. There are a set of known clauses specified. A spec is
valid if it contains only known clauses and each clause is valid.

Normally a spec is created for each subroutine and placed alongside the code.
For example, in Perl the spec is normally put in the C<%SPEC> package variable:

 package MyPackage;
 our %SPEC;

 $SPEC{func1} = { ... }; # specification for func1()
 sub func1 {
     ...
 }

 $SPEC{func2} = { ... }; # specification for func2()
 sub func2 {
     ...
 }

and so on.

=head2 What can spec do for sub?

In Perl, there is a growing list of Perl modules (in the Sub::Spec::* namespace)
which can utilize the information in the spec. For example:

=over 4

=item *

L<Sub::Spec::Wrapper>: wraps subroutines and implement many of the clauses (e.g.
validate arguments specified in C<args> clause, implement C<timeout> clause
using alarm() and eval block, etc).

=item *

L<Sub::Spec::Exporter>: can be used to replace L<Exporter> or L<Sub::Exporter>,
automatically wrap subroutines when exporting.

=item *

Sub::Spec::To::* modules: can generate documentation of various formats from
spec, like a text usage (which one would normally see when giving --help
argument to a command-line program).

=item *

L<Sub::Spec::CmdLine>: run subroutines from the command line. Supply sub
arguments from command line options.

=item *

L<Sub::Spec::HTTP::Server>: serves subroutine call requests over HTTP.

=back

Hopefully there will be implementations to in other languages.

=head2 Sub

Any Perl subroutine can be given sub spec, but it needs to accept hash (named)
arguments and return a sub response (explained below), unless C<args_as> in spec
is 'array' and C<result_naked> is set to 1.

 sub foo {
     my %args = @_; # accept hash/named arguments
     ...
     return [200, "OK", $data]; # return sub response instead of just data
 }

=head2 Sub response

A sub response is a 2+-element arrayref:

 [STATUS, MESSAGE, DATA, METADATA]

STATUS is an integer number between 200-599, analogous to HTTP response code
(see L</"Response status"> for more details on the codes). MESSAGE is a string
(or object) containing error message. DATA contains the result, and is optional.
METADATA is a hashref containing metadata (analogous to HTTP response headers),
is optional and seldom used.

This way, a subroutine can conveniently return error/status message as well as
data. Also, since the codes are the same as in HTTP, converting to HTTP messages
is straightforward.

=head2 Response status

=over 4

=item * 1xx code

Currently not used.

=item * 2xx code

200 should be used to mean success.

206 can be used to signal partial content, for example: a read_file() sub which
accepts 'byte_start' and 'byte_end' arguments should return 206 when only
partial file content is returned. But in general, use 200 as some clients will
simply check for this exact code (instead of checking for range 200-299).

=item * 3xx code

301 (moved) can be used to redirect clients to alternate location, though I
haven't used it yet.

304 (not modified, nothing done). Used for example by setup subroutines to
indicate that nothing is being modified (see Setup::* modules in CPAN).

=item * 4xx code

400 (bad request, bad arguments) should be returned when the sub encountered
invalid input (arguments). The wrapper code will return this code when arguments
fail schema validation.

403 (forbidden, access denied).

404 not found. Can be used for example: a get_user() sub which accepts
username/userid argument and when the user is not found.

Note: In general, a delete_object() sub should return 200 (or perhaps 304, but
200 is preferred) instead of 404 when the object specified by the user is not
found, since the goal of the delete function is reached anyway.

408 (request timeout)

409 (conflict) can be used, for example: a create_user() function when receiving
an already existing username.

412 (precondition failed).

=item * 5xx code

500 is the general code to use when a failure occurs during the execution of
sub. For example, when a delete_file() sub fails to delete specified file
(though it can return 403 which is more specific).

501 (not implemented)

503 (service unavailable)

507 (insufficient storage)

53x (bad spec) is used when there is something wrong with the spec.

=back

=head2 Clauses

A clause must be of lowercase letters, numbers, or underscores. The next
sections describe known clauses. A specific application/project can add to this
list, but in general it is advisable to stick with the standard.

=head2 Clause: type => STR (default 'sub')

Type of subroutine. Either 'sub' for normal subroutine, 'method' for object
method (class instance method), or 'class_method' for class method.

=head2 Clause: scope => STR (default 'public')

Subroutine scope. Either 'public' or 'private'.

=head2 Clause: name => STR

The name of the subroutine. Useful for generating help/usage information, or
when aliasing subroutines (and reusing the spec) and finding out the
canonical/original name of the subroutine.

=head2 Clause: summary => STR

A one-line summary. It should be plain text without any markup. It is like the
C<summary> Data::Sah clause.

=head2 Clause: description => STR

A longer description. It should be text in Org format. See http://orgmode.org/
for details on the Org format. It is like the C<description> Data::Sah clause.

=head2 Clause: timeout => NUM

A number (in seconds), specifying execution time limit.

=head2 Clause: args => HASHREF

Args is a hash of argument names and schemas. Argument must only contain
letters, numbers, and underscores. Schemas are L<Data::Sah> schema. Example:

 args => {
     a => 'str*',
     b => ['int*' => {
         summary => 'The second argument',
         description => '... a longer description ...',
         min => 0,
         max => 100,
         ... # other schema clauses for 'int'
     }],
 }

Sub::Spec adds a few schema clauses:

=over 4

=item * arg_pos => INT, 0+

Specify the order of argument when specified in a positional order. Example:

 $SPEC{multiply2} = {
     summary => 'Multiple two numbers (a & b)',
     args    => {
         a      => ['num*' => {arg_pos=>0}],
         b      => ['num*' => {arg_pos=>1}],
         digits => 'int',
     },
 }

This allows calling using named arguments as well as positional:

 multiply2(a=>4, b=>3);
 multiply2(4, 3); # after being wrapped

 # In command line:
 % cmd --a 2 --b 3
 % cmd 2 --b 3
 % cmd 2 3

=item * arg_greedy => BOOL

Specify whether, in positional arguments, this argument should gobble up the
rest of the arguments into array.

Example:

 $SPEC{multiply} = {
     summary => 'Multiple numbers',
     args    => {
         nums   => ['num*[]*' => {arg_pos=>0, arg_greedy=>1, min_len=>1}],
     },
 }
 sub multiply {
     my %args = @_;
     my $nums = $args{nums};

     my $ans = 1;
     $ans *= $_ for @$nums;
     [200, "OK", $ans];
 }

In positional mode it can then be called:

 multiply(2, 3, 4);

which is the same as (in normal named-argument style):

 multiply(nums => [2, 3, 4]);

In command-line:

 % cmd 2 3 4

instead of:

 % cmd --nums '[2, 3 ,4]'

=item * arg_complete => CODEREF

Specifies how to complete argument value. CODEREF will be given arguments:
word=>..., args=>.... and should return an arrayref containing a list of
possible candidates. For an example of implementation for this, see
L<Sub::Spec::BashComplete> to provide tab completion for argument value.
Example:

 $SPEC{delete_user} = {
    args => {
        username => ['str*' => {
            arg_complete => sub {
                my %args = @_;
                my $word = $args{word} // "";

                # find users beginning with $word
                local $CWD = "/home";
                return [grep {-d && $_ ~~ /^\Q$word/} <*>];
            },
        }],
    },
 };

=back

=head2 Clause: required_args => LIST

List of argument names that are required.

=head2 Clause: args_as => STR (default 'hash')

Specify what kind of arguments sub accepts. The default is 'hash', which means
arguments will be passed as %args into Perl subroutines. The other options are
'hashref', 'array', 'arrayref', 'object'.

Setting args_as to 'array' is useful if you have a "legacy" sub which accepts
arguments directly from @_, like most normal Perl subroutines.

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

Setting args_as to 'object' is useful if you want to catch typo mistakes in your
subs:

 package My::Palindrome;
 $SPEC{is_palindrome} = {
     summary => 'Check whether a string is a palindrome',
     args    => {str => 'str*', ci=>[bool=>{default=>0}]},
     args_as => 'object',
     result  => 'bool*',
 };
 sub is_palindrome {
     my $args = shift;
     my $str  = $args->str;
     $str = lc($str) if $args->ci;
     [200, "OK", $str eq reverse($str) ? 1:0];
 }

How this works: The wrapper (e.g. L<Sub::Spec::Wrapper) will create a class for
this argument, with accessors. Special arguments are accessed via _NAME (like
$args->_undo_action, $args->_reverse, etc) so make sure you do not define
arguments with those names if you want to use object argument passing.

=head2 Clause: result => SCHEMA

The 'result' clause specifies sub's result value. The value of the clause is a
Sah schema.

Note that since 'result_naked' by default is false, instead of just returning:

 RESULT

you'll normally have to return a proper response sub:

 [STATUS, MESSAGE, RESULT]

Example:

 # result is an integer
 result => 'int*'

 # result is an integer starting from zero
 result => ['int*' => {ge=>0}]

 # result is an array of records
 result => ['array*' => {
             summary => 'blah blah blah ...',
             of      => ['hash*' => {allowed_keys=>[qw/name age address/]} ]
           }]

=head2 Clause: result_naked => BOOL (default 0)

Setting 'result_naked' to 1 is useful if you have a "legacy" sub which does not
return sub response. Example:

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
     summary      => 'Check whether a string is a palindrome',
     args         => {str => 'str*'},
     result       => 'bool*',
     result_naked => 1,
 };
 sub is_palindrome {
     my %args = @_;
     my $str  = $args{str};
     $str eq reverse($str);
 }

=head2 Clause: retry => INT

Specify automatic retry upon failure. Not yet specified.

=head2 Clause: features => HASHREF

The C<features> clause allows subroutines to express their features. Each hash
key contains feature name, which must only contain letters/numbers/underscores.

Below is the list of defined features. New feature clause may be defined by
extension.

=over 4

=item * reverse => BOOL (default 0)

If set to true, specifies that subroutine supports reverse operation. To
reverse, caller can add special argument '-reverse'. For example:

 $SPEC{triple} = {args=>{num=>'num*'}, features=>{reverse=>1}};
 sub triple {
     my %args = @_;
     my $num  = $args{num};
     [200, "OK", $args{-reverse} ? $num/3 : $num*3];
 }

 triple(num=>12);              # => 36
 triple(num=>12, -reverse=>1); # =>  4

PLANNED: Conditional reversibility.

=item * undo => BOOL

If set to true, specifies that subroutine supports undo operation. Undo is
similar to 'reverse' but needs some state to be saved and restored for do/undo
operation, while reverse can work solely from the arguments.

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

=item * dry_run => BOOL

If set to 1, specifies that subroutine supports dry-run (simulation) mode.
Example:

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

=item * pure => BOOL

If set to true, specifies that subroutine is "pure" and has no "side effects"
(these are terms from functional programming / computer science). Having a side
effect means changing something, somewhere (e.g. setting the value of a global
variable, modifies its arguments, writing some data to disk, changing system
date/time, etc.) Specifying a function as pure means, among others:

=over 4

=item * the function needs not be involved in undo operation;

=item * you can safely include it during dry run;

=back

=back

=head2 Clause: deps => HASHREF

This clause specifies subroutine's dependencies. It is a hashref of dep clause
names and values. Some dep clauses are special: C<all>, C<any>, and C<none>.

 deps => {
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

A dependency can be anything: another subroutine, Perl version and module,
environment variables, program, etc. It is up to the dependency checker library
to make use of this information.

For the dependencies to be declared as satisfied, all of the clauses must be
satisfied.

Below is the list of defined dependency clauses. New dependency clause may be
defined by an extension.

=over 4

=item * sub => STR

Require that subroutine exists. STR is the name of the subroutine and will be
assumed to be in the 'main' package if unqualified.

Example:

 sub => 'foo'   # == main::foo
 sub => '::foo' # == main::foo
 sub => 'Package::foo'

=item * mod => STR

Require that module is loadable. Example:

 mod => 'Moo'

=item * env => STR

Require that an environment variable exists and has a true value. Example:

 env => 'HTTPS'

=item * exec => STR

Require that an executable exists. If STR doesn't contain path separator
character '/' it will be searched in PATH.

 exec => 'rsync'   # any rsync found on PATH
 exec => '/bin/su' # won't accept any other su

=item * code => CODEREF

Require that CODEREF returns a true value after called. Example:

 code => sub {$>}  # i am not being run as root

=item * all => [DEPCLAUSES, ...]

A "meta" clause that allows several dependencies to be joined together in a
logical-AND fashion. All dependencies must be satisfied. For example, to declare
a dependency to several subroutines:

 all => [
     {sub => 'Package::foo1'},
     {sub => 'Package::foo2'},
     {sub => 'Another::Package::bar'},
 ],

=item * any => [DEPCLAUSES, ...]

Like C<all>, but specify a logical-OR relationship. Any one of the dependencies
will suffice. For example, to specify requirement to alternative modules:

 or => [
     {mod => 'HTTP::Daemon'},
     {mod => 'HTTP::Daemon::SSL'},
 ],

=item * none => [DEPCLAUSES, ...]

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

=back

=head2 Special arguments

These are arguments prefixed by - (dash) that have special meanings.

=head1 SEE ALSO

L<Data::Sah>

Python Decorators, http://www.python.org/dev/peps/pep-0318/ ,
http://wiki.python.org/moin/PythonDecorators .

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

