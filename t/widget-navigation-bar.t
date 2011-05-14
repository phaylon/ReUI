use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Navigation::Bar';
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
                {   id          => 'a-a',
                    title       => 'A:A',
                    uri         => $mk_uri->(qw( a a )),
                },
            ],
        },
        {   id          => 'b',
            title       => 'B',
            uri         => $mk_uri->(qw( b )),
        },
    ],
);

my $bar = Bar->new(
    model   => $model,
    trail   => sub { $_{nav_trail} },
    id      => 'menu-bar',
    classes => [qw( foo bar )],
);

my $mk_base_test = fun (@node_tests) {
    return test_markup(fun ($markup) {
        $markup->into('/ul', fun ($list) {
            $list->classes(qw( foo bar navigation-bar ));
            $list->attr_is(id => 'menu-bar');
            $list->into('./li', @node_tests);
        });
    });
};

test_processing('single level',
    {   widget      => $bar,
        variables   => { nav_trail => $model->trail->into('a') },
    },
    $mk_base_test->(
        fun ($node) {
            $node->classes(qw( active current navigation-node ));
            $node->into('./a', fun ($link) {
                $link->content_is('A');
                $link->attr_is(href => 'http://example.com/a');
                $link->classes(qw( node-link ));
            });
        },
        fun ($node) {
            $node->classes(qw( navigation-node ));
            $node->not_classes(qw( active current ));
            $node->into('./a', fun ($link) {
                $link->content_is('B');
                $link->attr_is(href => 'http://example.com/b');
                $link->classes(qw( node-link ));
            });
        },
    ),
);

test_processing('deeper level',
    {   widget      => $bar,
        variables   => {
            nav_trail   => $model->trail
                ->into('a')
                ->into('a-a'),
        },
    },
    $mk_base_test->(
        fun ($node) {
            $node->classes(qw( active navigation-node ));
            $node->not_classes(qw( current ));
            $node->into('./a', fun ($link) {
                $link->content_is('A');
                $link->attr_is(href => 'http://example.com/a');
                $link->classes(qw( node-link ));
            });
        },
        fun ($node) {
            $node->classes(qw( navigation-node ));
            $node->not_classes(qw( active current ));
            $node->into('./a', fun ($link) {
                $link->content_is('B');
                $link->attr_is(href => 'http://example.com/b');
                $link->classes(qw( node-link ));
            });
        },
    ),
);

done_testing;
