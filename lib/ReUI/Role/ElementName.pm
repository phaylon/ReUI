use strictures 1;

# ABSTRACT: Provide a name property

package ReUI::Role::ElementName;
use Moose::Role;

use ReUI::Traits        qw( LazyRequire );
use ReUI::Types         qw( Identifier );
use Try::Tiny;
use Params::Classify    qw( is_blessed );

use syntax qw( function method );
use namespace::autoclean;

has name => (
    traits      => [ LazyRequire ],
    is          => 'ro',
    isa         => Identifier,
);

method has_name {
    my $name;
    try {
        $name = $self->name;
    }
    catch {
        unless (is_blessed($_, 'ReUI::Exception::Attribute::MissingValue')) {
            die $_;
        }
    };
    return defined $name;
}

around _build_name => fun ($orig, $self) {
    return $self->id || $self->$orig;
};

method name_in ($state) {
    my $namespace = $state->namespace;
    return join '.',
        ( defined($namespace) and length($namespace) )
            ? $namespace
            : (),
        $self->name;
}

with qw(
    ReUI::Role::Identification
);

1;
