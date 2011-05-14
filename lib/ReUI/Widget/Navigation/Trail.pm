use strictures 1;

package ReUI::Widget::Navigation::Trail;
use Moose;

use ReUI::Types qw( Int NonEmptySimpleStr );
use ReUI::Util  qw( trailing leading );

use syntax qw( function method );
use namespace::autoclean;


has limit => (
    is          => 'rw',
    isa         => Int,
);


method compile ($state) {
    my ($cutoff, @nodes) = $self->find_displayable_nodes($state);
    my $separator = $state->markup_for($self, 'separator');
    return $state->markup_for($self)
        ->apply($self->identity_populator_for('.navigation-trail'))
        ->select('.navigation-trail')
        ->repeat_content(
            [ map {
                my $node = $nodes[ $_ ];
                $self->crumb_populator($state, $node, $_, $#nodes, $cutoff);
            } 0 .. $#nodes ],
            { repeat_between => '.trail-separator' },
        )
        ->memoize
        ->select('.trail-separator')
        ->replace($separator);
}

method crumb_populator ($state, $node, $index, $last, $cutoff) {
    return sub {
        $_->select('.node-link')
          ->set_attribute(href => $state->render($node->uri))
          ->then
          ->replace_content($state->render($node->title))
          ->apply_if($index == 0, sub {
              $_->select('.navigation-node')
                ->add_to_attribute(class => 'first');
          })
          ->apply_if($index == $last, sub {
              $_->select('.navigation-node')
                ->add_to_attribute(class => 'last');
          })
          ->apply_if($cutoff == $index, sub {
              $_->select('.navigation-node')
                ->add_to_attribute(class => 'cutoff');
          });
    };
}

method find_displayable_nodes ($state) {
    my @nodes = $self->resolve_trail($state)->nodes;
    my $limit = $self->limit;
    return -1, @nodes
        unless $limit;
    if ($limit > 0) {
        my @display = leading $limit, @nodes;
        return @display != @nodes ? $#display : -1, @display;
    }
    else {
        my @display = trailing abs($limit), @nodes;
        return @display != @nodes ? 0 : -1, @display;
    }
}


with qw(
    ReUI::Widget::API
    ReUI::Widget::API::Styled
    ReUI::Widget::Navigation::API
    ReUI::Role::ElementClasses
);

__PACKAGE__->meta->make_immutable;

1;
