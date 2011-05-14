use strictures 1;

# ABSTRACT: Attribute is lazily resolvable via a state

package ReUI::Meta::Attribute::Trait::Resolvable;
use Moose::Role;

use ReUI::Types         qw(
    NonEmptySimpleStr
    Any
    CodeRef
    TypeConstraint
    Bool
);
use Carp                qw( confess );
use Params::Classify    qw( is_ref );

use syntax qw( function method );
use namespace::autoclean;

has resolver => (
    is          => 'ro',
    isa         => NonEmptySimpleStr,
    required    => 1,
);

has original_type_constraint => (
    is          => 'ro',
    isa         => TypeConstraint,
    required    => 1,
);

has as_list => (
    is          => 'ro',
    isa         => Bool,
);

method has_original_type_constraint {
    return defined $self->original_type_constraint;
}

before _process_options => method ($class: $name, $options) {
    my $type = $options->{isa} || Any;
    %$options = (
        resolver                    => "resolve_$name",
        %$options,
        isa                         => CodeRef | $type,
        original_type_constraint    => $type,
    );
};

after install_accessors => method {
    my $name = $self->name;
    $self->associated_class->add_method(
        $self->resolver,
        method ($state, @args) {
            my $attr  = $self->meta->find_attribute_by_name($name);
            my $value = $attr->get_value($self);
            $value = $state->resolve($value, @args);
            confess q{Cannot resolve value to code reference}
                if is_ref $value, 'CODE';
            if (my $tc = $attr->original_type_constraint) {
                if ($attr->should_coerce) {
                    $value = $tc->assert_coerce($value);
                }
                else {
                    $tc->assert_valid($value);
                }
            }
            return $attr->as_list
                ? @$value
                : $value;
        },
    );
};

1;
