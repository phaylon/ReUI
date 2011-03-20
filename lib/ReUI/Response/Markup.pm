use strictures 1;

# ABSTRACT: Full-body markup response

package ReUI::Response::Markup;
use Moose;

use syntax qw( function method );
use namespace::autoclean;


=attr state

Contains the state object that should be rendered. The object needs to
implement L<ReUI::State::API>, which is also fully delegated to this
attribute. The value is required and must be passed in at construction
time.

=method state

    Object = $object->state;

Returns the state object.

=cut

has state => (
    is          => 'ro',
    does        => 'ReUI::State::API',
    required    => 1,
    handles     => 'ReUI::State::API',
);


=method _build_body

    Str = $object->_build_body;

Lazily renders the body from the widgets in the L</state>.

=cut

method _build_body {
    my $markup = $self->state->render_root;
    return $markup->to_html;
}


=method content_type

Returns C<text/html> by default.

=cut

method content_type { 'text/html' }


with qw(
    ReUI::Response::API
);

1;

__END__

=head1 DESCRIPTION

This class represents full page markup responses.

=head1 METHODS

=head1 ATTRIBUTES

=head1 IMPLEMENTS

=over

=item * L<ReUI::Response::API>

=back

=head1 SEE ALSO

=over

=item * L<ReUI::Response::API>

=item * L<ReUI::State/process>

=back

=cut
