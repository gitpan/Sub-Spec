package Sub::Spec;
BEGIN {
  $Sub::Spec::VERSION = '0.08';
}
# ABSTRACT: Subroutine metadata & wrapping framework

use 5.010;
use strict;
use warnings;

#use Data::Sah;
#use Sub::Install;

1;


=pod

=head1 NAME

Sub::Spec - Subroutine metadata & wrapping framework

=head1 VERSION

version 0.08

=head1 SYNOPSIS

In your module:

 package MyModule;

 use 5.010;
 use strict;
 use warnings;

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

Use your subs in Perl scripts/modules:

 package MyApp;
 use 5.010;
 use Sub::Spec;
 use MyModule qw(pow);
 my $res;

 # schema checking (NOT WORKING YET)
 #$res = pow(base => 1);   # [400, "Missing argument: exp"]
 #$res = pow(base => "a"); # [400, "Invalid argument: base must be a float"]

 $res = pow(base => 2, exp=>10); # [200, "OK", 1024]
 say $res->[2];

Use positional arguments (NOT WORKING YET):

 use MyModule pow => {args_positional=>1};
 $res = pow(2, 10); # [200, "OK", 1024]

Return data only instead of with status code + message (NOT WORKING YET):

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

Create HTTP REST API from your subs (NOT WORKING YET, see L<Sub::Spec::HTTP> for
more details):

 % cat apid.pl
 #!/usr/bin/perl
 use Sub::Spec::HTTP qw(run);
 run(port=>8000, module=>"MyModule", sub=>"pow");

 $ curl http://localhost:8000/api/MyModule/pow?base=2&exp=10
 1024

=head1 DESCRIPTION

NOTE: This module is still very early in development. Most of the features are
not even implemented yet.

Subroutines are an excellent unit of reuse, in some ways they are even superior
to objects (simpler, map better to HTTP/network programming due to being
stateless, etc). Sub::Spec aims to make your subs much more useful, reusable,
powerful. All you have to do is provide some metadata (a spec) for your sub. See
L<Sub::Spec::Manual::Spec> for more details about sub spec.

Below are the features provided by Sub::Spec:

=over 4

=item * fast and flexible parameter checking

See L<Sub::Spec::Clause::args> and L<Sub::Spec::Clause::result> for more
details.

=item * positional as well as named arguments calling style

See the export clause B<-args_positional> in L<Sub::Spec::Exporter>.

=item * flexible exporting

See L<Sub::Spec::Exporter>.

=item * easy switching between exception-based and return-code error handling

See the export clause B<-exception> in L<Sub::Spec::Exporter>.

=item * command-line access

You can basically turn your subs into a command-line program with a single line
of code, complete with argument processing, --help, pretty-printing of output,
and bash tab-completion. See L<Sub::Spec::CmdLine> for more information.

=item * HTTP REST access

Creating an API from your subs is dead easy. See L<Sub::Spec::HTTP>.

=item * generation of API documentation (POD, etc)

See L<Sub::Spec::Pod> on how to generate POD and L<Pod::Weaver::Plugin::SubSpec>
on how to do this when building dist with L<Dist::Zilla>.

See gen_usage() in L<Sub::Spec::CmdLine> to generate text help message.

=item * execution time limits

See L<Sub::Spec::Clause::timeout>.

=item * automatic retries

See L<Sub::Spec::Clause::retry>.

=item * logging

=item * and more ...

=back

=head1 CLAUSES

Here are the general clauses. For the rest of the clauses see respective
Sub::Spec::Clause::<CLAUSE_NAME>, e.g. L<Sub::Spec::Clause::args>, etc.

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

=head1 FAQ

See L<Sub::Spec::Manual::FAQ>

=head1 SEE ALSO

=head2 Modules used

L<Data::Sah> for schema checking.

L<Log::Any> for logging.

=head2 Alternative modules

If you just want to give named arguments, you might want to consider
L<Sub::NamedParams>.

You can check out L<Sub::Attempts> for retries.

There are a gazillion modules for parameter checking. L<Data::Sah> lists a few
of them.

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

