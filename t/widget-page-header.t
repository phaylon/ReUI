use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Page::Header';

use syntax qw( function );

my $title_content = test_widget('title-content');

test_processing('full',
    {   widget => Header->new(
            content                 => $title_content,
            logo_image_uri          => 'http://example.com/logo.png',
            logo_image_arguments    => {
                classes => [qw( foo bar )],
            },
            logo_link_uri           => 'http://example.com/',
            logo_link_arguments     => {
                classes => [qw( baz qux )],
            },
        ),
    },
    test_markup(fun ($markup) {
        $markup->into('//div[@id="page-header"]', fun ($header) {
            $header->contains_test_value('title-content');
            $header->into('./a[@id="page-header-logo-link"]', fun ($link) {
                $link->attr_is(href => 'http://example.com/');
                $link->attr_contains(class => qw( baz qux ));
                $link->into('./img', fun ($image) {
                    $image->attr_is(id  => 'page-header-logo');
                    $image->attr_is(src => 'http://example.com/logo.png');
                    $image->attr_contains(class => qw( foo bar ));
                });
            });
        });
    }),
);

# TODO: lazy tests, show_* flags

done_testing;
