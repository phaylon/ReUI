use strictures 1;

package ReUI::Exception::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

with qw(
    Throwable
    Role::HasPayload::Auto
    StackTrace::Auto
);

1;
