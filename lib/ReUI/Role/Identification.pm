use strictures 1;

# ABSTRACT: User specified ID for an object

package ReUI::Role::Identification;
use Moose::Role;

use ReUI::Types qw( NonEmptySimpleStr );

use syntax qw( function method );
use namespace::autoclean;

has id => (
    is          => 'ro',
    isa         => NonEmptySimpleStr,
);

method has_id { defined $self->id }

1;
