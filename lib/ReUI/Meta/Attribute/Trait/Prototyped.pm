use strictures 1;

package ReUI::Meta::Attribute::Trait::Prototyped;
use Moose::Role;

use MooseX::Types::Moose    qw( ArrayRef HashRef Str Maybe Bool );
use Params::Classify        qw( is_ref );
use Carp                    qw( confess );
use HTML::Zoom;

use syntax qw( function method );
use namespace::autoclean;

has make_via        => (is => 'ro', isa => Str);
has proto_clearer   => (is => 'ro', isa => Str, required => 1);
has proto_getter    => (is => 'ro', isa => Str, required => 1);
has proto_inflate   => (is => 'ro', isa => Str, required => 1);
has compile_all     => (is => 'ro', isa => Maybe[ Str ], required => 1);
has compile_single  => (is => 'ro', isa => Maybe[ Str ], required => 1);
has compile         => (is => 'ro', isa => Bool);

before _process_options => method ($class: $name, $options) {
    %$options = (
        init_arg        => undef,
        proto_clearer   => "_clear_prototyped_${name}",
        proto_getter    => "_prototyped_${name}",
        proto_inflate   => "_inflate_${name}",
        compile         => 1,
        compile_all     => "compile_${name}",
        compile_single  => "compile_${name}_widget",
        %$options,
    );
};

method _install_prototype_attribute {
    my $name    = $self->name;
    my $class   = $self->associated_class;
    my $proto   = $self->proto_getter;
    my $clearer = $self->proto_clearer;
    my $param   = $self->type_constraint->type_parameter
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
}

method _install_inflate_method {
    my $name    = $self->name;
    my $class   = $self->associated_class;
    my $inflate = $self->proto_inflate;
    my $maker   = $self->make_via;
    $maker = fun (%args) {
        confess qq{Prototypes for '$name' require a 'class' argument}
            unless exists $args{class};
        return load_class($args{class})->new(%args);
    } unless defined $maker;
    $class->add_method($inflate, method (@values) {
        return map {
            is_ref($_, 'HASH')
                ? $self->$maker(%$_)
                : $_
        } @values;
    });
}

method _install_real_builder_method {
    my $name    = $self->name;
    my $class   = $self->associated_class;
    my $inflate = $self->proto_inflate;
    my $proto   = $self->proto_getter;
    my $clearer = $self->proto_clearer;
    $class->add_method("_build_$name", method {
        my @objects = $self->$inflate($self->$proto);
        $self->$clearer;
        return \@objects;
    });
}

method _install_compilation_methods {
    my $name    = $self->name;
    my $class   = $self->associated_class;
    my $com_one = $self->compile_single;
    my $com_all = $self->compile_all;
    return unless defined $com_one;
    $class->add_method($com_one, method ($state, $widget) {
        return $state->render($widget);
    });
    return unless defined $com_all;
    $class->add_method($com_all, method ($state) {
        my $ls = $self->meta
            ->find_attribute_by_name($name)
            ->get_value($self);
        return HTML::Zoom->from_events([ map {
            (@{ $self->$com_one($state, $_)->to_events });
        } @$ls ]);
    });
}

after install_accessors => method {
    my $name    = $self->name;
    my $tc      = $self->type_constraint;
    confess qq{Only ArrayRef types are supported in $self}
        unless $tc->is_a_type_of(ArrayRef);
    my $param   = $tc->type_parameter
        or confess qq{Unparameterized type on $name is not supported};
    $self->_install_prototype_attribute;
    $self->_install_inflate_method;
    $self->_install_real_builder_method;
    $self->_install_compilation_methods
        if $self->compile;
};

with qw(
    ReUI::Meta::Attribute::Trait::Lazy
);

1;
