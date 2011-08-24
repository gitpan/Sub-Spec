package Sub::Spec;

our $VERSION = '0.15'; # VERSION

use 5.010;
use strict;
use warnings;

1;
# ABSTRACT: Subroutine metadata & wrapping framework


=pod

=head1 NAME

Sub::Spec - Subroutine metadata & wrapping framework

=head1 VERSION

version 0.15

=head1 SYNOPSIS

Write your subroutine and add a metadata ($SPEC{subname}):

 package MyModule;

 use 5.010;
 use strict;
 use warnings;

 use Sub::Spec::Exporter ...;

 our %SPEC;
 $SPEC{pow} = {
     summary     => 'Exponent a number',
     description => <<'_',
...
_
     args        => {
         base => [float => {summary=>"Base number", required=>1, arg_pos=>0}],
         exp  => [float => {summary=>"Exponent"   , required=>1, arg_pos=>1}],
     },
 };
 sub pow {
     my (%args) = @_;
     return [200, "OK", $arg{base} ** $arg{exp}];
 }

Use your sub:

 package MyApp;
 use 5.010;
 use Sub::Spec;
 use MyModule qw(pow);
 my $res;

 # schema checking (NOT YET IMPLEMENTED)
 #$res = pow(base => 1);   # [400, "Missing argument: exp"]
 #$res = pow(base => "a"); # [400, "Invalid argument: base must be a float"]

 $res = pow(base => 2, exp=>10); # [200, "OK", 1024]
 say $res->[2];

Use positional arguments (NOT YET IMPLEMENTED):

 use MyModule pow => {args_as=>'ARRAY'};
 $res = pow(2, 10); # [200, "OK", 1024]

Return data only instead of with status code + message (NOT YET IMPLEMENTED):

 use MyModule pow => {result_naked=>1};

 say pow(base=>2, exp=>10); # 1024
 say pow(base=>2); # now throws exception due to missing required arg 'exp'

Use your subs from the command line (see L<Sub::Spec::CmdLine> for more
details):

 % cat script.pl
 #!/usr/bin/perl
 use Sub::Spec::CmdLine qw(run);
 run(module=>"MyModule", sub=>"pow");

 % script.pl --help
 (Usage message ...)

 % script.pl --base 2 --exp 10
 1024

 % script.pl 2 10
 1024

 % script.pl 2
 Error: Missing required argument exp

Create HTTP REST API from your subs (see L<Sub::Spec::HTTP::Server> and
L<Sub::Spec::HTTP::Client> for more details):

 % cat apid.psgi
 #!/usr/bin/perl
 use Sub::Spec::HTTP::Server;
 use My::Module1;

 my $app = sub {
     Sub::Spec::HTTP::Server->psgi_app();
 };

 % plackup apid.psgi

and then you can do:

 % curl 'http://localhost:5000/MyModule/pow?base=2&exp=10'
 [200,"OK",1024]

=head1 DESCRIPTION

Subroutines are an excellent unit of reuse; in some ways they are even superior
to objects (simpler, map better to HTTP/network programming due to being
stateless, etc). Sub::Spec aims to make your subs much more useful, reusable,
powerful. All you have to do is provide some metadata (a "spec") for your subs
(see L<Sub::Spec::Manual::Spec> for a full description of the spec), and then
there will be a family of modules doing useful things for you.

Below are the features provided by Sub::Spec:

=over 4

=item * fast and flexible parameter checking

See L<Sub::Spec::Clause::args> and L<Sub::Spec::Clause::result> for more
details.

=item * positional as well as named arguments calling style

See the export clause B<-args_as> in L<Sub::Spec::Exporter>.

=item * flexible exporting

See L<Sub::Spec::Exporter>.

=item * easy switching between exception-based and return-code error handling

See the export clause B<-exception> in L<Sub::Spec::Exporter>.

=item * command-line access

You can basically turn your subs into a command-line program with a single line
of code, complete with argument processing, --help, pretty-printing of output,
and bash tab-completion. See L<Sub::Spec::CmdLine> for more information.

