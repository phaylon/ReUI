use strictures 1;

# ABSTRACT: View interface

package ReUI::View::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

with qw(
    ReUI::View::Provider::API
);

1;

__END__

=head1 DESCRIPTION

This interface is used by the view and objects that want to delegate certain
common operations.

=head1 IMPLEMENTS

=over

=item * L<ReUI::View::Provider::API>

=back

=head1 SEE ALSO

=item * L<ReUI::View::Provider::API>

=item * L<ReUI::View>

=cut
