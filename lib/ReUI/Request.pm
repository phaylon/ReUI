use strictures 1;

# ABSTRACT: Request container

package ReUI::Request;
use Moose;

use ReUI::Traits    qw( Hash );
use ReUI::Types     qw( HashRef RequestMethod );

use syntax qw( function method );
use namespace::autoclean;

has parameters => (
    traits      => [ Hash ],
    isa         => HashRef,
    required    => 1,
    handles     => {
        parameter       => 'get',
        has_parameter   => 'defined',
        has_parameters  => 'count',
        parameters      => 'keys',
    }
);

has method => (
    is          => 'ro',
    isa         => RequestMethod,
    coerce      => 1,
    required    => 1,
);

with qw(
    ReUI::Request::API
);

__PACKAGE__->meta->make_immutable;

1;
