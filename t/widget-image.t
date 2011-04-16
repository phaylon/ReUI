use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Widget::Image';

use syntax qw( function );

my $ImageUri    = 'http://example.com/image.png';
my $AltText     = 'Test Alt Content';
my $TitleText   = 'Test Title Content';
my @CssClasses  = qw( class-a class-b );
my $CssId       = 'test-image-id';

my $default_test = test_markup(fun ($markup) {
    $markup->into('//img', fun ($img) {
        $img->attr_is(src   => $ImageUri);
        $img->attr_is(alt   => '');
        $img->attr_is(title => '');
        $img->attr_is(id    => '');
    });
});

my $full_test = test_markup(fun ($markup) {
    $markup->into('//img', fun ($img) {
        $img->attr_is(src   => $ImageUri);
        $img->attr_is(alt   => $AltText);
        $img->attr_is(title => $TitleText);
        $img->attr_is(id    => $CssId);
        $img->attr_contains(class => @CssClasses);
    });
});

test_processing('basic',
    {   widget => Image->new(
            src => $ImageUri,
        ),
    },
    $default_test,
);

test_processing('full',
    {   widget => Image->new(
            src     => $ImageUri,
            alt     => $AltText,
            title   => $TitleText,
            id      => $CssId,
            classes => [@CssClasses],
        ),
    },
    $full_test,
);

test_processing('lazy',
    {   widget => Image->new(
            src     => sub { $_{img_src} },
            alt     => sub { $_{img_alt} },
            title   => sub { $_{img_title} },
            id      => $CssId,
            classes => [@CssClasses],
        ),
        variables => {
            img_src     => $ImageUri,
            img_alt     => $AltText,
            img_title   => $TitleText,
        },
    },
    $full_test,
);

done_testing;
