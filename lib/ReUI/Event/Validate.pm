use strictures 1;

# ABSTRACT: Validation event

package ReUI::Event::Validate;
use Moose;

use ReUI::Traits qw( RelatedClass Hash Lazy );
use ReUI::Types  qw( HashRef );

use syntax qw( function method );
use namespace::autoclean;


=attr result_class

Implements L<ReUI::Meta::Attribute::Trait::RelatedClass> and contains the
name of the event class that is used inside a submitted form validation.

=method result_class

    Str = $object->result_class

Returns the name of the result event class. Defaults to
L<ReUI::Event::Validate::Result>.

=method make_result

    Object = $object->make_result( %arguments );

Returns a new result event with the given C<%arguments>. An optional
C<result_arguments> method can be provided to inject default arguments.

=cut

has result_class => (
    traits      => [ RelatedClass ],
);

method _build_result_class { 'ReUI::Event::Validate::Result' }


=attr results

Maps internal form IDs to result events.

=method results

    ( Object, ... ) = $object->results;

Returns all result objects created up to this point.

=method has_results

    Bool = $object->has_results

Returns true if any result event was created, otherwise false.

=method result_ids

    ( Str, ... ) = $object->result_ids;

Returns the internal ids of the forms to which the result events are
associated.

=method result

    Maybe[ Object ] = $object->result( $id );

Returns the result event dispatched for the form with the internal C<$id>,
if there was one.

=method result_event

    Object = $object->result_event( $id );

Creates, stores, and returns a new result event of the L</result_class>.

=cut

has results => (
    traits      => [ Hash, Lazy ],
    isa         => HashRef[ 'ReUI::Event::Validate::Result' ],
    handles     => {
        results     => 'values',
        has_results => 'count',
        result_ids  => 'keys',
        _set_result => 'set',
        result      => 'get',
    },
);

method _build_results { {} }

method result_event ($id) {
    my $event = $self->make_result(
        state => $self->state,
    );
    $self->_set_result($id, $event);
    return $event;
}


method BUILD {
    $self->results; # make sure this is there for variants
}


=method apply_to

See L<ReUI::Event::API/apply_to>.

=cut

method apply_to ($object) { $object }


with qw(
    ReUI::Event::API
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

This event class is used to collect all validation information from a widget
tree. It will be dispatched to widgets outside of a validated
L<ReUI::Widget::Form>, while the validation inside a form is handled by a
L<ReUI::Event::Validate::Result> event.

=head1 METHODS

=head1 ATTRIBUTES

=head1 IMPLEMENTS

=over

=item * L<ReUI::Event::API>

=back

=head1 SEE ALSO

=over

=item * L<ReUI::Event::API>

=item * L<ReUI::Event::Validate::Result>

=back

=cut
