use strictures 1;

package ReUI::Widget::API::Namespaced::EventPropagation;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw(
    propagate_event
);

around propagate_event => fun ($orig, $self, $event) {
    return $self->$orig($event->descend($self->name));
};

with qw(
    ReUI::Widget::API::Namespaced
);

1;
