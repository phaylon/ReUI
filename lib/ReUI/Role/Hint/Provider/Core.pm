use strictures 1;

# ABSTRACT: Core hints

package ReUI::Role::Hint::Provider::Core;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

with qw( ReUI::Role::Hint::Provider );

around additional_search_path_dists => fun ($orig, $self) {
    return(
        $self->$orig,
        $ENV{REUI_SKIP_DISTDIR} ? () : ('ReUI'),
    );
};

1;
