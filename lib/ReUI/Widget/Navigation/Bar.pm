use strictures 1;

package ReUI::Widget::Navigation::Bar;
use Moose;

use ReUI::Traits    qw( Resolvable );
use ReUI::Types     qw( Maybe ArrayRef NonEmptySimpleStr );

use syntax qw( function method );
use namespace::autoclean;


has included_node_ids => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => Maybe[ ArrayRef[ NonEmptySimpleStr ] ],
    init_arg    => 'include',
);


method compile ($state) {
    my $trail  = $self->resolve_trail($state);
    my $id_map = $trail->id_map;
    my $marker = $self->trail_marker($trail);
    return $state->markup_for($self)
        ->apply($self->identity_populator_for('.navigation-bar'))
        ->select('.navigation-bar')
        ->repeat_content([
            map {
                my $node = $_;
                sub {
                    $_->select('.node-link')
                      ->set_attribute(href => $state->render($node->uri))
                      ->then
                      ->replace_content($state->render($node->title))
                      ->apply($marker->($node));
                };
            } $self->find_displayable_nodes($state, $trail),
        ])
        ->memoize;
}

method find_displayable_nodes ($state, $trail) {
    my @nodes   = $self->resolve_model($state)->children;
    my $include = $self->resolve_included_node_ids($state)
        or return @nodes;
    my %ids     = map { ($_ => 1) } @$include;
    return grep { $ids{ $_->id } } @nodes;
}


with qw(
    ReUI::Widget::API
    ReUI::Widget::API::Styled
    ReUI::Widget::Navigation::API
    ReUI::Widget::Navigation::API::Rooted
    ReUI::Role::ElementClasses
);

__PACKAGE__->meta->make_immutable;

1;
