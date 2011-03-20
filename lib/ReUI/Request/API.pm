use strictures 1;

# ABSTRACT: Request interface

package ReUI::Request::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw(
    method
    parameter
    has_parameters
    has_parameter
    parameters
);

1;

=head1 DESCRIPTION

This is the interface that must be implemented by all classes that wish to
provide request information in a compatible manner.

=head1 REQUIRED

=head2 method

    RequestMethod = $object->method;

Returns the L<RequestMethod|ReUI::Types::Common/RequestMethod>.

=head2 parameter

    Any = $object->parameter( $name );

Returns the parameter specified with C<$name>. This method is not context
sensitive and must always return a scalar value. If multiple values are
provided for a parameter, an array reference must be returned. In the case
that the parameter doesn't exist, and undefined value must be returned.

=head2 has_parameters

    Bool = $object->has_parameters;

Returns true if any parameters are available in the request, otherwise false.

=head2 has_parameter

    Bool = $object->has_parameter( $name );

Returns true if a parameter with the name C<$name> was provided, otherwise
false.

=head2 parameters

    ( Str, ... ) = $object->parameters;

Returns the names of all provided parameters as a list of strings.

=head1 SEE ALSO

=over

=item * L<ReUI::Request>

=back

=cut
