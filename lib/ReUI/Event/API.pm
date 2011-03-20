use strictures 1;

# ABSTRACT: Event interface

package ReUI::Event::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw( apply_to );

=attr state

    Does[ ReUI::State::API ] = $object->state;

Required attribute containing the current state object. The value needs to
implement and delegates the interface L<ReUI::State::API>.

=cut

has state => (
    is          => 'ro',
    does        => 'ReUI::State::API',
    handles     => 'ReUI::State::API',
    required    => 1,
);

=method descend

    Does[ ReUI::Event::API ] = $object->descend( @arguments );

Returns a new event object in a lower namespace that is extended by the
passed C<@arguments>. These values will be passed to passed to
L<ReUI::State/descend>, and the resulting state object will be placed with
the new event.

=cut

around descend => fun ($orig, $self, @args) {
    return $self->variant(state => $self->state->descend(@args));
};

with qw(
    ReUI::Role::Variations
);

1;

__END__

=head1 DESCRIPTION

This is the interface that must be implemented by all classes that need to
be valid L<ReUI> events.

=head1 ATTRIBUTES

=head1 METHODS

=head1 REQUIRED

=head2 apply_to

    $event->apply_to( $object );

Called to apply the C<$event> to the C<$object>. The behaviour is event
specific. L<ReUI::Event::API::Dispatch> will dispatch to specific methods.

=head1 IMPLEMENTS

=over

=item * L<ReUI::Role::Variations>

=back

=head1 SEE ALSO

=over

=item * L<ReUI::Event::API::Dispatch>

=back

=cut
