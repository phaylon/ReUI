use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Anchor';

use syntax qw( function );

my $NameText    = 'test_name';
my @CssClasses  = qw( class-a class-b );
my $CssId       = 'test-anchor-id';

my $content_test_value = test_widget('anchor-content');

my $default_test = test_markup(fun ($markup) {
    $markup->into('//a', fun ($link) {
        $link->contains_test_value('anchor-content');
        $link->attr_is(name  => $NameText);
        $link->attr_is(id    => '');
    });
});

my $full_test = test_markup(fun ($markup) {
    $markup->into('//a', fun ($link) {
        $link->contains_test_value('anchor-content');
        $link->attr_is(name  => $NameText);
        $link->attr_is(id    => $CssId);
        $link->attr_contains(class => @CssClasses);
    });
});

test_processing('basic',
    {   widget => Anchor->new(
            name    => $NameText,
            widgets => [$content_test_value],
        ),
    },
    $default_test,
);

test_processing('full',
    {   widget => Anchor->new(
            name    => $NameText,
            widgets => [$content_test_value],
            id      => $CssId,
            classes => [@CssClasses],
        ),
    },
    $full_test,
);

test_processing('lazy',
    {   widget => Anchor->new(
            name    => sub { $_{anchor_name} },
            widgets => [$content_test_value],
            id      => $CssId,
            classes => [@CssClasses],
        ),
        variables => {
            anchor_name => $NameText,
        },
    },
    $full_test,
);

done_testing;
