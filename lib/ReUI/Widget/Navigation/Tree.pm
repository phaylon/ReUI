use strictures 1;

package ReUI::Widget::Navigation::Tree;
use Moose;

use ReUI::Traits    qw( Lazy Resolvable );
use ReUI::Types     qw( Any );
use HTML::Zoom;

use syntax qw( function method );
use namespace::autoclean;


has expand_if => (
    traits      => [ Lazy, Resolvable ],
    is          => 'rw',
    isa         => Any,
    required    => 1,
);

method _build_expand_if { 1 }


method compile ($state) {
    my $stream = $state->markup_for($self)->to_events;
    my $trail  = $self->resolve_trail($state);
    return $self->compile_level($state, $stream, $trail, 0, $self->model);
}

method compile_level ($state, $stream, $trail, $level, $parent) {
    my @nodes  = $parent->children;
    my $marker = $self->trail_marker($trail);
    return HTML::Zoom->from_events($stream)
        ->apply_if(
            $level == 0,
            $self->identity_populator_for('.navigation-tree'),
        )
        ->select('.navigation-tree')
        ->add_to_attribute(class => "level-${level}")
        ->memoize
        ->select('.navigation-tree')
        ->repeat_content([ map {
            my $node     = $_;
            my $children = $self->children_populator_cb(
                $state,
                $stream,
                $trail,
                $level + 1,
                $node,
            );
            sub {
                $_->select('.node-link')
                  ->set_attribute(href => $state->render($node->uri))
                  ->then
                  ->replace_content($state->render($node->title))
                  ->apply($marker->($node, $children));
            };
        } @nodes ])
        ->memoize;
}

method children_populator_cb ($state, $stream, $trail, $level, $parent) {
    return fun (%args) {
        return sub { $_ }
            unless  $parent->has_children
                and $self->resolve_expand_if(
                    $state, %args, parent => $parent, level => $level);
        return sub {
            my $children = $self->compile_level(
                $state, $stream, $trail, $level, $parent);
            $_->select('li')
              ->append_content($children->to_events);
        };
    };
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
