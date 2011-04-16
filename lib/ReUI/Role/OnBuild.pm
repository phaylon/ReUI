use strictures 1;

package ReUI::Role::OnBuild;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

method BUILD { () }

1;
