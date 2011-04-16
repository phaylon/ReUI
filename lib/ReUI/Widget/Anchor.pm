use strictures 1;

package ReUI::Widget::Anchor;
use Moose;

use ReUI::Types  qw( Str );
use ReUI::Traits qw( Resolvable );

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Container';


has name => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => Str,
    required    => 1,
);


with qw(
    ReUI::Widget::Anchor::API
);


around anchor_attributes => fun ($orig, $self, $state) {
    $self->$orig($state),
    name => $self->resolve_name($state),
};

1;
