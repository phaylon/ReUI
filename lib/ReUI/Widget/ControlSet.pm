use strictures 1;

package ReUI::Widget::ControlSet;
use Moose;

use ReUI::Types  qw( ArrayRef Does );
use ReUI::Traits qw( Array Prototyped );
use ReUI::Util   qw( load_class );
use Carp         qw( confess );

use syntax qw( function method );
use namespace::autoclean;


has controls => (
    traits      => [ Array, Prototyped ],
    isa         => ArrayRef[ Does['ReUI::Widget::Control::API'] ],
    required    => 1,
    make_via    => '_make_control',
    compile_all => undef,
    handles     => {
        controls        => 'elements',
        has_controls    => 'count',
    },
);

method _make_control (%args) {
    my $class = delete $args{class}     # FIXME should be exception
        or confess q{Expected class option for control};
    return load_class($class)->new(%args);
}


method compile ($state) {
    return $state->markup_for($self)
        ->apply($self->identity_populator_for('.control-set'))
        ->memoize
        ->select('.control-set-item')
        ->repeat([ map {
            $self->control_populator_for($state, $_);
          } $self->controls ])
        ->memoize
}

method control_populator_for ($state, $control) {
    my $class = $control->validation_state_in($state);
    return sub {
        $_->apply_if(defined($class), sub {
                $_->select('.control-set-item')
                  ->add_to_attribute(class => $class);
            })
          ->select('.control-widgets')
          ->replace_content(
                $self->compile_controls_widget($state, $control)
            )
          ->select('.control-label')
          ->collect({
                passthrough   => 1,
                filter        => sub {
                    $_->select('label')
                      ->replace_content($control->label);
                },
            })
          ->select('.control-errors')
          ->replace($self->compile_control_errors($state, $control))
          ->select('.control-comment')
          ->replace_content($state->render($control->comment));
    };
}

method compile_control_errors ($state, $control) {
    return []
        unless $state->isa('ReUI::State::Result')
           and $state->has_result;
    my @errors = $state->control_errors_for($control->name_in($state));
    return []
        unless @errors;
    return $state->markup_for($self, 'errors')
        ->select('.control-errors')
        ->repeat([ map {
            my $error = $_;
            sub {
                $_->select('.error')
                  ->replace_content($state->render($error));
            };
          } @errors ])
        ->memoize;
}


method _build_style { 'tabular' }

method event_propagation_targets { $self->controls }


# separate so all attributes are found (name)
with qw(
    ReUI::Role::ElementName
    ReUI::Role::ElementClasses
    ReUI::Widget::API
    ReUI::Widget::API::Styled
    ReUI::Role::EventHandling::Propagation
);

with qw(
    ReUI::Widget::API::Namespaced::EventPropagation
);

1;
