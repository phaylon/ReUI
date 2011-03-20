use strictures 1;

# ABSTRACT: General container widget

package ReUI::Widget::Container;
use Moose;

use ReUI::Traits        qw( Array Lazy );
use ReUI::Types         qw( ArrayRef Does );
use HTML::Zoom;
use Carp                qw( confess );
use Params::Classify    qw( is_blessed );
use Moose::Util         qw( does_role );

use syntax qw( function method );
use namespace::autoclean;

has widgets => (
    traits      => [ Array, Lazy ],
    isa         => ArrayRef[ Does[ 'ReUI::Widget::API' ] ],
    handles     => {
        widgets     => 'elements',
        add         => 'push',
        is_empty    => 'is_empty',
        widget      => 'get',
    },
);

method _build_widgets { [] }

method compile ($state) {
    return HTML::Zoom->from_events([ map {
        (@{ $self->compile_widget($_, $state)->to_events })
    } $self->widgets ]);
}

method compile_widget ($widget, $state) {
    return $state->render($widget);
}

with qw(
    ReUI::Widget::API
    ReUI::Widget::Container::API
);

after fire => method ($event) { $self->propagate_event($event) };

method propagate_event ($event) {
    $_->fire($event)
        for $self->widgets;
}

1;
