use strictures 1;

# ABSTRACT: Reaction registry

package ReUI::Reactor;
use Moose;

use ReUI::Traits qw( Lazy );
use ReUI::Types  qw( HashRef ArrayRef CodeRef );

use syntax qw( function method );
use namespace::autoclean;


=attr reactions

Maps the success reactions to internal IDs.

=method reactions_for

See L<ReUI::Reactor::API/reactions_for>.

=method has_reactions_for

See L<ReUI::Reactor::API/has_reactions_for>.

=method _build_reactions

    HashRef[ ArrayRef[ CodeRef ] ] = $object->_build_reactions;

Returns an empty map by default.

=cut

has reactions => (
    traits      => [ Lazy ],
    isa         => HashRef[ ArrayRef[ CodeRef ] ],
    reader      => '_reaction_data',
    init_arg    => undef,
);

method _build_reactions { {} }

method reactions_for ($action) {
    return @{ $self->_reaction_data->{ $action->internal_id } || [] };
}

method has_reactions_for ($action) {
    return scalar $self->reactions_for($action);
}


=attr failure_reactions

Maps the failure reactions to internal IDs.

=method failure_reactions_for

See L<ReUI::Reactor::API/reactions_failure_for>.

=method has_failure_reactions_for

See L<ReUI::Reactor::API/has_reactions_failure_for>.

=method _build_failure_reactions

    HashRef[ ArrayRef[ CodeRef ] ] = $object->_build_failure_reactions;

Returns an empty map by default.

=cut

has failure_reactions => (
    traits      => [ Lazy ],
    isa         => HashRef[ ArrayRef[ CodeRef ] ],
    reader      => '_failure_reaction_data',
    init_arg    => undef,
);

method _build_failure_reactions { {} }

method failure_reactions_for ($action) {
    return @{
        $self->_failure_reaction_data->{ $action->internal_id }
            || []
    };
}

method has_failure_reactions_for ($action) {
    return scalar $self->failure_reactions_for($action);
}


=method on_success

See L<ReUI::Reactor::API/on_success>.

=cut

method on_success ($action, @callbacks) {
    if (@callbacks) {
        push @{ $self->_reaction_data->{ $action->internal_id } ||= [] },
            @callbacks;
    }
    return $action;
}


=method on_failure

See L<ReUI::Reactor::API/on_failure>.

=cut

method on_failure ($action, @callbacks) {
    if (@callbacks) {
        push @{
            $self->_failure_reaction_data->{ $action->internal_id }
                ||= []
        }, @callbacks;
    }
    return $action;
}

with qw(
    ReUI::Reactor::API
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 DESCRIPTION

This class is used for managing user-supplied reactions to action control
objects. Most of the relevant interface is documented in the interface
L<ReUI::Reactor::API>.

=head1 METHODS

=head1 ATTRIBUTES

=head1 IMPLEMENTS

=over

=item * L<ReUI::Reactor::API>

=back

=head1 SEE ALSO

=over

=item * L<ReUI::Reactor::API>

=item * L<ReUI::Widget::Control::Action>

=item * L<ReUI::Event::Validate::Result/finalize>

=item * L<ReUI::State>

=back

=cut
