use strictures 1;

# ABSTRACT: For attributes containing related classes for object construction

package ReUI::Meta::Attribute::Trait::RelatedClass;
use Moose::Role;

use ReUI::Types qw( Maybe NonEmptySimpleStr HashRef StrMap );
use ReUI::Util  qw( load_class );

use syntax qw( function method );
use namespace::autoclean;

has constructor => (
    is          => 'ro',
    isa         => Maybe[ NonEmptySimpleStr ],
    required    => 1,
);

has argument_builder => (
    is          => 'ro',
    isa         => Maybe[ NonEmptySimpleStr ],
    required    => 1,
);

has build_via => (
    is          => 'ro',
    isa         => NonEmptySimpleStr,
    required    => 1,
);

has proxy => (
    is          => 'ro',
    isa         => StrMap,
    coerce      => 1,
);

before _process_options => method ($class: $name, $options) {
    ( my $type = $name ) =~ s/^(.+)_class$/$1/x;
    %$options = (
        is                  => 'ro',
        constructor         => "make_${type}",
        argument_builder    => "${type}_arguments",
        build_via           => 'new',
        proxy               => {},
        %$options,
    );
};

after install_accessors => method {
    my $name        = $self->name;
    my $arg_build   = $self->argument_builder;
    my $via         = $self->build_via;
    my $add_args    = "additional_${arg_build}";
    my $proxy       = $self->proxy;
    my $class       = $self->associated_class;
    $class->add_attribute(
        $add_args,
        traits      => [qw( Hash )],
        isa         => HashRef,
        init_arg    => $arg_build,
        handles     => {
            $add_args           => 'elements',
            "has_${add_args}"   => 'count',
        },
    );
    $class->add_method(
        $self->constructor, method (%args) {
            my $args_from = $self->can($arg_build);
            my $related   =
                defined($args{class})
                    ? $args{class}
                    : $self->meta
                        ->find_attribute_by_name($name)
                        ->get_value($self);
            return load_class($related)->$via(
                $args_from ? ($self->$args_from) : (),
                %args,
                (map {
                    my $pr_name = $_;
                    ( $self->can("_has_proxied_${pr_name}")->($self)
                        ? ( $pr_name,
                            $self->can("_proxied_${pr_name}")->($self),
                        ) : ()
                    );
                } keys %$proxy),
                $self->$add_args,
            );
        },
    ) if defined $self->constructor;
    for my $proxied_attr (keys %$proxy) {
        $class->add_attribute("_proxied_${proxied_attr}",
            is          => 'ro',
            init_arg    => $proxied_attr,
            predicate   => "_has_proxied_${proxied_attr}",
        );
    }
};

with qw(
    ReUI::Meta::Attribute::Trait::Lazy
);

1;
