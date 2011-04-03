use strictures 1;

package ReUI::View::Skinner;
use Moose;

use ReUI::Traits qw( Lazy Hash Array );
use ReUI::Types  qw( SkinMap DirList );
use Carp         qw( confess );

use syntax qw( function method );
use namespace::autoclean;


has skins => (
    traits      => [ Lazy, Hash ],
    isa         => SkinMap,
    coerce      => 1,
    handles     => {
        skins       => 'values',
        skin_names  => 'keys',
        has_skins   => 'count',
        skin        => 'get',
    },
);

method _build_skins { {} }


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


method locate_skin_file ($skinname, $filename) {
    my $skin = $self->skin($skinname)
        or confess qq{Unknown skin '$skinname'};
    return file_by_object($skin, $filename, [$self->search_paths]);
}


with qw(
    ReUI::View::Skinner::API
);

1;
