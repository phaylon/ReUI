use Test::More;

use ReUI::Util ':all';

is class_to_path($_->[0]), $_->[1], sprintf 'class_to_path %s', $_->[0]
    for ['Foo',         'foo'],
        ['Foo::Bar',    'foo/bar'],
        ['ABC',         'abc'],
        ['ABCSpec',     'abc_spec'],
        ['FooBar::Baz', 'foo_bar/baz'],
        ['ABC2011',     'abc2011'],
        ['Foo::2011',   'foo/2011'];

my $unflat = deflatten_hashref({
    'foo.bar'               => 23,
    'foo.bar.baz'           => 17,
    'foo.bar.qux'           => 6,
    'foo.baz.qux'           => 52,
    'foo.baz.quux'          => 53,
    'bar.0.baz'             => 1,
    'bar.0.qux'             => 2,
    'bar.1.baz'             => 3,
    'bar.1.qux'             => 4,
});

is_deeply
    $unflat,
    {   foo => {
            bar => 23,
            baz => {
                qux  => 52,
                quux => 53,
            },
        },
        bar => {
            0 => {
                baz => 1,
                qux => 2,
            },
            1 => {
                baz => 3,
                qux => 4,
            },
        },
    },
    'deflatten_hashref';

is_deeply
    filter_flat_hashref('foo', {
        'foo'           => 2,
        'foo.bar'       => 3,
        'foo.bar.baz'   => 4,
        'bar'           => 5,
        'bar.baz'       => 6,
        'bar.baz.qux'   => 7,
    }),
    {   'bar'       => 3,
        'bar.baz'   => 4,
    },
    'filter_flat_hashref';

done_testing;
