use strictures 1;

package ReUI::Widget::Message;
use Moose;

use ReUI::Traits        qw( Resolvable );
use ReUI::Types         qw( MessageType Renderable Uri Undef );
use ReUI::Constants     qw( :skinfiles );
use Params::Classify    qw( is_blessed );

use syntax qw( function method );
use namespace::autoclean;


has type => (
    is          => 'rw',
    isa         => MessageType,
    required    => 1,
);

has content => (
    is          => 'rw',
    isa         => Renderable,
    required    => 1,
);


has icon_uri => (
    traits      => [ Resolvable ],
    is          => 'ro',
    isa         => Uri | Undef,
);


method locate_icon_uri ($state) {
    if (my $given = $self->resolve_icon_uri($state)) {
        return $given;
    }
    return $state->uri_for_current_skin(
        SKINFILE_MESSAGE_ICON_PATH,
        [$self->type, 'png'],
    );
}

method compile ($state) {
    return $state->markup_for($self)
        ->apply(sub {
            my $icon_uri = $self->locate_icon_uri($state);
            my $selected = $_->select('.message-icon');
            defined($icon_uri)
                ? $selected->set_attribute(src => $icon_uri)
                : $selected->replace([]);
        })
        ->apply($self->identity_populator_for('.message'))
        ->select('.message')
        ->add_to_attribute(class => $self->type)
        ->select('.message-content')
        ->replace_content($state->render($self->content))
        ->memoize;
}

method event_propagation_targets {
    my $content = $self->content;
    return is_blessed($content) ? $content : ();
}


with qw(
    ReUI::Widget::API
    ReUI::Widget::API::Styled
    ReUI::Role::ElementClasses
    ReUI::Role::EventHandling::Propagation
);

1;
