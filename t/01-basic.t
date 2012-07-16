{
    package Foo;
    sub bar {
        return pop;
    }
}

{
    package Bar;
    use base 'Foo';

    sub new { bless {}, shift }
}


use Test::More;
use Monkey::Patch::Context qw(:all);

my $patcher = sub {
    my $ctx = shift;
   'patched ' . $ctx->{orig_name} . ' '. $ctx->{orig_sub}->(@_)
};

{
    my $h = patch_package Foo => bar => $patcher;
    is Foo::bar('one'), 'patched Foo::bar one';
}
is Foo::bar('one'), 'one';

{
    my $h = patch_class Bar => bar => $patcher;
    is(Bar->bar('one'), 'patched Bar::bar one');
}
is(Bar->bar('one'), 'one');

my $one = Bar->new;
my $two = Bar->new;

{
    my $h = patch_object $one => bar => $patcher;
    is $one->bar('one'), 'patched Bar::bar one';
    is $two->bar('one'), 'one';
}

is $one->bar('one'), 'one';
is $two->bar('one'), 'one';

done_testing;
