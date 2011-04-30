use strictures 1;
use Test::More;
use ReUI::Test;
use ReUI::Types qw( Int );
use URI;

use aliased 'ReUI::Widget::Form';
use aliased 'ReUI::Widget::Form::GlobalErrors';
use aliased 'ReUI::Widget::Control::Hidden';

use syntax qw( function );

test_processing('basic',
    {   widget => Form->new(
            action              => 'http://example.com',
            name                => 'test-form',
            ignore_indicator    => 1,
            method              => 'POST',
            widgets             => [
                GlobalErrors->new(
                    id      => 'main-form-errors',
                    classes => [qw( foo bar )],
                ),
                Hidden->new(
                    name        => 'test-input',
                    label       => 'Some Value',
                    isa         => Int,
                    required    => 1,
                ),
            ],
        ),
        request => {
            method      => 'POST',
            parameters  => {
                'test-form.test-input' => q{"foo"},
            },
        },
    },
    test_markup(fun ($markup) {
        $markup->into('//form', fun ($form) {
            $form->into('./ul', fun ($list) {
                $list->attr_contains(class => qw( foo bar global-errors ));
                $list->attr_is(id => 'main-form-errors');
                $list->into('./li', fun ($error) {
                    $error->is('.', 'Invalid value for Some Value', 'error');
                });
            });
        });
    }),
);

test_processing('without errors',
    {   widget => Form->new(
            action              => 'http://example.com',
            name                => 'test-form',
            ignore_indicator    => 1,
            method              => 'POST',
            widgets             => [
                GlobalErrors->new(
                    id      => 'main-form-errors',
                    classes => [qw( foo bar )],
                ),
                Hidden->new(
                    name        => 'test-input',
                    label       => 'Some Value',
                    isa         => Int,
                    required    => 1,
                ),
            ],
        ),
        request => {
            method      => 'POST',
            parameters  => {
                'test-form.test-input' => q{23},
            },
        },
    },
    test_markup(fun ($markup) {
        $markup->into('//form', fun ($form) {
            $form->not_ok('./ul', 'no errors');
        });
    }),
);

done_testing;
