use strictures 1;

# ABSTRACT: Password control

package ReUI::Widget::Control::Password;
use Moose;

use ReUI::Types     qw( Identifier );
use ReUI::Constants qw( :i18n );
use Carp            qw( confess );

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Control::Value';

has compare_to => (
    is          => 'ro',
    isa         => Identifier,
);

around compile_with_value => fun ($orig, $self, $state, $value) {
    return $self->$orig($state, '')
        ->select('.value')
        ->set_attribute(type => 'password')
        ->then
        ->add_to_attribute(class => 'password');
};

around validate => fun ($orig, $self, $event) {
    my $value = $self->$orig($event);
    $event->register_control($self->name_in($event), $self);
    if (defined($value) and my $compare_to = $self->compare_to) {
        $event->add_post_validation_constraint(fun ($result) {
            my $other = $result->control($result->namespace, $compare_to)
                or confess qq{Unable to find a control named '$compare_to'};
            my $other_value  = $other->find_value($result);
            my $other_name   = $other->name_in($result);
            my $other_errors = $result->has_control_errors_for($other_name);
            if (defined $other_value) {
                if (not($other_errors) and $other_value ne $value) {
                    $result->add_control_errors_for(
                        $self->name_in($result),
                        [I18N_PASSWORD_MISMATCH, $self->label, $other->label],
                    );
                }
            }
            else {
                unless ($other_errors) {
                    $result->add_control_errors_for(
                        $other_name,
                        [I18N_VALUE_MISSING, $other->label],
                    );
                }
            }
        });
    }
    return $value;
};

1;
