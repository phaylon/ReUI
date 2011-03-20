use strictures 1;

# ABSTRACT: Reaction registry interface

package ReUI::Reactor::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw(
    reactions_for
    failure_reactions_for
    has_reactions_for
    has_failure_reactions_for
    on_success
    on_failure
);

1;

__END__

=head1 DESCRIPTION

This interface is provided by all classes allowing validation reaction
management.

=head1 REQUIRED

=head2 reactions_for

    ( CodeRef, ... ) = $object->reactions_for( $action );

Returns all registered success reactions for the specified C<$action>.

=head2 has_reactions_for

    Bool = $object->has_reactions_for( $action );

Returns true if any success reactions are known for the specified C<$action>,
false otherwise.

=head2 failure_reactions_for

    ( CodeRef, ... ) = $object->failure_reactions_for( $action );

Returns all registered failure reactions for the specified C<$action>.

=head2 has_failure_reactions_for

    Bool = $object->has_failure_reactions_for( $action );

Returns true if any failure reactions are known for the specified C<$action>,
false otherwise.

=head2 on_success

    $action = $object->on_success( $action, @callbacks );

This will register the provided subroutines in C<@callbacks> as success
reactions for the C<$action>. It will also return the C<$action> object
to allow better inlining.

=head2 on_failure

    $action = $object->on_failure( $action, @callbacks );

This will register the provided subroutines in C<@callbacks> as failure
reactions for the C<$action>. It will also return the C<$action> object
to allow better inlining.

=head1 SEE ALSO

=over

=item * L<ReUI::Reactor>

=item * L<ReUI::Widget::Control::Action>

=item * L<ReUI::Event::Validate::Result/finalize>

=back

=cut
