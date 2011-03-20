use strictures 1;

# ABSTRACT: Additional hints per object for the markup provider

package ReUI::Role::Hint::Provider;
use Moose::Role;

use File::ShareDir  qw( dist_dir );
use Path::Class     qw( dir );

use syntax qw( function method );
use namespace::autoclean;

method additional_search_path_dists { () }

method additional_search_paths {
    return map {
        dir(dist_dir($_), 'templates');
    } $self->additional_search_path_dists;
}

1;
