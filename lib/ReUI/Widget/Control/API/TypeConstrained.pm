use strictures 1;

# ABSTRACT: Type constrained and coerced control value

package ReUI::Widget::Control::API::TypeConstrained;
use Moose::Role;

use ReUI::Types qw( TypeConstraint Bool );

use syntax qw( function method );
use namespace::autoclean;

has type_constraint => (
    is          => 'ro',
    isa         => TypeConstraint,
    init_arg    => 'isa',
);

has coerce => (
    is          => 'ro',
    isa         => Bool,
);

method coerced_value ($value) {
    if ($self->coerce and my $tc = $self->type_constraint) {
        return $tc->coerce($value);
    }
    return $value;
}

method errors_for_value ($value) {
    if (my $tc = $self->type_constraint) {
        if (my $error = $self->type_constraint->validate($value)) {
            return ["$error", $value, $self->label];
        }
    }
    return;
}

1;
