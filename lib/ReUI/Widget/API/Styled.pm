use strictures 1;

package ReUI::Widget::API::Styled;
use Moose::Role;

use ReUI::Traits qw( Lazy );
use ReUI::Types  qw( NonEmptySimpleStr File );

use syntax qw( function method );
use namespace::autoclean;

has style => (
    traits      => [ Lazy ],
    is          => 'rw',
    isa         => NonEmptySimpleStr | File,
    required    => 1,
);

method _build_style { 'base' }

1;
