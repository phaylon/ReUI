use strictures 1;

package ReUI::Widget::List;
use Moose;

use ReUI::Traits        qw( Array Lazy RelatedClass Prototyped );
use ReUI::Types         qw( ArrayRef Bool HashRef );
use Params::Classify    qw( is_ref );

use aliased 'ReUI::Widget::List::Item';

use syntax qw( function method );
use namespace::autoclean;


has item_class => (
    traits      => [ RelatedClass ],
);

method _build_item_class { Item }


has items => (
    traits      => [ Array, Prototyped ],
    isa         => ArrayRef[ Item ],
    make_via    => 'make_item',
    handles     => {
        items           => 'elements',
        has_items       => 'count',
        add_items       => 'push',
        item            => 'accessor',
    },
);


has is_ordered => (
    is          => 'rw',
    isa         => Bool,
);

method _build_style { $self->is_ordered ? 'ordered' : 'unordered' }


around add_items => fun ($orig, $self, @items) {
    return $self->$orig($self->_inflate_items(@items));
};

method compile ($state) {
    return $state->markup_for($self)
        ->apply($self->identity_populator_for('.list-container'))
        ->memoize
        ->select('.list-container')
        ->replace_content($self->compile_items($state));
}

method event_propagation_targets { $self->items }

with qw(
    ReUI::Widget::API
    ReUI::Widget::API::Styled
    ReUI::Role::ElementClasses
    ReUI::Role::EventHandling::Propagation
);

1;