=item * HTTP REST access

Creating an API from your subs is dead easy. See L<Sub::Spec::HTTP::Server>.

=item * generation of API documentation (POD, etc)

See L<Sub::Spec::To::Pod> on how to generate POD for your functions and
L<Pod::Weaver::Plugin::SubSpec> on how to do this when building dist with
L<Dist::Zilla>.

There is also L<Sub::Spec::To::Text>, used by L<Sub::Spec::CmdLine> to generate
text help message (--help / usage), and other format exporters like
L<Sub::Spec::To::HTML> and L<Sub::Spec::To::Org>.

=item * execution time limits

See L<Sub::Spec::Clause::timeout>.

=item * automatic retries

See L<Sub::Spec::Clause::retry>.

=item * logging

=item * a simple undo framework

See L<Sub::Spec::Clause::features> ('undo' feature). Also see the 'reverse'
feature for even simpler mechanism, if your sub applies.

=item * and more ...

More useful and interesting things to come.

=back

=head1 WHAT ALREADY WORKS AND WHAT HAS NOT

While the Sub::Spec specification is stabilizing, implementation-wise there are
still key components that are missing. L<Sub::Spec::Wrapper>, the main meat, has
not been written, so almost all extra sub functionalities do not work yet (this
include argument validation, timeouts and retries, conversion of argument style,
etc). For example, right now I still check my arguments manually, but this
portion of the code can be removed later when the wrapper is ready.

What already works?

=over 4

=item * command-line access

=item * exporting sub specs to text/html/org/pod

=item * dependency checking (see L<Sub::Spec::Runner>)

=item * HTTP API stuffs

=back

See L</"MODULES FAMILY"> for more details.

=head1 CLAUSES

Here are the general clauses of the spec. For the rest of the clauses see
respective Sub::Spec::Clause::<CLAUSE_NAME>, e.g. L<Sub::Spec::Clause::args>,
etc.

=over 4

=item * name

The name of the subroutine. Useful for generating help/usage information, or
when aliasing subroutines (and reusing the spec) and finding out the
canonical/original name of the subroutine.

=item * summary

A one-line summary. It should be plain text without any markup.

=item * description

A longer description. Currently the format of the text inside is not yet
specified. It is probably going to be Markdown, not POD/HTML.

=back

Sub::Spec is extensible, you can add your own clauses (see
L<Sub::Spec::Manual::Spec> for more information).

=head1 MODULES FAMILY

Below is the namespace organization and list of Sub::Spec modules/distributions
family.

=over 4

=item * Sub::Spec

The main module, contains specification, general documentation, and current best
practice.

=item * L<Sub::Spec::Schema>

This module name is reserved, it will contain the L<Data::Sah>'s schema for the
sub spec, so you can validate your sub specs with it.

Not yet implemented.

=item * L<Sub::Spec::Wrapper>

The module that actually generates the wrapper code for subroutines (including
code for validating arguments and all the other code necessary to implement the
other spec clauses). Normally, it will be used through Sub::Spec::Exporter or
some kind of invoker in your module.

Not yet implemented.

=item * L<Sub::Spec::Exporter>

The exporter to be used by modules containing spec'ed functions, instead of,
say, L<Exporter> or L<Sub::Exporter>. It will have some advantages like the
ability to parse sub specs (e.g. for export tags), generation of wrapper code,
etc.

Not yet implemented. For now I personally still use the good ol' Exporter. As a
recommended best practice, do not export anything by default. Put everything
worth exporting into @EXPORT_OK.

=item * Sub::Spec::GetArgs::*

