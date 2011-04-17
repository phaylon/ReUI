use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Form';
use aliased 'ReUI::Widget::ControlSet';

use syntax qw( function );

test_processing('tabular basic',
    {   widget => Form->new(
            action  => 'http://example.com/action',
            name    => 'test-form',
            widgets => [
                ControlSet->new(
                    name        => 'credentials',
                    id          => 'important-control-set',
                    classes     => [qw( foo bar )],
                    controls    => [
                        {   class   => 'ReUI::Widget::Control::Value',
                            name    => 'username',
                        },
                        {   class   => 'ReUI::Widget::Control::Password',
                            name    => 'password',
                        },
                    ],
                ),
            ],
        ),
    },
    test_markup(fun ($markup) {
        $markup->into('//form', fun ($form) {
            $form->into('./table', fun ($table) {
                $table->attr_is(id => 'important-control-set');
                $table->attr_contains(class => qw( foo bar control-set ));
                $table->into('./tr',
                    fun ($row) {
                        $row->attr_contains(class => qw( control-set-item ));
                        $row->into('./td',
                            fun ($label) {
                                $label->is('./label', 'Username', 'username');
                            },
                            fun ($inputs) {
                                $inputs->attr_contains(
                                    class => qw( control-inputs ),
                                );
                                $inputs->into('./span',
                                  fun ($widgets) {
                                    $widgets->into('./input',
                                      fun ($input) {
                                        $input->attr_is(
                                          'name',
                                          'test-form.credentials.username'
                                        );
                                      },
                                    );
                                  },
                                );
                            },
                            fun ($comment) {
                                $comment->attr_contains(
                                    class => qw( control-comment ),
                                );
                            },
                        );
                    },
                    fun ($row) {
                        $row->attr_contains(class => qw( control-set-item ));
                        $row->into('./td',
                            fun ($label) {
                                $label->is('./label', 'Password', 'password');
                            },
                            fun ($inputs) {
                                $inputs->attr_contains(
                                    class => qw( control-inputs ),
                                );
                                $inputs->into('./span',
                                  fun ($widgets) {
                                    $widgets->into('./input',
                                      fun ($input) {
                                        $input->attr_is(type => 'password');
                                        $input->attr_is(
                                          'name',
                                          'test-form.credentials.password'
                                        );
                                      },
                                    );
                                  },
                                );
                            },
                            fun ($comment) {
                                $comment->attr_contains(
                                    class => qw( control-comment ),
                                );
                            },
                        );
                    },
                );
            });
        });
    }),
);

done_testing;
