package Monkey::Patch::Context::Handle;

use Scalar::Util qw(weaken);
use Sub::Delete;

use strict;
use warnings;

our $VERSION = '0.03.01'; # VERSION

my %handles;

# What we're doing here, essentially, is keeping a stack of subroutine
# refs for each name (Foo::bar::baz type name).  We're doing this so that
# the coderef that lives at that name is always the top of the stack, so
# the wrappers get uninstalled in a funky order all hell doesn't break
# loose.  The most recently installed undestroyed wrapper will always get
# called, and it will unwind gracefully until we get down to the original
# sub (if there was one).

sub new {
    my ($class, %args) = @_;
    bless \%args, $class;
}

sub name {
    my $self = shift;
    $self->{name} ||= "$self->{package}::$self->{subname}";
}

sub stack {
    my $self = shift;
    $self->{stack} ||= $handles{ $self->name } ||= [];
}

sub call_previous {
    my $self    = shift;
    my $stack   = $self->stack;
    my $wrapper = $self->wrapper;
    for my $i (1..$#$stack) {
        if ($stack->[$i] == $wrapper) {
            goto &{ $stack->[$i-1] };
        }
    }
    $self->call_default(@_);
}

sub call_default {}

sub should_call_code { 1 }

sub wrapper {
    my $self = shift;
    unless ($self->{wrapper}) {
        weaken($self);
        $self->{wrapper} = sub {
            if ($self->should_call_code($_[0])) {
                my $ctx = {
                    orig_sub  => sub { $self->call_previous(@_) },
                    orig_name => $self->name,
                };
                unshift @_, $ctx;
                goto $self->{code};
            }
            else {
                return $self->call_previous(@_);
            }
        };
    }
    return $self->{wrapper};
}

sub install {
    my $self = shift;
    my $name  = $self->name;
    my $stack = $self->stack;

    no strict 'refs';

    unless (@$stack) {
        if (*$name{CODE}) {
            push @$stack, \&$name;
        }
    }

    my $code = $self->wrapper;

    no warnings 'redefine';
    *$name = $code;
    push(@$stack, $code);

    return $self;
}

sub DESTROY {
    my $self    = shift;
    my $stack   = $self->stack;
    my $wrapper = $self->wrapper;
    for my $i (0..$#$stack) {
        if($stack->[$i] == $wrapper) {
            splice @$stack, $i, 1;
            no strict 'refs';
            my $name = $self->name;
            if(my $top = $stack->[-1]) {
                no warnings 'redefine';
                *$name = $top;
            }
            else {
                delete_sub $name;
            }
            last;
        }
    }
}

1;


__END__
=pod

=head1 NAME

Monkey::Patch::Context::Handle

=head1 VERSION

version 0.03.01

=for Pod::Coverage .*

=head1 AUTHOR

Steven Haryanto <sharyanto@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

