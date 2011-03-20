use strictures 1;

# ABSTRACT: Submit button

package ReUI::Widget::Control::Submit;
use Moose;

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Control::Action';

method compile_with_value ($state) {
    return $state->markup_for($self)
        ->select('.submit-action')
        ->set_attribute(name => $self->name_in($state))
        ->then
        ->set_attribute(value => $state->render($self->label))
        ->apply($self->identity_populator_for('.submit-action'));
}

with qw(
    ReUI::Role::ElementClasses
);

1;
