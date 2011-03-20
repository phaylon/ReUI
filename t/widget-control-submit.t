use strictures 1;
use Test::More;
use ReUI::Test;
use URI;

use aliased 'ReUI::Widget::Form';
use aliased 'ReUI::Widget::Control::Submit';

use syntax qw( function );

my $uri = URI->new('http://example.com/');

my @tests = (
    ['without value submission' => {
        method      => 'GET',
        parameters  => {},
    }, 0],
    ['with value submission' => {
        method      => 'POST',
        parameters  => { 'test_form.ok' => 'FNORD' },
    }, 1],
);

for my $test (@tests) {
    my ($title, $request, $cbc) = @$test;
    test_processing($title,
        {   request => $request,
            widget  => fun ($state) {
                my $test_cb = test_require_call('success callback', $cbc);
                return Form->new(
                    id                  => 'test_form',
                    action              => $uri,
                    method              => 'POST',
                    ignore_indicator    => 1,
                    widgets             => [
                        $state->on_success(
                            Submit->new(
                                name    => 'ok',
                                id      => 'ok-button',
                                classes => [qw( foo bar )],
                                label   => 'reui.label.ok',
                            ),
                            fun ($result) {
                                $test_cb->();
                                is  $result->{ok},
                                    'FNORD',
                                    'correct action label in values';
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
                $form->into('//input[@type="submit"]', fun ($submit) {
                    $submit->attr_is(name  => 'test_form.ok');
                    $submit->attr_is(id    => 'ok-button');
                    $submit->attr_is(value => 'OK');
                    $submit->attr_contains(class => qw(
                        submit-action
                        foo
                        bar
                    ));
                });
            });
        }),
    );
}

done_testing;
