use strictures 1;

# ABSTRACT: Common traits

package ReUI::Traits;

use syntax qw( function );
use namespace::clean;

my (@BuiltinTraits, @ReTraits, $ReBase, @AllTraits);

BEGIN {
    $ReBase        = 'ReUI::Meta::Attribute::Trait';
    @BuiltinTraits = qw( Array Code Hash );
    @ReTraits      = qw(
        RelatedClass
        Resolvable
        Lazy
        LazyRequire
        Prototyped
    );
    @AllTraits     = (@BuiltinTraits, @ReTraits);
};

use constant +{
    ( map { ($_, $_) } @BuiltinTraits ),
    ( map { ($_, join '::', $ReBase, $_) } @ReTraits ),
};

use Sub::Exporter -setup => {
    exports => [@AllTraits],
    groups  => {
        core    => [@BuiltinTraits],
        re      => [@ReTraits],
    },
};

1;

__END__

=head1 DESCRIPTION

This module exports constants for attribute traits that are commonly used
across L<ReUI>.

=head1 TRAITS

=over

=item * L<RelatedClass|ReUI::Meta::Attribute::Trait::RelatedClass>

=item * L<Resolvable|ReUI::Meta::Attribute::Trait::Resolvable>

=item * L<Lazy|ReUI::Meta::Attribute::Trait::Lazy>

=item * L<LazyRequire|ReUI::Meta::Attribute::Trait::LazyRequire>

=item * L<Array|Moose::Meta::Attribute::Native::Trait::Array>

=item * L<Hash|Moose::Meta::Attribute::Native::Trait::Hash>

=item * L<Code|Moose::Meta::Attribute::Native::Trait::Code>

=back

=cut
