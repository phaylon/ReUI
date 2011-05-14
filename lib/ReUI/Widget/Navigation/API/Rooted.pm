use strictures 1;

package ReUI::Widget::Navigation::API::Rooted;
use Moose::Role;

use ReUI::Traits    qw( Resolvable );
use ReUI::Types     qw( Does InstanceOf );

use syntax qw( function method );
use namespace::autoclean;


has model => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => Does['ReUI::Model::Navigation::Node::API'],
    required    => 1,
);


1;
