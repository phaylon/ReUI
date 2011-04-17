use strictures 1;

package ReUI::Widget::ActionSet;
use Moose;

use ReUI::Traits qw( RelatedClass Array Prototyped );
use ReUI::Types  qw( ArrayRef );

use syntax qw( function method );
use namespace::autoclean;


has action_class => (
    traits      => [ RelatedClass ],
);

method _build_action_class { 'ReUI::Widget::Control::Submit' }


has actions => (
    traits      => [ Array, Prototyped ],
    isa         => ArrayRef[ 'ReUI::Widget::Control::Action' ],
    required    => 1,
    make_via    => 'make_action',
    handles     => {
        actions         => 'elements',
        add_actions     => 'push',
        has_actions     => 'count',
        action          => 'get',
        _first_action   => 'first',
    },
);


around add_actions => fun ($orig, $self, @actions) {
    return $self->$orig($self->_inflate_actions(@actions));
};

method action_by_name ($name) {
    return $self->_first_action(sub { $_->name eq $name });
}


method compile ($state) {
    return $state->markup_for($self)
        ->apply($self->identity_populator_for('.action-set'))
        ->memoize
        ->select('.action-set')
        ->replace_content($self->compile_actions($state));
};


with qw(
    ReUI::Widget::API
    ReUI::Role::ElementClasses
);

1;
