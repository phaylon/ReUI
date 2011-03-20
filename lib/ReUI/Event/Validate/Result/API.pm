use strictures 1;

# ABSTRACT: Result event interface

package ReUI::Event::Validate::Result::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw(
    has_control_errors
    has_control_errors_for
    add_control_errors_for
    control_errors_for

    has_global_errors
    add_global_errors
    global_errors

    has_valid_values
    has_valid_value_for
    valid_value_names
    valid_value_for

    has_errors
    is_success

    has_action
    action

    registered_controls
    register_control
    control

    finalize
);

1;

__END__

=head1 DESCRIPTION

This interface is implemented by all classes that behave like result classes
used with L<ReUI::Event::Validate> to contain validation results for a
L<ReUI::Widget::Form>.

=head1 REQUIRED

=head2 has_errors

    Bool = $object->has_errors;

Returns true if any errors were encountered during validation, false
otherwise.

=head2 is_success

    Bool = $object->is_success;

The inverse of L</has_errors>.

=head2 has_action

    Bool = $object->has_action;

Returns true if an instance of L<ReUI::Widget::Control::Action> was
encountered during validation and registered itself.

=head2 action

    Maybe[ ReUI::Widget::Control::Action ] = $object->action;

Returns the L<ReUI::Widget::Control::Action> that was encountered and
deemed active during validation, if there was one. This is required for
callback invocations when L</finalize> is called.

=head2 registered_controls

    ( Namespace, ... ) = $object->registered_controls;

Returns a list of namespaces for registered controllers. The control objects
can be accessed via L</control>.

=head2 register_control

    $object->register_control( $namespace, $control );

Registers the C<$control> object under C<$namespace>. This is useful for
controls that have to communicate with each other.

=head2 control

    Maybe[ Object ] = $object->control( $namespace, ... );

Returns the control object registered under C<$namespace> if one exists.
Multiple namespace parts can be passed in and will be joined to a single
namespace before lookup.

=head2 has_control_errors

    Bool = $object->has_control_errors;

Returns true if any of the validated controls had any errors, false
otherwise.

=head2 has_control_errors_for

    Bool = $object->has_control_errors_for( $namespace );

Returns true if the control at C<$namespace> registered any errors, false
otherwise.

=head2 add_control_errors_for

    $object->add_control_errors_for( $namespace, @errors );

Registers the passed C<@errors> for the control validated under C<$namespace>.

=head2 control_errors_for

    ( Any, ... ) = $object->control_errors_for( $namespace );

Returns a list of errors that were registered by a control uner C<$namespace>.

=head2 has_global_errors

    Bool = $object->has_global_errors;

Returns true if any global errors were encounterd during validation, false
otherwise.

=head2 add_global_errors

    $object->add_global_errors( @errors );

Register the passed C<@errors> as global errors.

=head2 global_errors

    ( Any, ... ) = $object->global_errors;

Returns all global errors registerd during validation. Global errors are
errors that do not relate to any specific control.

=head2 has_valid_values

    Bool = $object->has_valid_values;

Returns true if any valid values were registered.

Note that the presence of valid values do not indicate a successful
validation. They only mean that some controls were valid. Use L</is_success>
or L</has_errors> for determining success.

=head2 has_valid_value_for

    Bool = $object->has_valid_value_for( $namespace );

Returns true if the control under C<$namespace> received a valid value,
false otherwise.

=head2 valid_value_names

    ( Namespace, ... ) = $object->valid_value_names;

Returns a list of namespaces under which valid values were registered. This
is essentially the list of controls that did not fail.

=head2 valid_value_for

    Maybe[ Defined ] = $object->valid_value_for( $namespace );

Returns the value that was registered under the given C<$namespace>, if one
exists.

=head2 finalize

    $object->finalize;

Needs to be called by the validation system (usually an outer event like
L<ReUI::Event::Validate>) and will perform any final cleanups and action
callbacks.

=head1 SEE ALSO

=over

=item * L<ReUI::Event::Validate::Result>

=item * L<ReUI::Event::Validate>

=back

=cut
