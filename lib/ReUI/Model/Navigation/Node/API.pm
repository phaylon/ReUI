use strictures 1;

package ReUI::Model::Navigation::Node::API;
use Moose::Role;

use ReUI::Traits    qw( RelatedClass Lazy Prototyped Array );
use ReUI::Types     qw( ArrayRef Does );

use syntax qw( function method );
use namespace::autoclean;


has child_class => (
    traits      => [ RelatedClass, Lazy ],
);

method _build_child_class { ref($self) }


has children => (
    traits      => [ Array, Prototyped, Lazy ],
    isa         => ArrayRef[ Does[__PACKAGE__] ],
    compile     => 0,
    make_via    => 'make_child',
    handles     => {
        children        => 'elements',
        has_children    => 'count',
        add             => 'push',
        find_child      => 'first',
    },
);

method _build_children { [] }

around add => fun ($orig, $self, %args) {
    return $self->$orig($self->make_child(%args));
};

method get ($id) {
    return $self->find_child(sub { $_->id eq $id });
}


1;
