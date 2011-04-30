use strictures 1;

# ABSTRACT: Require control value

package ReUI::Widget::Control::API::Require;
use Moose::Role;

use ReUI::Types     qw( Bool );
use ReUI::Constants qw( :i18n );

use syntax qw( function method );
use namespace::autoclean;

has required => (
    is          => 'ro',
    isa         => Bool,
);

around validate => fun ($orig, $self, $event) {
    my $value = $self->find_value($event);
    if (defined($value) and length($value)) {
        return $self->$orig($event);
    }
    else {
        if ($self->required) {
            $self->register_requirement_error(
                $event,
                $self->name_in($event),
                $self->requirement_error_for($event),
            );
        }
    }
    return undef;
};

method requirement_error_for ($event) {
    return [I18N_VALUE_MISSING, $self->label],
}

method register_requirement_error ($event, $name, @errors) {
    $event->add_control_errors_for($name, @errors);
}

1;
