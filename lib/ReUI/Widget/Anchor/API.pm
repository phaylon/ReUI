use strictures 1;

package ReUI::Widget::Anchor::API;
use Moose::Role;

use ReUI::Types  qw( NonEmptySimpleStr );
use ReUI::Traits qw( Lazy );

use syntax qw( function method );
use namespace::autoclean;


has link_selector => (
    traits      => [ Lazy ],
    is          => 'ro',
    isa         => NonEmptySimpleStr,
    required    => 1,
);

method _build_link_selector { 'a' }


method anchor_attributes ($state) { () }

around compile => fun ($orig, $self, $state) {
    my $selector = $self->link_selector;
    return $state->markup_for($self)
        ->apply($self->identity_populator_for($selector))
        ->apply($self->attribute_set_populator_for(
            $selector,
            $self->anchor_attributes($state),
        ))
        ->memoize
        ->select($selector)
        ->replace_content($self->$orig($state));
};


with qw(
    ReUI::Role::ElementClasses
);

1;
