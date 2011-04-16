use strictures 1;

package ReUI::Widget::Page::Header;
use Moose;

use ReUI::Types     qw( Renderable Uri Maybe Does );
use ReUI::Traits    qw( Resolvable LazyRequire Lazy RelatedClass );
use ReUI::Constants qw( :skinfiles );

use syntax qw( function method );
use namespace::autoclean;


has content => (
    traits      => [ Resolvable, LazyRequire ],
    is          => 'rw',
    isa         => Renderable,
    required    => 1,
);

has logo_image_uri => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => Uri,
    coerce      => 1,
);

has logo_link_uri => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => Uri,
    coerce      => 1,
);


has logo_image_class => (
    traits      => [ RelatedClass ],
);

method _build_logo_image_class { 'ReUI::Widget::Page::Header::Logo::Image' }


has logo_link_class => (
    traits      => [ RelatedClass ],
);

method _build_logo_link_class { 'ReUI::Widget::Page::Header::Logo::Link' }


has logo => (
    traits      => [ Lazy ],
    is          => 'ro',
    isa         => Maybe[ Does['ReUI::Widget::API'] ],
    clearer     => 'reset_logo',
);

method _build_logo {
    my $image_uri = $self->logo_image_uri
        or return undef;
    my $image = $self->make_logo_image(
        alt     => '',
        src     => $image_uri,
    );
    my $link_uri = $self->logo_link_uri
        or return $image;
    return $self->make_logo_link(
        href    => $link_uri,
        widgets => [ $image ],
    );
}


method compile ($state) {
    return $state->markup_for($self)
        ->select('.page-header-content')
        ->replace($state->render($self->content))
        ->select('.page-header-logo')
        ->replace($self->logo || []);
}


with qw(
    ReUI::Widget::API
);

1;
