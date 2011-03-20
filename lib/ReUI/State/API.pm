use strictures 1;

# ABSTRACT: State interface

package ReUI::State::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw(
    render
    namespace
    descend
    variables
    resolve
);

with qw(
    ReUI::Request::API
    ReUI::Reactor::API
    ReUI::View::API
);

1;

__END__

=head1 DESCRIPTION

This interface is implemented by all classes that contain a per-request state
or those that wish to be used in place of state objects.

=head1 REQUIRED

=head2 render

    Str | HTML::Zoom = $object->render( $value );

Takes an L<I18N|ReUI::Types::Common/I18N> value, a widget implementing
L<ReUI::Widget::API>, or a code reference resolving to one of them and returns
a rendered value. Simple values like internationaliued values return strings,
while complex markup is returned as an L<HTML::Zoom> object.

=head2 namespace

    Namespace = $object->namespace;

Returns the L<Namespace|ReUI::Types::Common/Namespace> the state is currently
in.

=head2 descend

    Object = $object->descend( $name );

Returns a new state with a L</namespace> one level deeper as specified by
C<$name>.

=head2 variables

    HashRef = $object->variables;

Returns a hash reference of user supplied variables.

=head2 resolve

    Any = $object->resolve( $value );

If the supplied C<$value> is a code reference, it will be evaluated with
the L</variables> localised into C<%_> and returned, otherwise the passed
in value is returned as-is.

=head1 IMPLEMENTS

=over

=item * L<ReUI::Request::API>

=item * L<ReUI::Reactor::API>

=item * L<ReUI::View::API>

=back

=head1 SEE ALSO

=over

=item * L<ReUI::State>

=item * L<HTML::Zoom>

=back

=cut
