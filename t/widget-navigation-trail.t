use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Navigation::Trail';
use aliased 'ReUI::Model::Navigation';

use syntax qw( function );

my $mk_uri = fun (@args) {
    return sub { sprintf 'http://example.com/%s', join '/', @args };
};

my $model = Navigation->new(
    children => [
        {   id          => 'a',
            title       => 'A',
            uri         => $mk_uri->(qw( a )),
            children    => [
                {   id          => 'b',
                    title       => 'B',
                    uri         => $mk_uri->(qw( a b )),
                },
            ],
        },
    ],
);

my $trail = $model->trail->into(
    qw( a b ),
    { title => 'C', id => 'c', uri => $mk_uri->(qw( c )) },
    { title => 'D', id => 'd', uri => $mk_uri->(qw( d )) },
    { title => 'E', id => 'e', uri => $mk_uri->(qw( e )) },
);

my $sep_test = fun ($sep) {
    $sep->classes(qw( trail-separator ));
    $sep->content_is('/');
};

my $mk_node_test = fun ($path, $title, @classes) {
    my %class_map = map { ($_ => 0) } qw( first last cutoff );
    $class_map{ $_ }++ for @classes;
    my @not_classes = grep { not $class_map{ $_ } } keys %class_map;
    return fun ($node) {
        $node->classes(@classes, qw( navigation-node ));
        $node->not_classes(@not_classes);
        $node->into('./a', fun ($link) {
            $link->classes(qw( node-link ));
            $link->attr_is(href => "http://example.com/$path");
            $link->content_is($title);
        });
    };
};

my $mk_trail_test = fun (@node_tests) {
    return test_markup(fun ($markup) {
        $markup->into('/div', fun ($trail) {
            $trail->classes(qw( navigation-trail foo bar ));
            $trail->attr_is(id => 'main-trail');
            $trail->into('./span', @node_tests);
        });
    });
};

test_processing('default',
    {   widget => Trail->new(
            id      => 'main-trail',
            classes => [qw( foo bar )],
            trail   => $trail,
        ),
    },
    $mk_trail_test->(
        $mk_node_test->('a', 'A', qw( first )),
        $sep_test,
        $mk_node_test->('a/b', 'B'),
        $sep_test,
        $mk_node_test->('c', 'C'),
        $sep_test,
        $mk_node_test->('d', 'D'),
        $sep_test,
        $mk_node_test->('e', 'E', qw( last )),
    ),
);

test_processing('limit by leading',
    {   widget => Trail->new(
            id      => 'main-trail',
            classes => [qw( foo bar )],
            trail   => $trail,
            limit   => 3,
        ),
    },
    $mk_trail_test->(
        $mk_node_test->('a', 'A', qw( first )),
        $sep_test,
        $mk_node_test->('a/b', 'B'),
        $sep_test,
        $mk_node_test->('c', 'C', qw( last cutoff )),
    ),
);

test_processing('limit by trailing',
    {   widget => Trail->new(
            id      => 'main-trail',
            classes => [qw( foo bar )],
            trail   => $trail,
            limit   => -3,
        ),
    },
    $mk_trail_test->(
        $mk_node_test->('c', 'C', qw( first cutoff )),
        $sep_test,
        $mk_node_test->('d', 'D'),
        $sep_test,
        $mk_node_test->('e', 'E', qw( last )),
    ),
);

done_testing;
