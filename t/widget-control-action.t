use strictures 1;
use Test::More;
use ReUI::Test;
use URI;

use aliased 'ReUI::Widget::Form';
use aliased 'ReUI::Widget::Control::Action';

use syntax qw( function );

my $uri = URI->new('http://example.com/');

test_processing('basic',
    {   widget => fun ($state) {
            my $test_cb = test_require_call('success callback');
            my $arg_cb  = test_require_call('per-widget callback');
            return Form->new(
                id                  => 'test_form',
                action              => $uri,
                method              => 'POST',
                ignore_indicator    => 1,
                widgets             => [
                    $state->on_success(
                        Action->new(
                            id          => 'test_action',
                            on_success  => fun ($result) {
                                $arg_cb->();
                                is  $result->{test_action},
                                    'Test Action',
                                    'correct result';
                                is  $_{test_var},
                                    23,
                                    'state variables available';
                            },
                        ),
                        fun ($result) {
                            $test_cb->();
                            is  $result->{test_action},
                                'Test Action',
                                'correct action label in values';
                        },
                    ),
                ],
            );
        },
        variables => {
            test_var    => 23,
        },
        request => {
            method      => 'POST',
            parameters  => {
                'test_form.test_action' => 'Test Action',
            },
        },
    },
    test_markup(fun ($page) {
        $page->into('//form', fun ($form) {
            $form->attr_is(method => 'POST');
            $form->attr_is(action => $uri);
            $form->attr_is(name   => 'test_form');
            $form->into('//input', fun ($input) {
                note('indicator');
                $input->attr_is(type => 'hidden');
            });
        });
    }),
);

done_testing;
