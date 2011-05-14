use strictures 1;

package ReUI::Widget::Image;
use Moose;

use ReUI::Types  qw( Uri Str Undef NonEmptySimpleStr );
use ReUI::Traits qw( Resolvable Lazy );

use syntax qw( function method );
use namespace::autoclean;


has src => (
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


has alt => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => Str | Undef,
);


has image_selector => (
    traits      => [ Lazy ],
    is          => 'ro',
    isa         => NonEmptySimpleStr,
    required    => 1,
);

method _build_image_selector { 'img' }


method compile ($state) {
    my $selector = $self->image_selector;
    return $state->markup_for($self)
        ->apply($self->identity_populator_for($selector))
        ->apply($self->attribute_set_populator_for($selector,
            src     => $self->resolve_src($state),
            title   => $self->resolve_title($state),
            alt     => $self->resolve_alt($state),
        ));
}


with qw(
    ReUI::Widget::API
    ReUI::Role::ElementClasses
);

__PACKAGE__->meta->make_immutable;

1;
