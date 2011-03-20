use strictures 1;
use Test::More;
use ReUI::Test;
use URI;

use aliased 'ReUI::Widget::Page';
use aliased 'ReUI::Widget::Form';

use syntax qw( function );

my $content_test_value = test_widget('form-content');

my $default_test = test_markup(fun ($page) {
    $page->into('/html/body', fun ($body) {
        $body->into('//form', fun ($form) {
            $form->attr_is(method   => 'POST');
            $form->attr_is(id       => 'testform');
            $form->attr_is(name     => 'testform');
            $form->attr_is(action   => 'http://example.com/');
            $form->attr_is(enctype  => 'multipart/form-data');
            $form->attr_contains(class => qw( formclass ));
            $form->contains_test_value('form-content');
            $form->into('//input[@type="hidden"]', fun ($hidden) {
                $hidden->attr_is(name  => 'testform._reui_indicator');
                $hidden->attr_is(value => 1);
                $hidden->attr_contains(class => qw( hidden-value ));
            });
        });
    });
});

test_processing('basic',
    {   widget  => Page->new(
            title   => 'Test Title',
            widgets => [
                Form->new(
                    method  => 'POST',
                    action  => URI->new('http://example.com/'),
                    id      => 'testform',
                    classes => 'formclass',
                    widgets => [
                        $content_test_value,
                    ],
                ),
            ],
        ),
    },
    $default_test,
);

test_processing('lazy',
    {   variables   => {
            form_action => URI->new('http://example.com/'),
        },
        widget      => Page->new(
            title   => 'Test Title',
            widgets => [
                Form->new(
                    method  => 'POST',
                    action  => sub { $_{form_action} },
                    id      => 'testform',
                    classes => 'formclass',
                    widgets => [
                        $content_test_value,
                    ],
                ),
            ],
        ),
    },
    $default_test,
);

done_testing;
