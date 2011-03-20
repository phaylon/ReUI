use strictures 1;
use Test::More;
use ReUI::Test;
use ReUI::Constants qw( :i18n );
use URI;

use aliased 'ReUI::Widget::Form';
use aliased 'ReUI::Widget::Control::Password';
use aliased 'ReUI::Widget::Control::Action';

use syntax qw( function );

my $uri = URI->new('http://example.com/');

my @tests = (
    ['basic',       { m => 'GET' }, {}],
    ['success',     { m => 'POST', p1 => 'foo', p2 => 'foo' }, {
        success => 'foo',
    }],
    ['mismatch',    { m => 'POST', p1 => 'foo', p2 => 'bar' }, {
        failure => { p1 => [[I18N_PASSWORD_MISMATCH, 'P1', 'P2']] },
    }],
    ['missing p1',  { m => 'POST', p2 => 'foo' }, {
        failure => { p1 => [[I18N_VALUE_MISSING, 'P1']] },
    }],
    ['missing p2',  { m => 'POST', p1 => 'foo' }, {
        failure => { p2 => [[I18N_VALUE_MISSING, 'P2']] },
    }],
);

for my $test (@tests) {
    my ($title, $opt, $exp) = @$test;
    test_processing($title,
        {   widget => fun ($state) {
                my $unexpected_cb
                    = test_require_call('unexpected callback', 0);
                my $expected_cb =
                    ( $opt->{m} eq 'POST' )
                        ? test_require_call('expected callback')
                        : $unexpected_cb;
                my $on_success = exists($exp->{success})
                    ? fun ($result) {
                        $expected_cb->();
                        is $result->{p1}, $exp->{success},
                            'valid value';
                    } : sub {
                        note('unexpected success');
                        $unexpected_cb->();
                    };
                my $on_failure = $exp->{failure}
                    ? fun ($global, $controls) {
                        $expected_cb->();
                        for my $f (keys %{ $exp->{failure} }) {
                            my $check = $exp->{failure}{ $f };
                            my $error = $controls->{ $f };
                            is_deeply $error, $check, "correct error on $f";
                        }
                    } : sub { note('unexpected fail'); $unexpected_cb->() };
                return Form->new(
                    name                => 'test_form',
                    action              => $uri,
                    method              => 'POST',
                    ignore_indicator    => 1,
                    widgets             => [
                        Password->new(
                            name        => 'p1',
                            id          => 'pw-1',
                            compare_to  => 'p2',
                            label       => 'P1',
                        ),
                        Password->new(
                            name        => 'p2',
                            id          => 'pw-2',
                            compare_to  => 'p1',
                            label       => 'P2',
                        ),
                        $state->on_failure(
                            $state->on_success(
                                Action->new(name => 'ok'),
                                $on_success,
                            ),
                            $on_failure,
                        ),
                    ],
                );
            },
            request => {
                method      => $opt->{m},
                parameters  => {
                    'test_form.p1'  => $opt->{p1},
                    'test_form.p2'  => $opt->{p2},
                    'test_form.ok'  => 1,
                },
            },
        },
        test_markup(fun ($page) {
            $page->into('//form', fun ($form) {
                $form->into('//input[@type="password"]',
                    fun ($pw) {
                        $pw->attr_is(id    => 'pw-1');
                        $pw->attr_is(name  => 'test_form.p1');
                        $pw->attr_is(value => '');
                    },
                    fun ($pw) {
                        $pw->attr_is(id    => 'pw-2');
                        $pw->attr_is(name  => 'test_form.p2');
                        $pw->attr_is(value => '');
                    },
                );
            });
        }),
    );
}

done_testing;
