use strictures 1;

# ABSTRACT: Result collection event

package ReUI::Event::Validate::Result;
use Moose;

use ReUI::Traits qw( Hash Array Lazy );
use ReUI::Types  qw( HashRef ArrayRef CodeRef Does );
use ReUI::Util   qw( deflatten_hashref filter_flat_hashref );

use syntax qw( function method );
use namespace::autoclean;


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


has post_validation_constraints => (
    traits      => [ Array, Lazy ],
    isa         => ArrayRef[ CodeRef ],
    handles     => {
        post_validation_constraints     => 'elements',
        add_post_validation_constraint  => 'push',
        has_post_validation_constraints => 'count',
    },
);

method _build_post_validation_constraints { [] }


has action => (
    is          => 'rw',
    isa         => 'ReUI::Widget::Control::Action',
);

method has_action { defined $self->action }


has registered_controls => (
    traits      => [ Hash, Lazy ],
    isa         => HashRef[ Does[ 'ReUI::Widget::Control::API' ] ],
    handles     => {
        registered_controls     => 'keys',
        control                 => 'get',
        register_control        => 'set',
        has_registered_controls => 'count',
    },
);

method _build_registered_controls { {} }

around control => fun ($orig, $self, @args) {
    return $self->$orig(join '.', @args);
};


method BUILD {
    $self->$_ for qw(
        has_registered_controls
        has_post_validation_constraints
        has_valid_values
        has_global_errors
        has_control_errors
    );
}


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

__PACKAGE__->meta->make_immutable;

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
