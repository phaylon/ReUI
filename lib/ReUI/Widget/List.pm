use strictures 1;

package ReUI::Widget::List;
use Moose;

use ReUI::Traits        qw( Array Lazy RelatedClass );
use ReUI::Types         qw( ArrayRef Bool HashRef );
use Params::Classify    qw( is_ref );

use aliased 'ReUI::Widget::List::Item';

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Container';


has item_class => (
    traits      => [ RelatedClass ],
);

method _build_item_class { Item }


has items => (
    traits      => [ Array, Lazy ],
    isa         => ArrayRef[ Item ],
    init_arg    => undef,
    handles     => {
        items           => 'elements',
        has_items       => 'count',
        add_items       => 'push',
        item            => 'accessor',
    },
);

method _build_items {
    my @items = $self->_inflate_items($self->_item_prototypes);
    $self->_clear_item_prototypes;
    return [@items];
}


has item_prototypes => (
    traits      => [ Array, Lazy ],
    isa         => ArrayRef[ HashRef | Item ],
    init_arg    => 'items',
    clearer     => '_clear_item_prototypes',
    handles     => {
        _item_prototypes    => 'elements',
    },
);

method _build_item_prototypes { [] }


has is_ordered => (
    is          => 'rw',
    isa         => Bool,
);

method base_style { $self->is_ordered ? 'ordered' : 'unordered' }


around add_items => fun ($orig, $self, @items) {
    return $self->$orig($self->_inflate_items(@items));
};


around compile => fun ($orig, $self, $state) {
    return $state->markup_for($self, $self->base_style)
        ->apply($self->identity_populator_for('.list-container'))
        ->memoize
        ->select('.list-container')
        ->replace_content(HTML::Zoom->from_events([ map {
            (@{ $state->render($_)->to_events });
        } $self->items ]));
};


method _inflate_items (@items) {
    return map {
        is_ref($_, 'HASH') ? $self->make_item(%$_) : $_
    } @items;
}


with qw(
    ReUI::Role::ElementClasses
);

1;