These modules, normally with the help of sub spec, parse some form of input into
subroutine arguments (%args). Example modules: L<Sub::Spec::GetArgs::Argv> (from
@ARGV), L<Sub::Spec::GetArgs::GetPost> (from HTTP GET/POST request data), or
L<Sub::Spec::GetArgs::PathInfo> (from CGI/PSGI's PATH_INFO).

Someday I also plan to write L<Sub::Spec::GetArgs::Console> to get args from
interactive console prompts.

I also envision something like getting args from a GUI/TUI dialog.

=item * Sub::Spec::To::*

These modules convert (export) sub spec to various other outputs, example:
L<Sub::Spec::To::Pod> (e.g. the generated POD is to be inserted into Perl module
files; see L<Pod::Weaver::Plugin::SubSpec>), L<Sub::Spec::To::Text> (e.g. for
generating --help/usage message), L<Sub::Spec::To::HTML> and
L<Sub::Spec::To::Org> (e.g. to generate API documentation).

=item * L<Sub::Spec::Runner>

With Sub::Spec you can specify dependencies between subs (and to external
objects like an OS software package, a binary, etc). This module can be used to
check dependencies before running your sub, as well as running several subs in
custom order.

=item * L<Sub::Spec::CmdLine>

This module provides an easy way to execute your subs from the command line, and
even provides extra support like bash completion. Internally, it is just a
composition of Sub::Spec::GetArgs::Argv, Sub::Spec::Runner,
Sub::Spec::BashComplete.

=item * Sub::Spec::Gen:*

These modules generate sub spec (and/or the sub code) from some other, probably
higher-level or more abstract, specification. Example:
L<Sub::Spec::Gen::ReadTable>.

Someday I also plan to write L<Sub::Spec::Gen::ReadTable::SQL>, to generate
table access functions from a SQL database table.

=item * L<Sub::Spec::Caller>

A helper module to load wanted module and call its sub, but with some options.
See its documentation for more details.

=item * L<Sub::Spec::BashComplete>

A helper module for Sub::Spec::CmdLine, to provide bash completion for programs
using spec'ed functions.

=item * Sub::Spec::HTTP::*

These modules all relate to providing remote sub call access via HTTP.

L<Sub::Spec::HTTP::Server> serves sub call requests via HTTP; it is a PSGI
application. There are also several middleware in Sub::Spec::HTTP::Middleware::*
to provide functionalities like authentication/authorization. Suitable for
providing remote API access.

You can call any HTTP client to use the API service built using the tool
mentioned above, but L<Sub::Spec::HTTP::Client> provides some convenience and
options.

=item * Sub::Spec::Loader::*

Reserved for modules that load sub spec from some sources (e.g. Perl modules
require()'d, files/databases, or whatever).

=item * Sub::Spec::OO

Reserved for module that provides an OO-interface to sub spec, to query its
(meta)data.

=item * Sub::Spec::?

Reserved for modules that do some kind of transformation/modification to sub
specs.

But honestly, since sub specs are just data structures, you can use whatever
tool you want to transform them.

=back

=head1 FAQ

See L<Sub::Spec::Manual::FAQ>

=head1 SEE ALSO

=head2 Example applications/modules

The following applications/modules, among others, are already using Sub::Spec to
varying degrees:

=over 4

=item * L<File::RsyBak>, L<Git::Bunch>, L<Org::Parser>

Uses Sub::Spec::CmdLine to easily turn the subs into command-line app. Generates
POD documentation from sub specs.

=item * Setup:: modules family, e.g. L<Setup::Symlink>, L<Setup::File>.

Uses the undo framework and dry-run feature. Generates POD documentation from
sub specs.

=item * L<Array::Find>, L<Parse::PhoneNumber::ID>

Generates POD documentation from sub specs.

=back

=head2 Modules used

L<Data::Sah> for schema checking.

L<Log::Any> for logging.

=head2 Alternative modules

If you just want to give named arguments, you might want to consider
L<Sub::NamedParams>.

You can check out L<Sub::Attempts> for retries.

There are a gazillion modules for parameter checking. L<Data::Sah> lists a few
of them.

=head2 Related non-Perl resources

Python Decorators, http://www.python.org/dev/peps/pep-0318/ ,
http://wiki.python.org/moin/PythonDecorators .

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

