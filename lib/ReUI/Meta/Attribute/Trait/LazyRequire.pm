use strictures 1;

# ABSTRACT: Fail for missing values as late as possible

package ReUI::Meta::Attribute::Trait::LazyRequire;
use Moose::Role;

use Carp qw( confess );

use aliased 'ReUI::Exception::Attribute::MissingValue';

use syntax qw( function method );
use namespace::autoclean;

after install_accessors => method {
    my $name = $self->name;
    $self->associated_class->add_method($self->builder, method {
        MissingValue->throw(
            attribute   => $self->meta->find_attribute_by_name($name),
            class       => $self->meta,
        );
    }) unless $self->associated_class->name->can($self->builder);
};

with qw(
    ReUI::Meta::Attribute::Trait::Lazy
);

1;
