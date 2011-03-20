use strictures 1;

# ABSTRACT: UI core system object for ReUI

package ReUI::View;
use Moose;

use ReUI::Traits qw( RelatedClass Lazy Array );
use ReUI::Types  qw( DirList Language );
use ReUI::Util   qw( load_class );

use syntax qw( function method );
use namespace::autoclean;

has state_class => (
    traits      => [ RelatedClass ],
    constructor => 'prepare',
);

method _build_state_class { 'ReUI::State' }

method state_arguments {
    view => $self,
}

has provider_class => (
    traits      => [ RelatedClass ],
);

method _build_provider_class { 'ReUI::View::Provider::Auto' }

has provider => (
    traits      => [ Lazy ],
    does        => 'ReUI::View::Provider::API',
    handles     => 'ReUI::View::Provider::API',
);

method _build_provider {
    return $self->make_provider(
        search_paths => [ $self->search_paths ],
    );
}

has search_paths => (
    traits      => [ Lazy, Array ],
    isa         => DirList,
    required    => 1,
    coerce      => 1,
    handles     => {
        search_paths        => 'elements',
        has_search_paths    => 'count',
    },
);

method _build_search_paths { [] }

has i18n_class => (
    traits      => [ RelatedClass ],
    constructor => undef,
);

method _build_i18n_class { 'ReUI::I18N' }

method i18n_for (@possible_languages) {
    return load_class($self->i18n_class)->get_handle(@possible_languages);
}

with qw(
    ReUI::View::API
);

1;
