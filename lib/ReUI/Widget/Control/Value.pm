use strictures 1;

# ABSTRACT: Value input base

package ReUI::Widget::Control::Value;
use Moose;

use ReUI::Traits qw( Resolvable );

use syntax qw( function method );
use namespace::autoclean;

has value => (
    traits      => [ Resolvable ],
    is          => 'ro',
);

method find_value ($state) {
    return $state->parameter($self->name_in($state));
}

method validate ($event) {
    my $value = $self->coerced_value($self->find_value($event));
    if (my @errors = $self->errors_for_value($value)) {
        $self->register_validation_error(
            $event,
            $self->name_in($event),
            @errors,
        );
        return undef;
    }
    return $value;
}

method register_validation_error ($event, $name, @errors) {
    return $event->add_control_errors_for($name, @errors);
}

method compile_with_value ($state, $value) {
    $value = $self->resolve_value($state)
        unless defined $value;
    my $class = $self->validation_state_in($state);
    return $state->markup_for($self)
        ->select('.value')
        ->set_attribute(name => $self->name_in($state))
        ->apply_if(defined($class), sub {
            $_->then->add_to_attribute(class => $class);
        })
        ->apply_if(defined($value), sub {
            $_->then->set_attribute(
                value => $self->render_value($state, $value),
            );
        })
        ->apply($self->identity_populator_for('.value'));
}

method render_value ($state, $value) {
    return $value;
}

with qw(
    ReUI::Widget::Control::API
    ReUI::Widget::Control::API::TypeConstrained
    ReUI::Widget::Control::API::Require
    ReUI::Role::Hint::Provider::Core
    ReUI::Role::ElementClasses
);

1;
