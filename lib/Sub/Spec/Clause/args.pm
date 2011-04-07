package Sub::Spec::Clause::args;
BEGIN {
  $Sub::Spec::Clause::args::VERSION = '0.11';
}
# ABSTRACT: Schema for subroutine parameters

1;


=pod

=head1 NAME

Sub::Spec::Clause::args - Schema for subroutine parameters

=head1 VERSION

version 0.11

=head1 SYNOPSIS

NOT IMPLEMENTED YET.

In your spec:

 args => {
   # ARG_NAME => SCHEMA
   num => ['int*' => {arg_pos=>0, min=>0, divisible_by=>2}],
   ...
 },
 required_args => [qw/num/],

In your caller:

 use Sub::Spec;
 use MyModule qw(mysub);

 my $res;
 $res = mysub();        # error 400: missing argument num
 $res = mysub(num=>-1); # error 400: number must be >= 0

=head1 DESCRIPTION

B<args> defines schema for each known argument. Schema language is L<Data::Sah>.

B<required_args> lists which argument is available. In most cases you do not
need this spec clause, except when you want to allow an argument value to be
undef, but you want to require that it is specified:

 func(arg => undef); # arg is specified, but value is undef, OK.
 func();             # arg is not specified, ERROR

In that case, your spec will be something like this:

 args          => { arg => 'any' }, # arg value is not required
 required_args => [qw/arg/],

=head1 ARGUMENT CLAUSES

Since each argument is a Sah schema, all Sah type clauses are allowed. But there
are several type clauses added specific to arguments:

=head2 arg_pos => INT, 0+

Specify the order of argument when specified in a positional order. Utilized by
L<Sub::Spec::Exporter> and L<Sub::Spec::CmdLine> to parse positional arguments.
Example:

 $SPEC{multiply2} = {
     summary => 'Multiple two numbers (a & b)',
     args    => {
         a      => ['num*' => {arg_pos=>0}],
         b      => ['num*' => {arg_pos=>1}],
         digits => 'int',
     },
 }

In the caller package, if they export as positional:

 use Sub::Spec;
 use MyModule multiply2 => {-positional=>1};

then they can do:

 multiply2(2, 3)

instead of the normally:

 multiple(a=>2, b=>3)

And in the command-line, any of below is allowed:

 % cmd --a 2 --b 3
 % cmd 2 --b 3
 % cmd 2 3

=head2 arg_greedy => BOOL

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

which is the same as (in normal named mode):

 multiply(nums => [2, 3, 4]);

In command-line:

 % cmd 2 3 4

instead of:

 % cmd --nums '[2, 3, 4]'

=head2 arg_complete => CODEREF

Specifies how to complete argument value. CODEREF will be given arguments:
word=>..., args=>.... and should return an arrayref containing a list of
possible candidates. Used for example by L<Sub::Spec::CmdLine> to provide tab
completion for argument value. Example:

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

=head1 SEE ALSO

L<Sub::Spec>

L<Data::Sah>

L<Sub::Spec::Clause::returns>

=head1 AUTHOR

Steven Haryanto <stevenharyanto@gmail.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut


__END__

