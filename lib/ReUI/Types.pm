use strictures 1;

# ABSTRACT: Combined type library exporter

package ReUI::Types;
use parent 'MooseX::Types::Combine';

__PACKAGE__->provide_types_from(qw(
    ReUI::Types::Common
    ReUI::Types::Objects
    MooseX::Types::Moose
    MooseX::Types::Common::String
    MooseX::Types::URI
    MooseX::Types::Path::Class
    MooseX::Types::Meta
));

1;

__END__

=head1 DESCRIPTION

Combines all L<MooseX::Types> libraries that are commonly used throughout
L<ReUI>.

=head1 TYPE LIBRARIES

=over

=item * L<ReUI::Types::Common>

=item * L<ReUI::Types::Objects>

=item * L<MooseX::Types::Moose>

=item * L<MooseX::Types::Common::String>

=item * L<MooseX::Types::URI>

=item * L<MooseX::Types::Path::Class>

=item * L<MooseX::Types::Meta>

=back

=head1 SEE ALSO

=over

=item * L<MooseX::Types::Combine>

=back

=cut
