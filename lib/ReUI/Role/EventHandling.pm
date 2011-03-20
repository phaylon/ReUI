use strictures 1;

# ABSTRACT: Make a class event-aware

package ReUI::Role::EventHandling;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

method fire ($event) {
    $event->apply_to($self);
    return $event;
}

1;
