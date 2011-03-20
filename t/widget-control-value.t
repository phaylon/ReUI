use strictures 1;
use Test::More;
use ReUI::Test;
use ReUI::Constants qw( :i18n );
use URI;

use ReUI::Test::Types qw( MyInt );

use aliased 'ReUI::Widget::Form';
use aliased 'ReUI::Widget::Control::Value';
use aliased 'ReUI::Widget::Control::Action';

use syntax qw( function );

my $uri = URI->new('http://example.com/');

my @basic = (
    ['non-lazy' => 23],
    ['lazy'     => sub { $_{test_number} }],
);

for my $test (@basic) {
    my ($title, $value) = @$test;
    test_processing('basic ' . $title,
        {   widget => Form->new(
                name    => 'test_form',
                action  => $uri,
                widgets => [
                    Value->new(
                        name    => 'test_value',
                        id      => 'tested',
                        classes => [qw( foo bar )],
                        value   => $value,
                    ),
                ],
            ),
            variables => { test_number => 23 },
        },
        test_markup(fun ($page) {
            $page->into('//form', fun ($form) {
                $page->into('//input[@id="tested"]', fun ($input) {
                    $input->attr_is(name  => 'test_form.test_value');
                    $input->attr_is(value => 23);
                    $input->attr_contains(class => qw(
                        value
                        foo
                        bar
                    ));
                });
            });
        }),
    );
}

my @tests = (
    ['valid value',     MyInt, 23,      { success => 23 }],
    ['invalid_value',   MyInt, 'foo',   {
        failure => [['Invalid integer', 'foo', 'Test Value']],
    }],
    ['coerced value',   MyInt, 23.12,   { success => 23, coerce => 1 }],
    ['optional value',  MyInt, undef,   { success => undef }],
    ['required value',  MyInt, undef,   {
        failure  => [[I18N_VALUE_MISSING, 'Test Value']],
        required => 1,
    }],
);

for my $test (@tests) {
    my ($title, $type, $submitted, $opt) = @$test;
    test_processing($title,
        {   widget => fun ($state) {
                my $expected_cb
                    = test_require_call('expected callback');
                my $unexpected_cb
                    = test_require_call('unexpected callback', 0);
                my $on_success = exists($opt->{success})
                    ? fun ($result) {
                        $expected_cb->();
                        is $result->{test_value}, $opt->{success},
                            'valid value';
                    } : sub { $unexpected_cb->() };
                my $on_failure = $opt->{failure}
                    ? fun ($global, $controls) {
                        $expected_cb->();
                        my $check = $opt->{failure};
                        my $error = $controls->{test_value};
                        is_deeply $error, $check, 'correct error';
                    } : sub { $unexpected_cb->() };
                return Form->new(
                    name                => 'test_form',
                    action              => $uri,
                    method              => 'POST',
                    ignore_indicator    => 1,
                    widgets             => [
                        Value->new(
                            name        => 'test_value',
                            id          => 'tested',
                            isa         => $type,
                            coerce      => $opt->{coerce},
                            required    => $opt->{required},
                        ),
                        $state->on_failure(
                            $state->on_success(
                                Action->new(
                                    name    => 'test_action',
                                ),
                                $on_success,
                            ),
                            $on_failure,
                        ),
                    ],
                );
            },
            request => {
                method      => 'POST',
                parameters  => {
                    'test_form.test_action' => 1,
                    'test_form.test_value'  => $submitted,
                },
            },
        },
        test_markup(fun ($page) {
            $page->into('//form', fun ($form) {
                my @form_class_inc = (
                    exists($opt->{success}) ? ('success') : (),
                    exists($opt->{failure}) ? ('failure') : (),
                );
                my @form_class_exc = (
                    not(exists $opt->{success}) ? ('success') : (),
                    not(exists $opt->{failure}) ? ('failure') : (),
                );
                $form->attr_contains(class => @form_class_inc)
                    if @form_class_inc;
                $form->attr_doesnt_contain(class => @form_class_exc)
                    if @form_class_exc;
                $form->into('//input[@id="tested"]', fun ($input) {
                    my $value = defined($submitted) ? $submitted : '';
                    $input->attr_is(value => $value);
                    my @class_inc = (
                        defined($opt->{success}) ? ('success') : (),
                        defined($opt->{failure}) ? ('failure') : (),
                    );
                    my @class_exc = (
                        not(defined $opt->{success}) ? ('success') : (),
                        not(defined $opt->{failure}) ? ('failure') : (),
                    );
                    $input->attr_contains(class => @class_inc)
                        if @class_inc;
                    $input->attr_doesnt_contain(class => @class_exc)
                        if @class_exc;
                });
            });
        }),
    );
}

done_testing;
