use strictures 1;

package ReUI::View::Skinner::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw(
    skins
    skin_names
    has_skins
    skin
    locate_skin_file
);

1;
