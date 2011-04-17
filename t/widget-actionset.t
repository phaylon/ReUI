use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Form';
use aliased 'ReUI::Widget::ActionSet';

use syntax qw( function );

test_processing('basic',
    {   widget => Form->new(
            name    => 'test-form',
            action  => 'http://example.com',
            widgets => [
                ActionSet->new(
                    id      => 'some-action-set',
                    classes => [qw( foo bar )],
                    actions => [
                        {   name    => 'ok',
                            id      => 'some-action-id',
                        },
                        {   name    => 'cancel',
                            classes => [qw( baz )],
                        },
                    ],
                ),
            ],
        ),
    },
    test_markup(fun ($markup) {
        $markup->into('//form', fun ($form) {
            $form->into('//div[@id="some-action-set"]', fun ($set) {
                $set->attr_contains(class => qw( action-set foo bar ));
                $set->into('./input',
                    fun ($input) {
                        $input->attr_is(name => 'test-form.ok');
                    },
                    fun ($input) {
                        $input->attr_is(name => 'test-form.cancel');
                    },
                );
            });
        });
    }),
);

done_testing;
