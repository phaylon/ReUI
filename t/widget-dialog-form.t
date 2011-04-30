use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Dialog::Form';

use syntax qw( function );

test_processing('basic',
    {   widget => Form->new(
            id                      => 'test-dialog',
            classes                 => [qw( foo bar )],
            name                    => 'my-form',
            title                   => 'Test Dialog Form',
            action                  => 'http://example.com/',
            method                  => 'POST',
            controls                => [
                {   class       => 'ReUI::Widget::Control::Hidden',
                    name        => 'hidden_field',
                    id          => 'hidden-field',
                    required    => 1,
                },
                {   class       => 'ReUI::Widget::Control::Value',
                    name        => 'visible_field',
                    id          => 'visible-field',
                    required    => 1,
                },
            ],
            actions                 => [
                {   class       => 'ReUI::Widget::Control::Submit',
                    name        => 'ok',
                },
            ],
            content_arguments       => {
                id                  => 'test-form',
                ignore_indicator    => 1,
            },
            global_errors_arguments => {
                id      => 'ge',
                classes => [qw( ge-foo ge-bar )],
            },
            control_set_arguments   => {
                id      => 'cs',
                classes => [qw( cs-foo cs-bar )],
            },
            action_set_arguments    => {
                id      => 'as',
                classes => [qw( as-foo as-bar )],
            },
        ),
        request => {
            method      => 'POST',
            parameters  => {
                'my-form.actions.ok' => 1,
            },
        },
    },
    test_markup(fun ($markup) {
        $markup->into('/div', fun ($dialog) {
            $dialog->attr_is(id => 'test-dialog');
            $dialog->classes(qw( foo bar dialog ));
            $dialog->into('./div',
                fun ($header) {
                    $header->attr_contains(class => qw( dialog-header ));
                    $header->into('./span[@class="title"]', fun ($title) {
                        $header->content_is('Test Dialog Form');
                    });
                },
                fun ($content) {
                    $content->classes(qw( dialog-content ));
                    $content->into('./form', fun ($form) {
                        $form->into('./*',
                            fun ($indicator) {
                                note('form indicator');
                                $indicator->classes(qw( form-indicator ));
                            },
                            fun ($global_errors) {
                                note('global error list');
                                $global_errors->attr_is(id => 'ge');
                                $global_errors->into('./li', fun ($error) {
                                    $error->content_is(
                                        'Missing value for Hidden Field',
                                        'missing hidden value error message',
                                    );
                                });
                            },
                            fun ($hidden) {
                                note('hidden control');
                                $hidden->attr_is(id => 'hidden-field');
                                $hidden->classes(qw( failure ));
                            },
                            fun ($controls) {
                                note('control set');
                                $controls->attr_is(id => 'cs');
                                $controls->into(
                                    '//input[@id="visible-field"]',
                                    fun ($input) {
                                        $input->classes(qw( failure ));
                                    },
                                );
                            },
                            fun ($actions) {
                                note('action set');
                                $actions->attr_is(id => 'as');
                                $actions->into('./input', fun ($ok) {
                                    $ok->attr_is(name => 'my-form.ok');
                                });
                            },
                        );
                    });
                },
            );
        });
    }),
);

done_testing;
