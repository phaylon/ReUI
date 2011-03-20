use strictures 1;

package ReUI::Test::Types;
use MooseX::Types -declare => [qw( MyInt )];
use MooseX::Types::Moose ':all';

subtype MyInt, as Int, message { 'Invalid integer' };
coerce MyInt, from Num, via { int $_ };

1;
