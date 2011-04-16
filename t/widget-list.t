use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::List';

use syntax qw( function );

my @test_values = map { test_widget("item-$_") } qw( a b c );

test_processing('basic',
    {   widget => List->new(
            id              => 'some-list',
            classes         => [qw( foo bar )],
            item_arguments  => {
                classes => [qw( baz )],
            },
            items           => [
                {   id      => 'important-item',
                    widgets => [$test_values[0]],
                },
                {   widgets => [$test_values[1]]
                },
                {   id      => 'another-important-item',
                    widgets => [$test_values[2]]
                },
            ],
        ),
    },
    test_markup(fun ($markup) {
        $markup->into('//ul', fun ($list) {
            $list->attr_is(id => 'some-list');
            $list->attr_contains(class => qw( foo bar ));
            $list->into('./li',
                fun ($item) {
                    $item->attr_is(id => 'important-item');
                    $item->attr_contains(class => 'baz');
                    $item->contains_test_value('item-a');
                },
                fun ($item) {
                    $item->attr_is(id => '');
                    $item->attr_contains(class => 'baz');
                    $item->contains_test_value('item-b');
                },
                fun ($item) {
                    $item->attr_is(id => 'another-important-item');
                    $item->attr_contains(class => 'baz');
                    $item->contains_test_value('item-c');
                },
            );
        });
    }),
);

done_testing;
