use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;
use URI;

use aliased 'ReUI::Widget::Page';
use aliased 'ReUI::Widget::Container';

use syntax qw( function );

my $default_test = test_markup(fun ($page) {
    $page->into('/html', fun ($doc) {
        $doc->into('//head', fun ($head) {
            $head->into('//title', fun ($title) {
                $title->content_is('Test Title');
            });
            $head->into('//link',
                fun ($link) {
                    note('stylesheet');
                    $link->attr_is(href => 'http://example.com/main.css');
                    $link->attr_is(rel  => 'stylesheet');
                },
            );
            $head->into('//script',
                fun ($link) {
                    note('external javascript');
                    $link->attr_is(src  => 'http://example.com/main.js');
                    $link->attr_is(type => 'text/javascript');
                },
            );
        });
        $doc->into('//body', fun ($body) {
            $body->attr_is(id => 'pageid');
            $body->attr_contains(class => qw( foo bar ));
            $body->contains_test_value('page-content');
        });
    });
});

my $content_test_value = test_widget('page-content');

test_processing('basic',
    {   widget  => Page->new(
            title           => 'Test Title',
            id              => 'pageid',
            classes         => [qw( foo bar )],
            stylesheet_uris => [ URI->new('http://example.com/main.css') ],
            javascript_uris => [ URI->new('http://example.com/main.js') ],
            widgets         => [ $content_test_value ],
        ),
    },
    $default_test,
);

test_processing('lazy',
    {   widget => Page->new(
            title           => sub { $_{title} },
            id              => 'pageid',
            classes         => [qw( foo bar )],
            stylesheet_uris => sub { $_{stylesheets} },
            javascript_uris => sub { $_{external_js} },
            widgets         => [ $content_test_value ],
        ),
        variables => {
            title       => 'Test Title',
            stylesheets => [ URI->new('http://example.com/main.css') ],
            external_js => [ URI->new('http://example.com/main.js') ],
        },
    },
    $default_test,
);

my $skin_uri_cb  = sub { join '/', 'http://example.com/skin', @_ };
my $skin_css     = 'http://example.com/skin/base/main.css';
my $skinned_test = test_markup(fun ($page) {
    $page->into('/html', fun ($doc) {
        $doc->into('//head', fun ($head) {
            $head->into('//link',
                fun ($link) {
                    note('skin stylesheet');
                    $link->attr_is(href => $skin_css);
                    $link->attr_is(rel  => 'stylesheet');
                },
                fun ($link) {
                    note('user stylesheet');
                    $link->attr_is(href => 'http://example.com/main.css');
                    $link->attr_is(rel  => 'stylesheet');
                },
            );
        });
        $doc->into('//body', fun ($body) {
            $body->attr_is(id => 'pageid');
            $body->attr_contains(class => qw( foo bar ));
            $body->contains_test_value('page-content');
        });
    });
});

test_processing('skinned',
    {   widget => Page->new(
            title               => 'Test Title',
            id                  => 'pageid',
            classes             => [qw( foo bar )],
            stylesheet_uris     => [ URI->new('http://example.com/main.css') ],
            widgets             => [ $content_test_value ],
        ),
        prepare => {
            current_skin        => 'base',
            skin_uri_callback   => $skin_uri_cb,
        },
    },
    $skinned_test,
);

done_testing;
