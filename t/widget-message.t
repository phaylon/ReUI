use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Message';

use syntax qw( function );

my $msg = test_widget('message');

test_processing('basic',
    {   widget => Message->new(
            type    => 'notice',
            content => $msg,
            id      => 'test-message',
            classes => [qw( foo bar )],
        ),
        prepare => {
            current_skin => 'base',
        },
    },
    test_markup(fun ($markup) {
        $markup->into('/div', fun ($message) {
            $message->classes(qw( message notice foo bar ));
            $message->attr_is(id => 'test-message');
            $message->into('./*',
                fun ($content) {
                    $content->contains_test_value('message');
                },
            );
        });
    }),
);

done_testing;
