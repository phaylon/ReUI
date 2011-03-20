use strictures 1;

# ABSTRACT: Control widget interface

package ReUI::Widget::Control::API;
use Moose::Role;

use ReUI::Traits qw( Lazy LazyRequire );
use ReUI::Types  qw( NonEmptySimpleStr I18N Identifier );

use syntax qw( function method );
use namespace::autoclean;

requires qw( find_value compile_with_value validate );

has label => (
    traits      => [ Lazy ],
    is          => 'ro',
);

method validation_state_in ($state) {
    return(
        ( $state->isa('ReUI::State::Result') and $state->has_result )
          ? $state->has_control_errors_for($self->name_in($state))
                ? 'failure'
                :
            $state->has_valid_value_for($self->name_in($state))
                ? 'success'
                : undef
          : undef,
    );
}

method _build_label { join ' ', map ucfirst, map lc, split m{_}, $self->name }

method has_label { defined $self->label }

method compile ($state) {
    return $self->compile_with_value($state, $self->find_value($state));
}

method on_validate_event ($event) {
    my $value = $self->validate($event);
    if (defined($value)) {
        $self->store_valid_value($event, $value);
    }
}

method store_valid_value ($event, $value) {
    $event->valid_value_for($self->name_in($event), $value);
    return 1;
}

with qw(
    ReUI::Widget::API
    ReUI::Role::ElementName
);

1;
