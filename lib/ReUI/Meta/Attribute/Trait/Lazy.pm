use strictures 1;

# ABSTRACT: For lazily built attributes

package ReUI::Meta::Attribute::Trait::Lazy;
use Moose::Role;

use ReUI::Types qw( NonEmptySimpleStr );

use syntax qw( function method );
use namespace::autoclean;

before _process_options => method ($class: $name, $options) {
    %$options = (
        required    => 1,
        lazy        => 1,
        builder     => "_build_$name",
        %$options,
    );
};

1;
