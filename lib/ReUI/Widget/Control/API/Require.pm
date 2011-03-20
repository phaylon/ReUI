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
            $event->add_control_errors_for(
                $self->name_in($event),
                [I18N_VALUE_MISSING, $self->label],
            );
        }
    }
    return undef;
};

1;
