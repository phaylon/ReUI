use strictures 1;

package ReUI::Role::EventHandling::Propagation;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw( event_propagation_targets );

after fire => method ($event) { $self->propagate_event($event) };

method propagate_event ($event) {
    my @targets = $self->event_propagation_targets($event);
    $_->fire($event) for @targets;
}

1;
