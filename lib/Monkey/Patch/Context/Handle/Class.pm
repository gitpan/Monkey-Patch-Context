package Monkey::Patch::Context::Handle::Class;

use strict;
use warnings;

use base 'Monkey::Patch::Context::Handle';
use SUPER;

our $VERSION = '0.03.01'; # VERSION

sub call_default {
    my $self  = shift;
    my $class = $self->{package};
    my ($super) = SUPER::find_parent($class, $self->{subname});
    goto &$super if $super;
    return;
}

1;


__END__
=pod

=head1 NAME

Monkey::Patch::Context::Handle::Class

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

