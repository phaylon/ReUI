use strictures 1;

# ABSTRACT: Generic form container

package ReUI::Widget::Form;
use Moose;

use ReUI::Traits qw( Lazy LazyRequire Resolvable RelatedClass );
use ReUI::Types  qw( RequestMethod Uri Maybe NonEmptySimpleStr Bool );

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Container';

has method => (
    traits      => [ Lazy ],
    is          => 'ro',
    isa         => RequestMethod,
    coerce      => 1,
);

method _build_method { 'GET' }

has action => (
    traits      => [ LazyRequire, Resolvable ],
    is          => 'ro',
    isa         => Uri,
    coerce      => 1,
);

has enctype => (
    traits      => [ Lazy, Resolvable ],
    is          => 'ro',
    isa         => Maybe[ NonEmptySimpleStr ],
);

method _build_enctype { 'multipart/form-data' }

has indicator_class => (
    traits      => [ RelatedClass ],
);

method _build_indicator_class { 'ReUI::Widget::Control::Hidden' }

has indicator => (
    traits      => [ Lazy ],
    is          => 'ro',
    does        => 'ReUI::Widget::Control::API',
    handles     => {
        is_indicator_value_present_in => 'find_value',
    },
);

method _build_indicator {
    return $self->make_indicator(
        name    => '_reui_indicator',
        classes => 'form-indicator',
        force   => 1,
        value   => 1,
    );
}

has ignore_indicator => (
    is          => 'ro',
    isa         => Bool,
);

has result_state_class => (
    traits      => [ RelatedClass ],
    build_via   => 'new_from_state',
);

method _build_result_state_class { 'ReUI::State::Result' }

method is_submitted_in ($state) {
    return $self->method eq $state->method
        and (
               $self->ignore_indicator
            or $self->is_indicator_value_present_in($state)
        );
}

around propagate_event => fun ($orig, $self, $event) {
    if ($event->isa('ReUI::Event::Validate')) {
        return unless $self->is_submitted_in($event);
        my $result = $event->result_event($self->internal_id);
        my $done   = $self->$orig($result);
        $result->finalize;
        return $done;
    }
    else {
        return $self->$orig($event);
    }
};

around compile => fun ($orig, $self, $state) {
    my $name   = $state->namespace;
    my $result = $state->validation->result($self->internal_id);
    my $inner  = $self->make_result_state(
        state  => $state,
        result => $result,
    );
    my $enctype = $self->resolve_enctype($inner);
    my $class =
        $inner->has_result
            ? $inner->has_errors
                ? 'failure'
                : 'success'
            : undef;
    return $inner->markup_for($self)
        ->select('form')
        ->set_attribute(method => $self->method)
        ->then
        ->set_attribute(action => $self->resolve_action($inner))
        ->then
        ->set_attribute(name => $name)
        ->then
        ->replace_content($inner->render($self->indicator))
        ->apply_if(defined($enctype), sub {
            $_->then->set_attribute(enctype => $enctype);
        })
        ->apply_if(defined($class), sub {
            $_->then->add_to_attribute(class => $class);
        })
        ->apply($self->identity_populator_for('form'))
        ->memoize
        ->select('form')
        ->append_content($self->$orig($inner)->to_events);
};

with qw(
    ReUI::Role::Identification::Internal
    ReUI::Role::ElementClasses
    ReUI::Role::ElementName
);

# separate so all attributes are found (name)
with qw(
    ReUI::Widget::Container::API::Namespaced
);

1;
