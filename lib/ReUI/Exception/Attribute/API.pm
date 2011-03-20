use strictures 1;

package ReUI::Exception::Attribute::API;
use Moose::Role;

use ReUI::Types qw( NonEmptySimpleStr );

use aliased 'Role::HasPayload::Meta::Attribute::Payload';

use syntax qw( function method );
use namespace::autoclean;

has attribute_name => (
    traits      => [ Payload ],
    is          => 'ro',
    isa         => NonEmptySimpleStr,
    required    => 1,
    lazy        => 1,
    builder     => '_build_attribute_name',
    init_arg    => undef,
);

has class_name => (
    traits      => [ Payload ],
    is          => 'ro',
    isa         => NonEmptySimpleStr,
    required    => 1,
    lazy        => 1,
    builder     => '_build_class_name',
    init_arg    => undef,
);

has attribute => (
    is          => 'ro',
    isa         => 'Moose::Meta::Attribute',
    required    => 1,
    handles     => {
        _build_attribute_name   => 'name',
    },
);

has class => (
    is          => 'ro',
    isa         => 'Moose::Meta::Class',
    required    => 1,
    handles     => {
        _build_class_name   => 'name',
    },
);

with qw(
    ReUI::Exception::API
);

1;
