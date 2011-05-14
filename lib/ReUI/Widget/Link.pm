use strictures 1;

package ReUI::Widget::Link;
use Moose;

use ReUI::Types  qw( Uri Str NonEmptySimpleStr Undef );
use ReUI::Traits qw( Resolvable Lazy );

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Container';


has name => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => Str | Undef,
);

has href => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => Uri,
    coerce      => 1,
    required    => 1,
);

has title => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => Str | Undef,
);


with qw(
    ReUI::Widget::Anchor::API
);


around anchor_attributes => fun ($orig, $self, $state) {
    $self->$orig($state),
    title => $self->resolve_title($state),
    href  => $self->resolve_href($state),
    name  => $self->resolve_name($state),
};

__PACKAGE__->meta->make_immutable;

1;
