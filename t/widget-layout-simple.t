use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Layout::Simple';

use syntax qw( function );


my %test_content = map {
    ($_ => test_widget($_));
} qw( header footer left right content );


test_processing('empty',
    { widget => Simple->new(id => 'my-layout', classes => [qw( foo bar )]) },
    test_markup(fun ($markup) {
        $markup->into('/div', fun ($layout) {
            $layout->classes(qw( layout-simple layout foo bar ));
            $layout->attr_is(id => 'my-layout');
            $layout->into('./div',
                fun ($header) {
                    $header->classes(qw(
                        layout-header
                        layout-header-inner
                    ));
                    $header->content_is('');
                },
                fun ($content) {
                    $content->classes(qw(
                        layout-content
                        layout-content-inner
                    ));
                    $content->content_is('');
                },
                fun ($footer) {
                    $footer->classes(qw(
                        layout-footer
                        layout-footer-inner
                    ));
                    $footer->content_is('');
                },
            );
        });
    }),
);

test_processing('filled',
    {   widget => Simple->new(
            header  => $test_content{header},
            left    => $test_content{left},
            content => $test_content{content},
            right   => $test_content{right},
            footer  => $test_content{footer},
        ),
    },
    test_markup(fun ($markup) {
        $markup->into('/div', fun ($layout) {
            $layout->classes(qw( layout-simple layout ));
            $layout->into('./div', map {
                my $name = $_;
                fun ($section) {
                    $section->contains_test_value($name);
                };
            } qw( header left right content footer ));
        });
    }),
);

done_testing;
