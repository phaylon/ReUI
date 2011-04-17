use strictures 1;

package ReUI::Exception::Attribute::MissingValue;
use Moose;

use ReUI::Util  qw( lineup human_join_with );
use ReUI::Types qw( Str );

use aliased 'Role::HasPayload::Meta::Attribute::Payload';

use syntax qw( function method );
use namespace::clean;
use overload
    q{""}    => sub { (shift)->message },
    fallback => 1;

with qw( ReUI::Exception::Attribute::API );

has options => (
    traits      => [ Payload ],
    is          => 'ro',
    isa         => Str,
    required    => 1,
    lazy        => 1,
    init_arg    => undef,
    builder     => '_build_options',
);

method _build_options {
    my $options = human_join_with 'or',
        $self->attribute->builder
            ? sprintf(
                q{providing a '%s' method},
                $self->attribute->builder,
            ) : (),
        $self->attribute->init_arg
            ? sprintf(
                q{passing '%s' during construction},
                $self->attribute->init_arg,
            ) : ();
    return $options
        ? "This can be achieved by $options."
        : '';
}

with 'Role::HasMessage::Errf' => {
    lazy    => 1,
    default => lineup(q!
        You haven't yet supplied a value for the '%{attribute_name}s'
        attribute on this %{class_name}s instance. %{options}s
    !),
};

1;
