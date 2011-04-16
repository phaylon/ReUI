use strictures 1;

package ReUI::Widget::Page::Layout::Simple;
use Moose;

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Page';


has show_header => (
    traits      => [ Lazy ],
    is          => 'rw',
    isa         => Bool,
);

method _build_show_header { 1 }


around compile_widgets => fun ($orig, $self, $state, @widgets) {
    return $self->$orig(
        $state,
        $self->show_header ? $self->header : (),
        @widgets,
    );
};


with qw(
    ReUI::Widget::Page::Layout::Role::Header
);

1;
