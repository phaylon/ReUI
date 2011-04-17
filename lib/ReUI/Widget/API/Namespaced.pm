use strictures 1;

package ReUI::Widget::API::Namespaced;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw(
    has_name
    name
    compile
);

around compile => fun ($orig, $self, $state) {
    return $self->$orig($state->descend($self->name));
};

#for my $wrapped (qw( compile propagate_event )) {
#    around "$wrapped" => fun ($orig, $self, $proto) {
#        if ($self->has_name) {
#            $proto = $proto->descend($self->name);
#        }
#        return $self->$orig($proto);
#    };
#}

1;
