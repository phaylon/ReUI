use strictures 1;

# ABSTRACT: Response interface

package ReUI::Response::API;
use Moose::Role;

use ReUI::Traits qw( LazyRequire );
use ReUI::Types  qw( Str );

use syntax qw( function method );
use namespace::autoclean;

requires qw( content_type );


=attr body

Contains the body of the response as a string.

=method body

Returns the content of the L</body> attribute.

=method _build_body

    Str = $object->_build_body;

Needs to return the body string or an error will be thrown on first use.

=cut

has body => (
    traits      => [ LazyRequire ],
    is          => 'ro',
    isa         => Str,
);


1;

__END__

=head1 DESCRIPTION

This interface is implemented by all response types. Different requests
might return different types of responses. A non-usual example would be a
response to an AJAX request.

=head1 ATTRIBUTES

=head1 REQUIRED

=head2 content_type

Needs to return the content type of the response so the surrounding framework
can prepare the response.

=head1 SEE ALSO

=over

=item * L<ReUI::Response::Markup>

=item * L<ReUI::State/process>

=back

=cut
