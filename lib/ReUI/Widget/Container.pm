use strictures 1;

# ABSTRACT: General container widget

package ReUI::Widget::Container;
use Moose;

use ReUI::Traits                    qw( Array Lazy );
use ReUI::Types                     qw( ArrayRef );
use HTML::Zoom;
use Carp                            qw( confess );
use Params::Classify                qw( is_blessed );
use Moose::Util                     qw( does_role );
use Moose::Util::TypeConstraints;

use syntax qw( function method );
use namespace::autoclean;

has widgets => (
    traits      => [ Array, Lazy ],
    isa         => ArrayRef[ role_type('ReUI::Widget::API') ],
    handles     => {
        widgets     => 'elements',
        add         => 'push',
        is_empty    => 'is_empty',
        widget      => 'get',
        has_widgets => 'count',
    },
);

method _build_widgets { [] }

method compile ($state) {
    return $self->compile_widgets($state, $self->widgets);
}

method compile_widgets ($state, @widgets) {
    return HTML::Zoom->from_events([ map {
        (@{ $self->compile_widget($state, $_)->to_events })
    } @widgets ]);
}

method compile_widget ($state, $widget) {
    return $widget->compile($state);
}

method event_propagation_targets { $self->widgets }

with qw(
    ReUI::Widget::API
    ReUI::Widget::Container::API
    ReUI::Role::EventHandling::Propagation
);

__PACKAGE__->meta->make_immutable;

1;
