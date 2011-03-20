use strictures 1;
use Test::More;
use ReUI::Test;
use URI;

use aliased 'ReUI::Widget::Form';
use aliased 'ReUI::Widget::Control::Hidden';
use aliased 'ReUI::Widget::Control::Action';

use syntax qw( function );

my $uri = URI->new('http://example.com/');

test_processing('basic',
    {   request => {
            method      => 'POST',
            parameters  => { 'test_form.foo' => 23, 'test_form.ok' => 1 },
        },
        widget => fun ($state) {
            my $test_cb = test_require_call('success callback');
            return Form->new(
                id                  => 'test_form',
                action              => $uri,
                method              => 'POST',
                ignore_indicator    => 1,
                widgets             => [
                    Hidden->new(name => 'foo', value => 17),
                    $state->on_success(
                        Action->new(name => 'ok'),
                        fun ($result) {
                            $test_cb->();
                            is $result->{foo}, 23, 'correct value';
                        },
                    ),
                ],
            );
        },
    },
    test_markup(fun ($page) {
        $page->into('//form', fun ($form) {
            $form->attr_is(method => 'POST');
            $form->attr_is(action => $uri);
            $form->attr_is(name   => 'test_form');
            $form->into('//input[@type="hidden"]',
                fun ($hidden) {
                    $hidden->attr_contains(class => qw(
                        hidden-value
                        form-indicator
                    ));
                },
                fun ($hidden) {
                    $hidden->attr_is(name  => 'test_form.foo');
                    $hidden->attr_is(value => 23);
                    $hidden->attr_contains(class => qw(
                        hidden-value
                    ));
                },
            );
        });
    }),
);

done_testing;
