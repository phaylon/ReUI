use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Dialog';

use syntax qw( function );

my $c_left  = test_widget('left-header');
my $c_right = test_widget('right-header');
my $c_inner = test_widget('inner');

test_processing('basic',
    {   widget => Dialog->new(
            title           => 'Test Dialog',
            id              => 'test-dialog',
            classes         => [qw( foo bar )],
            left_header     => [ $c_left ],
            right_header    => [ $c_right ],
            widgets         => [ $c_inner ],
        ),
    },
    test_markup(fun ($markup) {
        $markup->into('/div', fun ($dialog) {
            $dialog->attr_contains(class => qw( foo bar dialog ));
            $dialog->attr_is(id => 'test-dialog');
            $dialog->into('./div',
                fun ($header) {
                    $header->attr_contains(class => qw( dialog-header ));
                    $header->into('./span',
                        fun ($left) {
                            $left->attr_contains(class => qw( left ));
                            $left->contains_test_value('left-header');
                        },
                        fun ($title) {
                            $title->attr_contains(class => qw( title ));
                            $title->content_is('Test Dialog');
                        },
                        fun ($right) {
                            $right->attr_contains(class => qw( right ));
                            $right->contains_test_value('right-header');
                        },
                    );
                },
                fun ($content) {
                    $content->attr_contains(class => qw( dialog-content ));
                    $content->contains_test_value('inner');
                },
            );
        });
    }),
);

done_testing;
