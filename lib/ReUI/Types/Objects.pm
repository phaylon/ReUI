use strictures 1;

# ABSTRACT: Object types

package ReUI::Types::Objects;

use ReUI::Util              qw( load_class );
use MooseX::Types::Moose    qw( :all );

use namespace::clean;

use MooseX::Types -declare => [qw(
    Request
)];

my %Namespace = map { ($_, "ReUI::$_") } qw(
    Request
);

for my $type (keys %Namespace) {
    my $constraint = __PACKAGE__->can($type)->();
    role_type $constraint, {
        role => join('::', $Namespace{ $type }, 'API'),
    };
    coerce $constraint, from HashRef, via {
        load_class($Namespace{ $type })->new(%$_);
    };
}

1;

__END__

=head1 SYNOPSIS

    use ReUI::Types::Objects qw( Request );

=head1 DESCRIPTION

This module contains a collection of object types. These are types that
expect objects of specific classes or subclasses. A coercion from hash
references is provided by default.

The types in this library are also part of the L<ReUI::Types> combination.

=head1 TYPES

=head2 Request

Requires an instance of L<ReUI::Request> or a subclass thereof.

=head1 SEE ALSO

=over

=item * L<ReUI::Types>

=item * L<MooseX::Types>

=item * L<Moose::Manual::Types>

=back

=cut
