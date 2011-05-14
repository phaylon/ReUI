use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Navigation::Tree';
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
                {   id          => 'a',
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

my $tree = Tree->new(
    model       => $model,
    trail       => sub { $_{nav_trail} },
    id          => 'menu-tree',
    classes     => [qw( foo bar )],
    expand_if   => fun (%node) { $node{is_active} },
);

test_processing('empty trail',
    {   widget      => $tree,
        variables   => { nav_trail => $model->trail },
    },
    test_markup(fun ($markup) {
        $markup->into('/ul', fun ($top) {
            $top->classes(qw( navigation-tree level-0 foo bar ));
            $top->attr_is(id => 'menu-tree');
            $top->into('./li',
                fun ($node) {
                    $node->classes(qw( navigation-node ));
                    $node->not_classes(qw( active current ));
                    $node->into('./a', fun ($link) {
                        $link->classes(qw( node-link ));
                        $link->attr_is(href => 'http://example.com/a');
                        $link->content_is('A');
                    });
                    $node->not_ok('ul', 'no children');
                },
                fun ($node) {
                    $node->classes(qw( navigation-node ));
                    $node->not_classes(qw( active current ));
                    $node->into('./a', fun ($link) {
                        $link->classes(qw( node-link ));
                        $link->attr_is(href => 'http://example.com/b');
                        $link->content_is('B');
                    });
                    $node->not_ok('ul', 'no children');
                },
            );
        });
    }),
);

test_processing('deeper level',
    {   widget      => $tree,
        variables   => { nav_trail => $model->trail->into('a') },
    },
    test_markup(fun ($markup) {
        $markup->into('/ul', fun ($top) {
            $top->classes(qw( navigation-tree level-0 foo bar ));
            $top->attr_is(id => 'menu-tree');
            $top->into('./li',
                fun ($node) {
                    $node->classes(qw( navigation-node active current ));
                    $node->into('./a', fun ($link) {
                        $link->classes(qw( node-link ));
                        $link->attr_is(href => 'http://example.com/a');
                        $link->content_is('A');
                    });
                    $node->into('./ul', fun ($subtree) {
                        $subtree->classes(qw( level-1 navigation-tree ));
                        $subtree->not_classes(qw( foo bar ));
                        $subtree->into('./li', fun ($child) {
                            $child->classes(qw( navigation-node ));
                            $child->not_classes(qw( active current ));
                            $child->into('a', fun ($link) {
                                $link->classes(qw( node-link ));
                                $link->attr_is(
                                    'href',
                                    'http://example.com/a/a',
                                );
                                $link->content_is('A:A');
                            });
                            $child->not_ok('ul', 'no children');
                        });
                    });
                },
                fun ($node) {
                    $node->classes(qw( navigation-node ));
                    $node->not_classes(qw( active current ));
                    $node->into('./a', fun ($link) {
                        $link->classes(qw( node-link ));
                        $link->attr_is(href => 'http://example.com/b');
                        $link->content_is('B');
                    });
                    $node->not_ok('ul', 'no children');
                },
            );
        });
    }),
);

test_processing('deepest level',
    {   widget      => $tree,
        variables   => { nav_trail => $model->trail->into(qw( a a )) },
    },
    test_markup(fun ($markup) {
        $markup->into('/ul', fun ($top) {
            $top->classes(qw( navigation-tree level-0 foo bar ));
            $top->attr_is(id => 'menu-tree');
            $top->into('./li',
                fun ($node) {
                    $node->classes(qw( navigation-node active ));
                    $node->into('./a', fun ($link) {
                        $link->classes(qw( node-link ));
                        $link->attr_is(href => 'http://example.com/a');
                        $link->content_is('A');
                    });
                    $node->into('./ul', fun ($subtree) {
                        $subtree->classes(qw( level-1 navigation-tree ));
                        $subtree->not_classes(qw( foo bar ));
                        $subtree->into('./li', fun ($child) {
                            $child->classes(qw(
                                navigation-node
                                active
                                current
                            ));
                            $child->into('a', fun ($link) {
                                $link->classes(qw( node-link ));
                                $link->attr_is(
                                    'href',
                                    'http://example.com/a/a',
                                );
                                $link->content_is('A:A');
                            });
                            $child->not_ok('./ul', 'no children');
                        });
                    });
                },
                fun ($node) {
                    $node->classes(qw( navigation-node ));
                    $node->not_classes(qw( active current ));
                    $node->into('./a', fun ($link) {
                        $link->classes(qw( node-link ));
                        $link->attr_is(href => 'http://example.com/b');
                        $link->content_is('B');
                    });
                    $node->not_ok('ul', 'no children');
                },
            );
        });
    }),
);

done_testing;
