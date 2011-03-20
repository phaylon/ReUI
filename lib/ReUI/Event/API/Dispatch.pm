use strictures 1;

# ABSTRACT: Dispatch event to specific widget method

package ReUI::Event::API::Dispatch;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw( dispatch_method );


=method dispatch_arguments

    ( Any, ... ) = $object->dispatch_arguments;

Returns the values that should be passed to the target method returned from
L</dispatch_method> when L</apply_to> is called.

=cut

method dispatch_arguments { () }


=method apply_to

    $object->apply_to( $widget );

Will call the method returned by L</dispatch_method> on the C<$widget> with
the L</dispatch_arguments> if the method is implemented.

=cut

method apply_to ($object) {
    if (my $method = $object->can($self->dispatch_method)) {
        $object->$method($self, $self->dispatch_arguments($object));
    }
    return $object;
}

with qw(
    ReUI::Event::API
);

1;

__END__

=head1 DESCRIPTION

This event interface will hook into L<ReUI::Event::API/apply_to> and dispatch
to a method named by L</dispatch_method> on the target object.

=head1 METHODS

=head1 REQUIRED

=head2 dispatch_method

    Str = $object->dispatch_method;

The name of the method to which the event should be dispatched. This method
will be called on the target object with the arguments returned by
L</dispatch_arguments>.

=head1 IMPLEMENTS

=over

=item * L<ReUI::Event::API>

=back

=head1 SEE ALSO

=over

=item * L<ReUI::Event::API>

=back

=cut
