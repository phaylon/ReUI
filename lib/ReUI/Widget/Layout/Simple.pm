use strictures 1;

package ReUI::Widget::Layout::Simple;
use Moose;

use ReUI::Traits    qw( Lazy RelatedClass );
use ReUI::Types     qw( Container );

use syntax qw( function method );
use namespace::autoclean;


my @FixedSections = qw( header content footer );
my @LooseSections = qw( left right );
my @Sections      = (@FixedSections, @LooseSections);


for my $section (@Sections) {
    has "${section}_class" => (
        traits  => [ RelatedClass ],
    );
    has $section => (
        traits  => [ Lazy ],
        isa     => Container,
        coerce  => 1,
        handles => {
            "add_to_${section}"         => 'add',
            "${section}_widgets"        => 'widgets',
            "has_${section}_widgets"    => 'has_widgets',
            "${section}_widget"         => 'widget',
            "${section}_is_empty"       => 'is_empty',
            "compile_${section}"        => 'compile',
        },
    );
    __PACKAGE__->meta->add_method("_build_${section}", method {
        return $self->can("make_${section}")->($self);
    });
    __PACKAGE__->meta->add_method("_build_${section}_class", method {
        return 'ReUI::Widget::Container';
    });
}

method _compile_section ($state, $section) {
    return $self->can("compile_${section}")->($self, $state);
}

method _has_widgets ($section) {
    return $self->can("has_${section}_widgets")->($self);
}


method inner_content_populator ($state) {
    return fun ($zoom, $section) {
        return $zoom
            ->select(".layout-${section}-inner")
            ->replace_content($self->_compile_section($state, $section));
    };
}

method compile ($state) {
    my $replace_inner = $self->inner_content_populator($state);
    my $remove_or_insert = fun ($zoom, $section) {
        return $zoom->select(".layout-${section}")->replace([])
            unless $self->_has_widgets($section);
        return $zoom->$replace_inner($section);
    };
    return $state->markup_for($self)
        ->apply($self->identity_populator_for('.layout-simple'))
        ->apply(sub {
            my $zoom = $_;
            for my $section (@FixedSections) {
                $zoom = $zoom->$replace_inner($section)->memoize;
            }
            for my $section (@LooseSections) {
                $zoom = $zoom->$remove_or_insert($section)->memoize;
            }
            return $zoom;
        });
}


with qw(
    ReUI::Widget::API
    ReUI::Widget::API::Styled
    ReUI::Role::ElementClasses
);

__PACKAGE__->meta->make_immutable;

1;
