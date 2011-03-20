use strictures 1;

# ABSTRACT: Provide instance variants

package ReUI::Role::Variations;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

method variant (%args) {
    return $self->meta->clone_object($self, %args);
}

1;
