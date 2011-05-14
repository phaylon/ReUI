use strictures 1;

package ReUI::Model::Navigation::Trail;
use Moose;

use ReUI::Traits        qw( Array Lazy LazyRequire );
use ReUI::Types         qw( ArrayRef Does );
use Params::Classify    qw( is_ref is_blessed is_string );

use syntax qw( function method );
use namespace::autoclean;


has model => (
    traits      => [ LazyRequire ],
    is          => 'ro',
    isa         => 'ReUI::Model::Navigation',
);


has nodes => (
    traits      => [ Array, Lazy ],
    isa         => ArrayRef[ 'ReUI::Model::Navigation::Node' ],
    handles     => {
        nodes           => 'elements',
        add_node        => 'push',
        current_node    => [get => -1],
        has_nodes       => 'count',
        node            => 'get',
    },
);

method _build_nodes { [] }


method make_node (%args) {
    return( ($self->current_node || $self->model)->make_child(%args) );
}

method into ($target, @rest) {
    if (is_blessed $target) {
        $self->add_node($target);
    }
    elsif (is_ref $target, 'HASH') {
        $self->add_node($self->make_node(%$target));
    }
    elsif (is_string $target) {
        my $node = ($self->current_node || $self->model)->get($target)
            or confess qq{Unknown navigation node '$target'};
        $self->add_node($node);
    }
    else {
        confess q{Navigation descension target must be an object, }
              . q{a hash reference, or a string};
    }
    return $self->into(@rest)
        if @rest;
    return $self;
}

method id_map {
    return +{}
        unless $self->has_nodes;
    return +{
        last => $self->current_node->internal_id,
        map { ($_->internal_id, 1) } $self->nodes,
    };
}


__PACKAGE__->meta->make_immutable;

1;
