use strictures 1;
use Test::More;
use ReUI::Test;
use URI;

use aliased 'ReUI::Widget::Page::Layout::Simple';

use syntax qw( function );

my $content  = test_widget('page-content');
my $logo_uri = 'http://example.com/logo.png';
my $home_uri = 'http://example.com/';

test_processing('complete and explicit',
    {   widget => Simple->new(
            title               => 'Test Title',
            header_arguments    => {
                logo_link_uri   => $home_uri,
                logo_image_uri  => $logo_uri,
            },
            widgets => [
                $content,
            ],
        ),
    },
    test_markup(fun ($markup) {
        $markup->into('//html', fun ($page) {
            $page->into('./head', fun ($head) {
                $head->is('./title', 'Test Title', 'document title');
            });
            $page->into('./body', fun ($body) {
                $body->contains_test_value('page-content');
                $body->into('./div[@id="page-header"]', fun ($header) {
                    $header->like('.', qr{Test Title}, 'page title');
                    $header->into('./a', fun ($link) {
                        $link->attr_is(href => $home_uri);
                        $link->attr_is(id   => 'page-header-logo-link');
                        $link->into('./img', fun ($logo) {
                            $link->attr_is(src => $logo_uri);
                            $link->attr_is(id  => 'page-header-logo');
                        });
                    });
                });
            });
        });
    }),
);

done_testing;
