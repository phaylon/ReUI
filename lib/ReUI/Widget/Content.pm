use strictures 1;

package ReUI::Widget::Content;
use Moose;

use ReUI::Types     qw( Str );
use ReUI::Traits    qw( LazyRequire Resolvable );
use HTML::Entities  qw( encode_entities );
use HTML::Zoom;

use syntax qw( function method );
use namespace::autoclean;

has content => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => Str,
    required    => 1,
);

method compile ($state) {
    my $raw = encode_entities $self->resolve_content($state);
    return $state->markup_for($self)
        ->apply($self->identity_populator_for('.content'))
        ->memoize
        ->select('.content')
        ->replace_content($raw);
}

with qw(
    ReUI::Widget::API
);

1;
