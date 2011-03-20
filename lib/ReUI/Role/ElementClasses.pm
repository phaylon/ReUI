use strictures 1;

# ABSTRACT: Provide classes for the markup

package ReUI::Role::ElementClasses;
use Moose::Role;

use ReUI::Traits qw( Array Lazy );
use ReUI::Types  qw( IdentifierList );

use syntax qw( function method );
use namespace::autoclean;

has classes => (
    traits      => [ Array, Lazy ],
    isa         => IdentifierList,
    coerce      => 1,
    handles     => {
        classes         => 'elements',
        has_classes     => 'count',
        classes_string  => [join => ' '],
    },
);

method _build_classes { [] }

around identity_populator_for => fun ($orig, $self, $selector) {
    my $next = $self->$orig($selector);
    return sub {
        return $_->apply($next)->apply_if($self->has_classes, sub {
            return $_->select($selector)->add_to_attribute(
                class => $self->classes_string,
            );
        });
    };
};

1;
