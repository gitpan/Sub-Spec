package Sub::Spec;
BEGIN {
  $Sub::Spec::VERSION = '0.01';
}
# ABSTRACT: Add spec to your subs so it can be more useful/reusable

use 5.010;
use strict;
use warnings;

#use Data::Sah;
#use Sub::Install;

1;


=pod

=head1 NAME

Sub::Spec - Add spec to your subs so it can be more useful/reusable

=head1 VERSION

version 0.01

=head1 SYNOPSIS

In your module:

 package MyModule;

 use 5.010;
 use strict;
 use warnings;

 our %SUBS;
 $SUBS{pow} = {
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

Use positional arguments (NOT WORKING YET, SPEC NOT EVEN FINALIZED):

 use YourModule pow => {positional=>1};
 $res = pow(2, 10); # [200, "OK", 1024]

Return data only instead of with status code + message (NOT WORKING YET):

 use YourModule pow => {unwrap=>1};

 say pow(base=>2, exp=>10); # 1024
 say pow(base=>2); # now throws exception due to missing required arg 'exp'

Use your subs from the command line:

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

Create HTTP REST API from your subs (NOT WORKING YET, SPEC NOT FINALIZED YET):

 % cat apid.pl
 #!/usr/bin/perl
 use Sub::Spec::HTTPD qw(run);
 run(port=>8000, module=>"MyModule", sub=>"pow");

 $ curl http://localhost:8000/api/MyModule/pow?base=2&exp=10
 1024

=head1 DESCRIPTION

NOTE: This module is still very early in development. Most of the features are
not even implemented yet.

Subroutines are an excellent unit of reuse, in some ways they are even superior
to objects (they are simpler, map better to HTTP/network programming due to
being stateless, etc). Sub::Spec aims to make your subs much more useful,
reusable, powerful. All you have to do is provide some metadata (a spec) for
your sub and follow some simple conventions, explained below in L</"HOW TO
USE">.

Below are the features provided by Sub::Spec:

=over 4

=item * fast and flexible parameter checking

See L<Sub::Spec::args> and L<Sub::Spec::return> for more details.

=item * positional as well as named arguments calling style

See the export clause B<-positional> in L<Sub::Spec::Exporter>.

=item * flexible exporting

See L<Sub::Spec::Exporter>.

=item * easy switching between exception-based and return-code error handling

See the export clause B<-positional> in L<Sub::Spec::Exporter>.

=item * command-line access

You can basically turn your subs into a command-line program with a single line
of code, complete with argument processing, --help, pretty-printing of output.
See L<Sub::Spec::CmdLine> for more information.

=item * HTTP REST access

Creating an API from your subs is dead easy. See L<Sub::Spec::HTTPD>.

=item * generation of API documentation (POD, etc)

See L<Sub::Spec::Pod> on how to generate POD, see gen_usage() in
L<Sub::Spec::CmdLine> to generate text help message.

=item * execution time limits

See L<Sub::Spec::timeout>.

=item * automatic retries

See L<Sub::Spec::retry>.

=item * logging

=item * and more ...

The Sub::Spec framework is extensible, you can add more clauses easily. See
L<Sub::Spec::Manual::Extension>.

=back

Despite all this, there is virtually no unnecessary cost to bear if you do not
want some/any of the features Sub::Spec provides. If Sub::Spec is not loaded,
your subs behaves 100% like a normal Perl subroutine.

=head1 HOW TO USE

=head2 Prepare a spec

Sub spec is a hashref, typically put inside package global hash %SUBS.

XXX

=head2 Accept named arguments (in hash)

That is, do this:

 my %args = @_;

instead of:

 my ($arg1, $arg2, $arg3) = @_;

Named arguments can stand refactoring/API changes better, they are scalable to
tens or more arguments, the names can be used by API/command line arguments,
etc. You can use positional arguments when calling your sub using the
B<positional> clause.

=head2 Return [errcode, errmsg, data]

Instead of returning just data, always return at least these 3 pieces of
information.

See XXX.

That's it.

=head1 FAQ

XXX

=head1 SEE ALSO

=head2 Modules used

L<Data::Sah> for schema checking.

L<Log::Any> for logging.

L<Sub::Install> to wrap subroutines.

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

