use strictures 1;

package ReUI::State::Result;
use Moose;

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::State';


=attr result

Holds an object implementing L<ReUI::Event::Validate::Result::API>, which
will also be completely delegated to this attribute.

=method result

    Object = $object->result;

Returns the result object.

=method has_result

    Bool = $object->has_result;

Returns true if a result object is available, otherwise false.

=cut

has result => (
    is          => 'ro',
    does        => 'ReUI::Event::Validate::Result::API',
    handles     => 'ReUI::Event::Validate::Result::API',
);

method has_result { defined $self->result }


=method new_from_state

    Object = $class->new_from_state( %arguments );

Creates a new instance from an existing state object that must be passed in
as C<state> argument. An optional C<result> argument can be passed in as well.

=cut

method new_from_state ($class: %args) {
    return $class->meta->rebless_instance(
        $args{state}->meta->clone_object($args{state}),
        $args{result} ? (result => $args{result}) : (),
    );
}

with qw(
    ReUI::Event::Validate::Result::API
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

This is a subclass of L<ReUI::State> linking the state with a specific
L<ReUI::Event::Validate::Result> to be used for compilation inside of a
L<ReUI::Widget::Form>.

=head1 METHODS

=head1 ATTRIBUTES

=head1 EXTENDS

=over

=item * L<ReUI::State>

=back

=head1 IMPLEMENTS

=over

=item * L<ReUI::Event::Validate::Result::API>

=back

=head1 SEE ALSO

=cut
