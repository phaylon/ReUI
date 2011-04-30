use strictures 1;

package ReUI::Widget::Page::Layout::Simple;
use Moose;

use ReUI::Types     qw( Bool );
use ReUI::Traits    qw( Lazy Resolvable );

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Page';


has show_header => (
    traits      => [ Lazy, Resolvable ],
    is          => 'rw',
    isa         => Bool,
);

method _build_show_header { 1 }


around compile_widgets => fun ($orig, $self, $state, @widgets) {
    my $show_header = $self->resolve_show_header($state);
    my $header      = $self->header;
    return $self->$orig(
        $state,
        $show_header ? $header : (),
        @widgets,
    );
};

around event_propagation_targets => fun ($orig, $self, @args) {
    return $self->$orig(@args), $self->header;
};


with qw(
    ReUI::Widget::Page::Layout::Role::Header
);

1;
