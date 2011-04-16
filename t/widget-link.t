use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Link';

use syntax qw( function );

my $LinkUri     = 'http://example.com/about.html';
my $TitleText   = 'Test Title Content';
my $NameText    = 'test_name';
my @CssClasses  = qw( class-a class-b );
my $CssId       = 'test-link-id';

my $content_test_value = test_widget('link-content');

my $default_test = test_markup(fun ($markup) {
    $markup->into('//a', fun ($link) {
        $link->contains_test_value('link-content');
        $link->attr_is(href  => $LinkUri);
        $link->attr_is(name  => '');
        $link->attr_is(title => '');
        $link->attr_is(id    => '');
    });
});

my $full_test = test_markup(fun ($markup) {
    $markup->into('//a', fun ($link) {
        $link->contains_test_value('link-content');
        $link->attr_is(href  => $LinkUri);
        $link->attr_is(name  => $NameText);
        $link->attr_is(title => $TitleText);
        $link->attr_is(id    => $CssId);
        $link->attr_contains(class => @CssClasses);
    });
});

test_processing('basic',
    {   widget => Link->new(
            href    => $LinkUri,
            widgets => [$content_test_value],
        ),
    },
    $default_test,
);

test_processing('full',
    {   widget => Link->new(
            href    => $LinkUri,
            name    => $NameText,
            title   => $TitleText,
            id      => $CssId,
            classes => [@CssClasses],
            widgets => [$content_test_value],
        ),
    },
    $full_test,
);

test_processing('lazy',
    {   widget => Link->new(
            href    => sub { $_{link_href} },
            name    => sub { $_{link_name} },
            title   => sub { $_{link_title} },
            id      => $CssId,
            classes => [@CssClasses],
            widgets => [$content_test_value],
        ),
        variables => {
            link_href   => $LinkUri,
            link_name   => $NameText,
            link_title  => $TitleText,
        },
    },
    $full_test,
);

done_testing;
