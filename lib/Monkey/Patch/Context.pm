package Monkey::Patch::Context;

use warnings;
use strict;

use Monkey::Patch::Context::Handle;
use Monkey::Patch::Context::Handle::Class;
use Monkey::Patch::Context::Handle::Object;

use Exporter qw(import);
our @EXPORT_OK = qw(patch_package patch_class patch_object);
our %EXPORT_TAGS = (all => \@EXPORT_OK);

our $VERSION = '0.03.01'; # VERSION

sub patch_package {
    Monkey::Patch::Context::Handle->new(
        package => shift,
        subname => shift,
        code    => shift,
    )->install;
}

sub patch_class {
    Monkey::Patch::Context::Handle::Class->new(
        package => shift,
        subname => shift,
        code    => shift,
    )->install;
}

sub patch_object {
    my $obj = shift;
    Monkey::Patch::Context::Handle::Object->new(
        object  => $obj,
        package => ref $obj,
        subname => shift,
        code    => shift,
    )->install;
}

1;
# ABSTRACT: Scoped monkeypatching (you can at least play nice)


__END__
=pod

=head1 NAME

Monkey::Patch::Context - Scoped monkeypatching (you can at least play nice)

=head1 VERSION

version 0.03.01

=head1 SYNOPSIS

    use Monkey::Patch::Context qw(:all);

    sub some_subroutine {
        my $pkg = patch_class 'Some::Class' => 'something' => sub {
            my $ctx = shift;
            say "Whee!";
            $ctx->{orig_sub}->(@_);
        };
        Some::Class->something(); # says Whee! and does whatever
        undef $pkg;
        Some::Class->something(); # no longer says Whee!

        my $obj = Some::Class->new;
        my $obj2 = Some::Class->new;

        my $whoah = patch_object $obj, 'twiddle' => sub {
            my $ctx  = shift;
            my $self = shift;
            say "Whoah!";
            $ctx->{orig_sub}->($self, @_);
        };

        $obj->twiddle();  # says Whoah!
        $obj2->twiddle(); # doesn't
        $obj->twiddle()   # still does
        undef $whoah;
        $obj->twiddle();  # but not any more

=head1 DESCRIPTION

This module is a fork of L<Monkey::Patch> 0.03. Its only notable difference, at
the moment, is that the patcher subroutine gets, as the first argument, a
context hash instead of the original subroutine. The context hash contains,
among others, the original subroutine in C<orig_sub> key. There are other
information contained in other keys, like C<orig_name> and possible others in
the future. This gives more, well, context to the patcher subroutine, useful
e.g. when the same patcher subroutine patches multiple subroutines.

=head1 SUBROUTINES

The following subroutines are available (either individually or via :all)

=head2 patch_package (package, subname, code)

Wraps C<package>'s subroutine named <subname> with your <code>. Your code
recieves a context hash (containing these keys: C<orig_sub> which is the
original subroutine, C<orig_name> which is the original subroutine's name) as
its first argument, followed by any arguments the subroutine would have normally
gotten. You can always call the subroutine ref your received; if there was no
subroutine by that name, the coderef will simply do nothing.

=head2 patch_class (class, methodname, code)

Just like C<patch_package>, except that the @ISA chain is walked when you try
to call the original subroutine if there wasn't any subroutine by that name in
the package.

=head2 patch_object (object, methodname, code)

Just like C<patch_class>, except that your code will only get called on the
object you pass, not the entire class.

=head1 HANDLES

All the C<patch> functions return a handle object.  As soon as you lose the
value of the handle (by calling in void context, assigning over the variable,
undeffing the variable, letting it go out of scope, etc), the monkey patch is
unwrapped.  You can stack monkeypatches and let go of the handles in any
order; they obey a stack discipline, and the most recent valid monkeypatch
will always be called.  Calling the "original" argument to your wrapper
routine will always call the next-most-recent monkeypatched version (or, the
original subroutine, of course).

=head1 BUGS

This magic is only faintly black, but mucking around with the symbol table is
not for the faint of heart.  Help make this module better by reporting any
strange behavior that you see!

=head1 ORIGINAL AUTHOR

Paul Driver <frodwith@cpan.org>

=head1 AUTHOR

Steven Haryanto <sharyanto@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 by Steven Haryanto.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

