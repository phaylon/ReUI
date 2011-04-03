use strictures 1;

package ReUI::Skin::Base;
use Moose;

use syntax qw( function method );
use namespace::autoclean;

method per_page_stylesheets {
    'main.css',
}

with qw(
    ReUI::Skin::API
);

1;
