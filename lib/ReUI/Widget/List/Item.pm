use strictures 1;

package ReUI::Widget::List::Item;
use Moose;

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Container';


around compile => fun ($orig, $self, $state) {
    return $state->markup_for($self)
        ->apply($self->identity_populator_for('li'))
        ->memoize
        ->select('li')
        ->replace_content($self->$orig($state));
};


with qw(
    ReUI::Role::ElementClasses
);

__PACKAGE__->meta->make_immutable;

1;
