use strictures 1;

# ABSTRACT: Action base

package ReUI::Widget::Control::Action;
use Moose;

use ReUI::Traits    qw( Array Lazy );
use ReUI::Types     qw( CodeRefList );
use HTML::Zoom;

use syntax qw( function method );
use namespace::autoclean;


has success_callbacks => (
    traits      => [ Array, Lazy ],
    isa         => CodeRefList,
    coerce      => 1,
    init_arg    => 'on_success',
    handles     => {
        on_success              => 'push',
        success_callbacks       => 'elements',
        has_success_callbacks   => 'count',
    },
);

method _build_success_callbacks { [] }


has failure_callbacks => (
    traits      => [ Array, Lazy ],
    isa         => CodeRefList,
    coerce      => 1,
    init_arg    => 'on_failure',
    handles     => {
        on_failure              => 'push',
        failure_callbacks       => 'elements',
        has_failure_callbacks   => 'count',
    },
);

method _build_failure_callbacks { [] }


method compile_with_value { HTML::Zoom->from_events([]) }

method find_value ($state) {
    return $state->parameter($self->name_in($state));
}

method validate ($state) { $self->find_value($state) }

method _run_callbacks ($state, $args, @callbacks) {
    for my $callback (@callbacks) {
        local *_ = $state->variables;
        $callback->(@$args);
    }
    return 1;
}

method _resolved_callbacks ($state, @callbacks) {
    return map {
        my $cb = $_;
        fun (@args) { $state->resolve($cb, @args) };
    } @callbacks;
}

method perform ($state, $result) {
    return $self->_run_callbacks(
        $state,
        [$result],
        $state->reactions_for($self),
        $self->_resolved_callbacks(
            $state,
            $self->success_callbacks,
        ),
    );
}

method failure ($state, $global_errors, $control_errors) {
    return $self->_run_callbacks(
        $state,
        [$global_errors, $control_errors],
        $state->failure_reactions_for($self),
        $self->_resolved_callbacks(
            $state,
            $self->failure_callbacks,
        ),
    );
}

with qw(
    ReUI::Widget::Control::API
    ReUI::Role::Identification::Internal
);

before store_valid_value => method ($event, $value) {
    $event->action($self);
};

1;
