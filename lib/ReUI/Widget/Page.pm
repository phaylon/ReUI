use strictures 1;

# ABSTRACT: Simple generic page widget

package ReUI::Widget::Page;
use Moose;

use ReUI::Types     qw( NonEmptySimpleStr CodeRef Uri ArrayRef I18N );
use ReUI::Traits    qw( LazyRequire Lazy Resolvable );

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Container';

has title => (
    traits      => [ LazyRequire, Resolvable ],
    is          => 'rw',
    isa         => I18N,
);

has javascript_uris => (
    traits      => [ Lazy, Resolvable ],
    is          => 'ro',
    isa         => ArrayRef[ Uri ],
    as_list     => 1,
);

method _build_javascript_uris { [] }

has stylesheet_uris => (
    traits      => [ Lazy, Resolvable ],
    is          => 'ro',
    isa         => ArrayRef[ Uri ],
    as_list     => 1,
);

method _build_stylesheet_uris { [] }

around compile => fun ($orig, $self, $state) {
    my $title = $self->resolve_title($state);
    return $state->markup_for($self)
        ->apply_if(defined($title), sub {
            $_  ->select('title')
                ->replace_content($state->render($title));
        })
        ->select('link')
        ->repeat([ $self->link_populators($state) ])
        ->select('script')
        ->repeat([ $self->script_populators($state) ])
        ->apply($self->identity_populator_for('body'))
        ->memoize
        ->select('body')
        ->replace_content($self->$orig($state));
};

method script_populators ($state) {
    return $self->external_script_populators($state);
}

method external_script_populators ($state) {
    return map {
        $self->external_script_populator($_, $state);
    } $self->resolve_javascript_uris($state);
}

method external_script_populator ($uri, $state) {
    return sub {
        $_  ->select('script')
            ->set_attribute(type => 'text/javascript')
            ->then
            ->set_attribute(src => $uri);
    };
}

method link_populators ($state) {
    return $self->stylesheet_link_populators($state);
}

method stylesheet_link_populators ($state) {
    return map {
        $self->stylesheet_link_populator($_, $state);
    } $self->resolve_stylesheet_uris($state);
}

method stylesheet_link_populator ($uri, $state) {
    return sub {
        $_  ->select('link')
            ->set_attribute(rel => 'stylesheet')
            ->then
            ->set_attribute(href => $uri);
    };
}

with qw(
    ReUI::Role::Hint::Provider::Core
    ReUI::Role::ElementClasses
);

1;
