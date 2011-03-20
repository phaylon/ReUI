use strictures 1;

package ReUI::Widget::Container::API::Namespaced;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

with qw( ReUI::Role::ElementName );

for my $wrapped (qw( compile propagate_event )) {
    around "$wrapped" => fun ($orig, $self, $proto) {
        if ($self->has_name) {
            $proto = $proto->descend($self->name);
        }
        return $self->$orig($proto);
    };
}

1;
