use strictures 1;

# ABSTRACT: Action base

package ReUI::Widget::Control::Action;
use Moose;

use HTML::Zoom;

use syntax qw( function method );
use namespace::autoclean;

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

method perform ($state, $result) {
    return $self->_run_callbacks(
        $state,
        [$result],
        $state->reactions_for($self),
    );
}

method failure ($state, $global_errors, $control_errors) {
    return $self->_run_callbacks(
        $state,
        [$global_errors, $control_errors],
        $state->failure_reactions_for($self),
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
