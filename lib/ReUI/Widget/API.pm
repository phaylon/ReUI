use strictures 1;

# ABSTRACT: Widget interface

package ReUI::Widget::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw( compile );

method identity_populator_for ($selector) {
    return sub {
        return $_->apply_if($self->has_id, sub {
            $_->select($selector)->set_attribute(id => $self->id);
        });
    };
}

with qw(
    ReUI::Role::Identification
    ReUI::Role::Variations
    ReUI::Role::EventHandling
);

1;
