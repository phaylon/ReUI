use strictures 1;

package ReUI::Widget::Dialog::Form;
use Moose;

use ReUI::Traits    qw( Lazy RelatedClass );

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Dialog';


has '+content_class' => (proxy => [qw( name method action )]);

method _build_content_class { 'ReUI::Widget::Form' }
around content_arguments => fun ($orig, $self, @args) {
    $self->$orig(@args),
    widgets => [
        $self->global_errors,
        $self->control_set,
        $self->action_set,
    ],
};


has global_errors_class => (
    traits      => [ RelatedClass ],
);

has global_errors => (
    traits      => [ Lazy ],
    is          => 'ro',
    init_arg    => undef,
    isa         => 'ReUI::Widget::Form::GlobalErrors',
);

method _build_global_errors_class   { 'ReUI::Widget::Form::GlobalErrors' }
method _build_global_errors         { $self->make_global_errors }


has control_set_class => (
    traits      => [ RelatedClass ],
    proxy       => [qw( controls )],
);

has control_set => (
    traits      => [ Lazy ],
    is          => 'ro',
    init_arg    => undef,
    isa         => 'ReUI::Widget::ControlSet',
    handles     => [qw( controls has_controls )],
);

method _build_control_set_class { 'ReUI::Widget::ControlSet' }
method _build_control_set       { $self->make_control_set }
method control_set_arguments    { name => 'controls' }


has action_set_class => (
    traits      => [ RelatedClass ],
    proxy       => [qw( actions )],
);

has action_set => (
    traits      => [ Lazy ],
    is          => 'ro',
    init_arg    => undef,
    isa         => 'ReUI::Widget::ActionSet',
    handles     => [qw( action actions has_actions add_actions )],
);

method _build_action_set_class { 'ReUI::Widget::ActionSet' }
method _build_action_set       { $self->make_action_set }
method action_set_arguments    { () }

1;
