use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Form';
use aliased 'ReUI::Widget::ControlSet';

use syntax qw( function );

fun check_controlset ($check) {
    return fun ($markup) {
        $markup->into('//form', fun ($form) {
            $form->into('./table', fun ($table) {
                return $check->($table);
            });
        });
    };
}

fun test_controlset_items ($table, $common, @checks) {
    $table->into('./tr', map {
        my $check = $_;
        fun ($row) {
            $_->($row)
                for $common, $check;
        };
    } @checks);
}

fun check_label ($text) {
    return fun ($cell) {
        $cell->attr_contains(class => qw( control-label ));
        $cell->into('./label', fun ($label) {
            $label->is('.', $text, 'label content');
        });
    };
}

fun check_inputs ($input_check, @errors) {
    return fun ($cell) {
        $cell->attr_contains(class => qw( control-inputs ));
        $cell->into('./span', fun ($widgets) {
            $widgets->attr_contains(class => qw( control-widgets ));
            $input_check->($widgets);
        });
        if (@errors) {
            $cell->into('./ul', fun ($errors) {
                $errors->attr_contains(class => qw( control-errors ));
                $errors->into('li', map {
                    my $msg = $_;
                    fun ($error) {
                        $error->attr_contains(class => qw( error ));
                        $error->is('.', $msg, 'error message');
                    };
                } @errors);
            });
        }
        else {
            $cell->not_ok('./ul', 'no errors');
        }
    },
}

fun check_comment ($check) {
    return fun ($cell) {
        $cell->attr_contains(class => qw( control-comment ));
        return $check->($cell);
    };
}

my $widget = Form->new(
    action              => 'http://example.com/action',
    name                => 'test-form',
    method              => 'POST',
    ignore_indicator    => 1,
    widgets             => [
        ControlSet->new(
            name        => 'credentials',
            id          => 'important-control-set',
            classes     => [qw( foo bar )],
            controls    => [
                {   class       => 'ReUI::Widget::Control::Value',
                    name        => 'username',
                    required    => 1,
                    comment     => 'Test Username Comment',
                },
                {   class       => 'ReUI::Widget::Control::Password',
                    name        => 'password',
                    required    => 1,
                    comment     => 'Test Password Comment',
                },
            ],
        ),
    ],
);

fun check_control ($name, $label, $comment, @errors) {
    return fun ($un) {
        $un->into('./td',
            check_label($label),
            check_inputs(
                fun ($widgets) {
                    $widgets->into('./input', fun ($input) {
                        $input->attr_is(name => $name);
                    });
                },
                @errors,
            ),
            check_comment(fun ($cell) {
                $cell->is('.', $comment, 'control comment');
            }),
        );
    };
}

test_processing('tabular basic',
    { widget => $widget },
    test_markup(
        check_controlset(fun ($table) {
            $table->attr_is(id => 'important-control-set');
            $table->attr_contains(class => qw( foo bar control-set ));
            test_controlset_items($table,
                fun ($every_row) {
                    $every_row->attr_contains(
                        class => qw( control-set-item ),
                    );
                },
                check_control(
                    'test-form.credentials.username',
                    'Username',
                    'Test Username Comment',
                ),
                check_control(
                    'test-form.credentials.password',
                    'Password',
                    'Test Password Comment',
                ),
            );
        }),
    ),
);

test_processing('tabular missing',
    {   widget  => $widget,
        request => {
            parameters  => {},
            method      => 'POST',
        },
    },
    test_markup(
        check_controlset(fun ($table) {
            $table->attr_is(id => 'important-control-set');
            $table->attr_contains(class => qw( foo bar control-set ));
            test_controlset_items($table,
                fun ($every_row) {
                    $every_row->attr_contains(
                        class => qw( control-set-item failure ),
                    );
                },
                check_control(
                    'test-form.credentials.username',
                    'Username',
                    'Test Username Comment',
                    'Value is missing',
                ),
                check_control(
                    'test-form.credentials.password',
                    'Password',
                    'Test Password Comment',
                    'Value is missing',
                ),
            );
        }),
    ),
);

done_testing;
