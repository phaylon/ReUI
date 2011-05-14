use strictures 1;

package ReUI::Widget::Dialog;
use Moose;

use ReUI::Traits    qw( RelatedClass Lazy Resolvable );
use ReUI::Types     qw( Bool );

use syntax qw( function method );
use namespace::autoclean;


has content_class => (
    traits      => [ RelatedClass ],
    proxy       => [qw( widgets )],
);

has content => (
    traits      => [ Lazy ],
    is          => 'ro',
    does        => 'ReUI::Widget::API',
    handles     => {
        compile_content => 'compile',
    },
);

method _build_content_class { 'ReUI::Widget::Container' }
method _build_content       { $self->make_content }
method content_arguments    { () }


has header_class => (
    traits      => [ RelatedClass ],
    proxy       => [qw( title left_header right_header )],
);

has header => (
    traits      => [ Lazy ],
    is          => 'ro',
    does        => 'ReUI::Widget::API',
    handles     => {
        compile_header => 'compile',
    },
);

method _build_header_class { 'ReUI::Widget::Dialog::Header' }
method _build_header       { $self->make_header }


has show_header => (
    traits      => [ Lazy, Resolvable ],
    is          => 'ro',
    isa         => Bool,
    required    => 1,
);

method _build_show_header { 1 }


method compile ($state) {
    my $show_header = $self->resolve_show_header($state);
    return $state->markup_for($self)
        ->apply($self->identity_populator_for('.dialog'))
        ->memoize
        ->apply(sub {
            my $selected = $_->select('.dialog-header');
            $show_header
                ? $selected->replace_content($self->compile_header($state))
                : $selected->replace([]);
        })
        ->memoize
        ->select('.dialog-content')
        ->replace_content($self->compile_content($state));
}

method event_propagation_targets {
    $self->header,
    $self->content,
}


with qw(
    ReUI::Widget::API
    ReUI::Widget::API::Styled
    ReUI::Role::ElementClasses
    ReUI::Role::EventHandling::Propagation
);

__PACKAGE__->meta->make_immutable;

1;
