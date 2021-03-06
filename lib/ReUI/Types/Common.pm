use strictures 1;

# ABSTRACT: Common type constraints

package ReUI::Types::Common;

use ReUI::Util                      qw( human_join_with load_class );
use Moose::Util                     qw( does_role );
use Moose::Util::TypeConstraints    qw( register_type_constraint );
use MooseX::Types::Path::Class      qw( :all );
use MooseX::Types::Moose            qw( :all );
use MooseX::Types::Parameterizable  qw( :all );
use MooseX::Types::Common::String   qw( :all );
use MooseX::Types::Meta             qw( :all );
use MooseX::Types::Structured       qw( :all );
use Params::Classify                qw( is_blessed );

use syntax qw( function );
use namespace::clean;

use MooseX::Types -declare => [qw(
    RequestMethod
    _LooseRequestMethod
    DirList
    Does
    InstanceOf
    Identifier
    Namespace
    _NamespaceStr
    IdentifierList
    I18N
    Language
    Skin
    SkinMap
    _SkinProto
    Renderable
    StrMap
    StrList
    MessageType
    CodeRefList
    Container
    Proto
)];

my $rxNamespaceStr = qr{
    \A
    (?:
        [^.]+
        (?:
            \.
            [^.]+
        )*
    )?
    \Z
}x;

fun load_proto ($proto) {
    return $proto
        if is_blessed $proto;
    my %args  = %$proto;
    my $class = delete $args{class};
    return load_class($class)->new(%args);
}

subtype CodeRefList, as ArrayRef[ CodeRef ];

coerce CodeRefList, from CodeRef, via { [$_] };

enum MessageType, [qw(
    notice
    success
    warning
    error
)];

subtype StrList, as ArrayRef[ Str ];

subtype StrMap, as HashRef[ Str ];

coerce StrMap, from StrList, via { +{ map { (($_) x 2) } @$_ } };

subtype _SkinProto,
    as HashRef,
    where { defined $_->{class} };

subtype Skin, as role_type('ReUI::Skin::API');

coerce Skin,
    from _SkinProto, via {
        my %args  = %$_;
        my $class = delete $args{class};
        Class::MOP::load_class($class);
        return $class->new(%args);
    };

subtype SkinMap,
    as HashRef[ Skin ];

coerce SkinMap,
    from HashRef[ _SkinProto | Skin ], via {
        my $map = $_;
        +{ map {
            ($_, Skin->coerce($map->{ $_ }));
        } keys %$map };
    };

subtype Language, as Str, where { m/^ [a-z]{2} (?: _ [a-z]{2} )? $/ix };

subtype I18N, as Str | Tuple[ NonEmptySimpleStr, slurpy Any ];

subtype Identifier, as NonEmptySimpleStr, where { not m/\./ and not m/\s/ };
subtype Namespace, as ArrayRef[ Identifier ];
subtype _NamespaceStr, as Str, where { $_ =~ $rxNamespaceStr };
coerce Namespace,
    from _NamespaceStr, via {
        length($_) ? [split m/\./, $_] : [];
    },
    from ArrayRef[ _NamespaceStr ], via {
        [map {
            (   length($_)
                ? (split m/\./, $_)
                : (),
            );
        } @$_];
    };

subtype IdentifierList, as ArrayRef[ Identifier ];
coerce IdentifierList, from Identifier, via { [$_] };

my @RequestMethods = qw( GET POST HEAD DELETE PUT );
enum RequestMethod, @RequestMethods;
subtype _LooseRequestMethod, as Str, where { RequestMethod->check(uc) };
coerce RequestMethod, from _LooseRequestMethod, via { uc };

subtype Does, as Parameterizable[ Object, NonEmptySimpleStr ],
    where {
        my ($object, $role) = @_;
#        warn "CHECK '$object' FOR '$role'";
        return undef
            unless is_blessed($object);
#        warn "IS BLESSED";
        return undef
            unless does_role($object, $role);
#        warn "DOES ROLE";
        return 1;
    };

subtype InstanceOf, as Parameterizable[ Object, NonEmptySimpleStr ],
    where {
        my ($object, $class) = @_;
        $object->isa($class);
    };

subtype DirList, as ArrayRef[ Dir ];
coerce DirList,
    from ArrayRef[ Dir | Str ], via {
        [ map { Dir->coerce($_) } @$_ ];
    },
    from Str, via {
        [ Dir->coerce($_) ];
    },
    from Dir, via {
        [ $_ ];
    };

subtype Renderable,
    as Str | I18N | Does['ReUI::Widget::API'];

subtype Proto, as Dict[ class => NonEmptySimpleStr, slurpy Any ];

subtype Container, as class_type('ReUI::Widget::Container');

coerce Container,
    from ArrayRef[ Proto | Does['ReUI::Widget::API'] ], via {
        return load_class('ReUI::Widget::Container')->new(
            widgets => [ map { load_proto($_) } @$_ ],
        );
    },
    from Proto, via {
        return load_class('ReUI::Widget::Container')->new(
            widgets => [ load_proto($_) ],
        );
    },
    from Does['ReUI::Widget::API'], via {
        return load_class('ReUI::Widget::Container')->new(
            widgets => [ $_ ],
        );
    };

1;

__END__

=head1 SYNOPSIS

    use ReUI::Types::Common qw(
        RequestMethod
        DirList
        Does
        InstanceOf
        Identifier
        Namespace
        IdentifierList
        I18N
        Language
    );

=head1 DESCRIPTION

This module provides common type constraints for the L<ReUI> project.

The types in this library are also part of the L<ReUI::Types> combination.

=head1 TYPES

=head2 RequestMethod

A string that can currently be either C<GET>, C<POST>, C<HEAD>, C<DELETE>
or C<PUT>. Optionally coerces from non-uppercase variants.

=head2 DirList

An array reference of L<Path::Class::Dir> objects. Can coerce from a single
directory object, from a single string, or from an array reference containing
directory objects or strings.

=head2 Does[$role]

An object implementing C<$role>.

=head2 InstanceOf[$class]

An object being an instance of C<$class> or a subclass thereof.

=head2 Identifier

Any non-empty string that doesn't contain dots or any whitespace.

=head2 Namespace

An array reference containing identifiers. Optionally coerces from a string
containing identifiers separated by dots, or from an array reference
containing such strings.

=head2 IdentifierList

An array reference containing identifiers. Optionally coerces from a single
identifier.

=head2 I18N

A string or an array reference beginning with an I18N key string, followed
by its arguments.

=head2 Language

A string of two characters (C<de>) optionally followed by an underscore and
another two characters (C<de_at>).

=head1 SEE ALSO

=over

=item * L<ReUI::Types>

=item * L<MooseX::Types>

=item * L<Moose::Manual::Types>

=back

=cut
