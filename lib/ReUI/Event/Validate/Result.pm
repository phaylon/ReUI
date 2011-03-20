use strictures 1;

# ABSTRACT: Result collection event

package ReUI::Event::Validate::Result;
use Moose;

use ReUI::Traits qw( Hash Array Lazy );
use ReUI::Types  qw( HashRef ArrayRef CodeRef Does );
use ReUI::Util   qw( deflatten_hashref filter_flat_hashref );

use syntax qw( function method );
use namespace::autoclean;


=attr control_errors

Maps the namespace of a control to an array reference of errors.

=method has_control_errors

See L<ReUI::Event::Validate::Result::API/has_control_errors>.

=method has_control_errors_for

See L<ReUI::Event::Validate::Result::API/has_control_errors_for>.

=method add_control_errors

See L<ReUI::Event::Validate::Result::API/add_control_errors>.

=method control_errors_for

See L<ReUI::Event::Validate::Result::API/control_errors_for>.

=method control_errors_as_data

Returns an inflated hash reference containing the control errors.

=cut

has control_errors => (
    traits      => [ Hash, Lazy ],
    isa         => HashRef[ ArrayRef ],
    reader      => '_control_errors_data',
    handles     => {
        has_control_errors  => 'count',
    },
);

method _build_control_errors { {} }

method control_errors_for ($name) {
    return @{ $self->_control_errors_data->{ $name } || [] };
}

method has_control_errors_for ($name) {
    return scalar $self->control_errors_for($name);
}

method add_control_errors_for ($name, @errors) {
    push @{ $self->_control_errors_data->{ $name } ||= [] }, @errors
        if @errors;
    return $self->has_control_errors_for($name);
}

method control_errors_as_data {
    return $self->_as_data($self->_control_errors_data);
}


=attr global_errors

Contains an array reference of global errors.

=method has_global_errors

See L<ReUI::Event::Validate::Result::API/has_global_errors>.

=method add_global_errors

See L<ReUI::Event::Validate::Result::API/add_global_errors>.

=method global_errors

See L<ReUI::Event::Validate::Result::API/global_errors>.

=cut

has global_errors => (
    traits      => [ Array, Lazy ],
    isa         => ArrayRef,
    handles     => {
        global_errors       => 'elements',
        has_global_errors   => 'count',
        add_global_errors   => 'push',
    },
);

method _build_global_errors { [] }


=attr valid_values

Maps control namespaces to valid values.

=method has_valid_values

See L<ReUI::Event::Validate::Result::API/has_valid_values>.

=method has_valid_value_for

See L<ReUI::Event::Validate::Result::API/has_valid_value_for>.

=method valid_value_names

See L<ReUI::Event::Validate::Result::API/valid_value_names>.

=method valid_value_for

See L<ReUI::Event::Validate::Result::API/valid_value_for>.

=method valid_values_as_data

Returns an inflated hash reference containing the valid values.

=cut

has valid_values => (
    traits      => [ Hash, Lazy ],
    isa         => HashRef,
    reader      => '_valid_values_data',
    handles     => {
        valid_value_for     => 'accessor',
        has_valid_value_for => 'exists',
        has_valid_values    => 'count',
        valid_value_names   => 'keys',
    },
);

method _build_valid_values { {} }

method valid_values_as_data {
    return $self->_as_data($self->_valid_values_data);
}


=attr post_validation_constraints

Contains validation subroutines to be evaluated after the individual controls
have been validated.

=method post_validation_constraints

    ( CodeRef, ... ) = $object->post_validation_constraints;

Returns all currently known constraints.

=method add_post_validation_constraint

    $object->add_post_validation_constraint( fun ($result) { ... } );

Registers a new constraint to be run after the individual controls have been
validated. The callback will have to register errors itself, the actual
return value is discarded.

=cut

has post_validation_constraints => (
    traits      => [ Array, Lazy ],
    isa         => ArrayRef[ CodeRef ],
    handles     => {
        post_validation_constraints     => 'elements',
        add_post_validation_constraint  => 'push',
    },
);

method _build_post_validation_constraints { [] }


=attr action

Stores the action that is to be performed, if one was found.

=method action

    $object->action( $action_object );
    Object = $object->action;

Getter/setter for the action attribute.

See L<ReUI::Event::Validate::Result::API/action>.

=method has_action

See L<ReUI::Event::Validate::Result::API/has_action>.

=cut

has action => (
    is          => 'rw',
    isa         => 'ReUI::Widget::Control::Action',
);

method has_action { defined $self->action }


=attr registered_controls

Maps namespaces to controls that were registered during validation. This will
usually not contain all control objects, but only those were communication
between different widgets is necessary.

=method registered_controls

See L<ReUI::Event::Validate::Result::API/registered_controls>.

=method control

See L<ReUI::Event::Validate::Result::API/control>.

=method register_control

See L<ReUI::Event::Validate::Result::API/register_control>.

=cut

has registered_controls => (
    traits      => [ Hash, Lazy ],
    isa         => HashRef[ Does[ 'ReUI::Widget::Control::API' ] ],
    handles     => {
        registered_controls => 'keys',
        control             => 'get',
        register_control    => 'set',
    },
);

method _build_registered_controls { {} }

around control => fun ($orig, $self, @args) {
    return $self->$orig(join '.', @args);
};


=method has_errors

See L<ReUI::Event::Validate::Result::API/has_errors>.

Includes L</has_global_errors> and L</has_control_errors> in the decision.

=cut

method has_errors { $self->has_global_errors or $self->has_control_errors }


=method is_success

See L<ReUI::Event::Validate::Result::API/is_success>.

=cut

method is_success { not $self->has_errors }


=method dispatch_method

See L<ReUI::Event::API::Dispatch/dispatch_method>. The event will be
dispatched to the C<on_validate_event> method.

=cut

method dispatch_method { 'on_validate_event' }


method _as_data ($data) {
    return deflatten_hashref(filter_flat_hashref($self->namespace, $data));
}


=method finalize

See L<ReUI::Event::Validate::Result::API/finalize>.

The L</post_validation_constraints> will be evaluated first. Depending on the
result, the method will then call L<ReUI::Widget::Control::Action/perform> on
success, or L<ReUI::Widget::Control::Action/failure> when errors where found.

If no L</action> was registered during validation, nothing will be done after
the constraint validations.

=cut

method finalize {
    $_->($self)
        for $self->post_validation_constraints;
    if ($self->is_success and $self->has_action) {
        my $result = $self->valid_values_as_data;
        $self->action->perform($self, $result);
    }
    elsif ($self->has_errors and $self->has_action) {
        my @global  = $self->global_errors;
        my $control = $self->control_errors_as_data;
        $self->action->failure($self, \@global, $control);
    }
    return 1;
}

with qw(
    ReUI::Event::Validate::Result::API
    ReUI::Event::API::Dispatch
);

1;

__END__

=head1 DESCRIPTION

An instance of this class is used to collect and manage the validation result
of all control widgets below a related L<ReUI::Widget::Form>. The related
form is not directly associated, but are managed by a L<ReUI::Event::Validate>
super event. Most of the relevant interface is documented in
L<ReUI::Event::Validate::Result::API>.

You shouldn't have to deal with this kind of object directly.

=head1 METHODS

=head1 ATTRIBUTES

=head1 IMPLEMENTS

=over

=item * L<ReUI::Event::Validate::Result::API>

=item * L<ReUI::Event::API::Dispatch>

=back

=head1 SEE ALSO

=over

=item * L<ReUI::Event::Validate>

=item * L<ReUI::Event::Validate::Result::API>

=back

=cut
