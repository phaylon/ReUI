use strictures 1;

package ReUI::Meta::Attribute::Trait::Prototyped;
use Moose::Role;

use MooseX::Types::Moose    qw( ArrayRef HashRef Str );
use Params::Classify        qw( is_ref );
use Carp                    qw( confess );

use syntax qw( function method );
use namespace::autoclean;

has make_via => (
    is          => 'ro',
    isa         => Str,
    required    => 1,
);

before _process_options => method ($class: $name, $options) {
    %$options = (
        init_arg => undef,
        %$options,
    );
};

after install_accessors => method {
    my $name    = $self->name;
    my $class   = $self->associated_class;
    my $clearer = "_clear_prototyped_${name}";
    my $proto   = "_prototyped_${name}";
    my $tc      = $self->type_constraint;
    my $inflate = "_inflate_${name}";
    my $maker   = $self->make_via;
    my $com_all = "compile_${name}";
    my $com_one = "${com_all}_widget";
    confess qq{Only ArrayRef types are supported in $self}
        unless $tc->is_a_type_of(ArrayRef);
    my $param   = $tc->type_parameter
        or confess qq{Unparameterized type on $name is not supported};
    $class->add_attribute("prototyped_$name",
        traits      => [qw( Array )],
        isa         => ArrayRef[ HashRef | $param ],
        init_arg    => $name,
        clearer     => $clearer,
        lazy        => 1,
        required    => 1,
        builder     => "_build_prototyped_$name",
        handles     => {
            $proto      => 'elements',
        },
    );
    $class->add_method("_build_prototyped_$name", method { [] });
    $class->add_method($inflate, method (@values) {
        return map {
            is_ref($_, 'HASH')
                ? $self->$maker(%$_)
                : $_
        } @values;
    });
    $class->add_method("_build_$name", method {
        my @objects = $self->$inflate($self->$proto);
        $self->$clearer;
        return \@objects;
    });
    $class->add_method($com_all, method ($state) {
        my $ls = $self->meta
            ->find_attribute_by_name($name)
            ->get_value($self);
        return HTML::Zoom->from_events([ map {
            (@{ $self->$com_one($state, $_)->to_events });
        } @$ls ]);
    });
    $class->add_method($com_one, method ($state, $widget) {
        return $state->render($widget);
    });
};

with qw(
    ReUI::Meta::Attribute::Trait::Lazy
);

1;
