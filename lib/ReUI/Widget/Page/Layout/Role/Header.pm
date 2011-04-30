use strictures 1;

package ReUI::Widget::Page::Layout::Role::Header;
use Moose::Role;

use ReUI::Traits qw( Lazy RelatedClass );

use aliased 'ReUI::Widget::Page::Header';

use syntax qw( function method );
use namespace::autoclean;


has header_class => (
    traits      => [ RelatedClass ],
);

method _build_header_class { Header }


has header => (
    traits      => [ Lazy ],
    is          => 'ro',
    isa         => Header,
);

method _build_header {
    return $self->make_header(
        content => $self->title,
    );
}


1;
