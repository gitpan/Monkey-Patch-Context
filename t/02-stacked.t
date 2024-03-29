{
    package Foo;
    sub bar {
        'unpatched';
    }
}

use Test::More;
use Monkey::Patch::Context qw(:all);

my $one = patch_package Foo => bar => sub {
    my $prev = shift->{orig_sub}->();
    "package $prev";
};

is(Foo::bar(), 'package unpatched');

my $two = patch_class Foo => bar => sub {
    my $prev = shift->{orig_sub}->();
    "class $prev";
};

is(Foo->bar, 'class package unpatched');

my $o = bless {}, 'Foo';
my $three = patch_object $o, bar => sub {
    my $prev = shift->{orig_sub}->();
    "obj $prev";
};

is $o->bar, 'obj class package unpatched';
undef $one;
is(Foo->bar, 'class unpatched');
is $o->bar, 'obj class unpatched';
undef $three;
is $o->bar, 'class unpatched';
undef $two;
is $o->bar, 'unpatched';

done_testing;
