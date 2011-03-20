use strictures 1;

# ABSTRACT: For attributes containing related classes for object construction

package ReUI::Meta::Attribute::Trait::RelatedClass;
use Moose::Role;

use ReUI::Types qw( Maybe NonEmptySimpleStr );
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

before _process_options => method ($class: $name, $options) {
    ( my $type = $name ) =~ s/^(.+)_class$/$1/x;
    %$options = (
        is                  => 'ro',
        constructor         => "make_${type}",
        argument_builder    => "${type}_arguments",
        build_via           => 'new',
        %$options,
    );
};

after install_accessors => method {
    my $name        = $self->name;
    my $arg_build   = $self->argument_builder;
    my $via         = $self->build_via;
    $self->associated_class->add_method(
        $self->constructor, method (%args) {
            my $args_from = $self->can($arg_build);
            my $related   = $self->meta
                ->find_attribute_by_name($name)
                ->get_value($self);
            return load_class($related)->$via(
                $args_from ? ($self->$args_from) : (),
                %args,
            );
        },
    ) if defined $self->constructor;
};

with qw(
    ReUI::Meta::Attribute::Trait::Lazy
);

1;
