use strictures 1;

# ABSTRACT: Provide a global internal ID for an object instance

package ReUI::Role::Identification::Internal;
use Moose::Role;

use ReUI::Traits qw( Lazy );
use Data::UUID;

use syntax qw( function method );
use namespace::autoclean;

has internal_id => (
    traits      => [ Lazy ],
    is          => 'ro',
    init_arg    => undef,
);

my $UG = Data::UUID->new;

method _build_internal_id { $UG->create_str }

1;
