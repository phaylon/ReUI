use strictures 1;

# ABSTRACT: Markup provider interface

package ReUI::View::Provider::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw(
    markup_for
);

1;

__END__

=head1 DESCRIPTION

This interface is implemented by markup providers and all objects that need
to delegate those functionalities.

=head1 REQUIRED

=head2 markup_for

    HTML::Zoom = $object->markup_for( $part? );

This will load and return the markup in form of an L<HTML::Zoom> stream. The
optional C<$part> will default to C<base>. If markup needs to be broken up
into different pieces, parts can be used to separate them.

=head1 SEE ALSO

=over

=item * L<ReUI::View::Provider::Auto>

=item * L<ReUI::View>

=item * L<HTML::Zoom>

=back

=cut
