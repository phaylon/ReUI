use strictures 1;

package ReUI::Model::Navigation;
use Moose;

use ReUI::Traits qw( RelatedClass Lazy );

use syntax qw( function method );
use namespace::autoclean;


has trail_class => (
    traits      => [ RelatedClass, Lazy ],
);

method _build_trail_class { 'ReUI::Model::Navigation::Trail' }

method trail (%args) { $self->make_trail(model => $self, %args) }


method _build_child_class { 'ReUI::Model::Navigation::Node' }


with qw(
    ReUI::Model::Navigation::Node::API
);

__PACKAGE__->meta->make_immutable;

1;
