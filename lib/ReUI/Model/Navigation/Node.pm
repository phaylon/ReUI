use strictures 1;

package ReUI::Model::Navigation::Node;
use Moose;

use ReUI::Traits qw( Resolvable );
use ReUI::Types  qw( NonEmptySimpleStr Uri );

use syntax qw( function method );
use namespace::autoclean;


has id => (
    is          => 'ro',
    required    => 1,
    isa         => NonEmptySimpleStr,
);

has title => (
    traits      => [ Resolvable ],
    is          => 'ro',
    required    => 1,
    isa         => NonEmptySimpleStr,
);

has uri => (
    traits      => [ Resolvable ],
    is          => 'ro',
    required    => 1,
    isa         => Uri,
    coerce      => 1,
);


method BUILD {
    $self->internal_id; # make sure we got one as soon as possible
}


with qw(
    ReUI::Model::Navigation::Node::API
    ReUI::Role::Identification::Internal
);

__PACKAGE__->meta->make_immutable;

1;
