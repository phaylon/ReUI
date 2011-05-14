use strictures 1;

# ABSTRACT: Raw markup

package ReUI::Widget::Raw;
use Moose;

use ReUI::Traits qw( LazyRequire Resolvable );
use ReUI::Types  qw( Str );
use HTML::Zoom;

use syntax qw( function method );
use namespace::autoclean;

has content => (
    traits      => [ LazyRequire, Resolvable ],
    is          => 'ro',
    isa         => Str,
);

method compile ($state) {
    return HTML::Zoom->from_html($self->resolve_content($state));
}

with qw(
    ReUI::Widget::API
);

__PACKAGE__->meta->make_immutable;

1;
