use strictures 1;

package ReUI::Skin::API;
use Moose::Role;

use ReUI::Util  qw( file_by_object );
use ReUI::Types qw( NonEmptySimpleStr );

use syntax qw( function method );
use namespace::autoclean;

requires qw(
    per_page_stylesheets
);

has title => (
    is          => 'ro',
    isa         => NonEmptySimpleStr,
    required    => 1,
);

1;
