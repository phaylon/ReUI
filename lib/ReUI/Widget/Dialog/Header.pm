use strictures 1;

package ReUI::Widget::Dialog::Header;
use Moose;

use ReUI::Traits        qw( Array Prototyped Resolvable );
use ReUI::Types         qw( Renderable ArrayRef Does );
use Params::Classify    qw( is_blessed );

use syntax qw( function method );
use namespace::autoclean;


has title => (
    traits      => [ Resolvable ],
    is          => 'ro',
    isa         => Renderable,
);


has left_header => (
    traits      => [ Array, Prototyped ],
    isa         => ArrayRef[ Does['ReUI::Widget::API'] ],
    handles     => {
        left_header_widgets     => 'elements',
        has_left_header_widgets => 'count',
    },
);


has right_header => (
    traits      => [ Array, Prototyped ],
    isa         => ArrayRef[ Does['ReUI::Widget::API'] ],
    handles     => {
        right_header_widgets     => 'elements',
        has_right_header_widgets => 'count',
    },
);


method compile ($state) {
    my $title    = $self->resolve_title($state);
    my $optional = fun ($selected, $count, $compile) {
        return $self->$count
            ? $selected->replace_content($self->$compile($state))
            : $selected->replace([])
    };
    return $state->markup_for($self)
        ->select('.left')
        ->replace_content($self->compile_left_header($state))
        ->select('.right')
        ->replace_content($self->compile_right_header($state))
        ->select('.title')
        ->replace_content($state->render($title));
}

method event_propagation_targets {
    my $title = $self->title;
    return(
        $self->left_header_widgets,
        is_blessed($title) ? $title : (),
        $self->right_header_widgets,
    );
}


with qw(
    ReUI::Widget::API
    ReUI::Widget::API::Styled
    ReUI::Role::ElementClasses
    ReUI::Role::EventHandling::Propagation
);

1;
