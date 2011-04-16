use strictures 1;

package ReUI::Demo::Screen::Forms;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

around _build_screen_options => fun ($orig, $self) {
    $self->$orig,
    forms => {
        title   => 'Forms',
        builder => fun ($state, @path) {
            return;
        },
    },
};

1;
