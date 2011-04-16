use strictures 1;

package ReUI::Role::OnBuild::Inflate::Array;
use MooseX::Role::Parameterized;

use ReUI::Types         qw( NonEmptySimpleStr );
use ReUI::Util          qw( lineup );
use Carp                qw( confess );
use Params::Classify    qw( is_ref is_blessed );

use syntax qw( function );
use namespace::autoclean;

parameter param => (
    isa         => NonEmptySimpleStr,
    required    => 1,
);

parameter push_method => (
    isa         => NonEmptySimpleStr,
    required    => 1,
);

parameter class_attribute => (
    isa         => NonEmptySimpleStr,
    required    => 1,
);


my $AssertObject = fun ($object, $msg) {
    return $object if is_blessed $object;
    confess $msg;
};


my $GetAttr = fun ($object, $name) {
    my $attr = $object->meta->find_attribute_by_name($name)
        or confess qq{Unable to find attribute '$name' on $self};
    return $attr;
};


role {
    my $p           = shift;
    my $param       = $p->param;
    my $push_method = $p->push_method;
    my $class_attr  = $p->class_attribute;

    after BUILD => fun ($self, $attrs) {
        if (defined( my $value = $attrs->{ $param } )) {
            confess sprintf lineup(q{
                Contructor argument '%s' is expected to be an
                array reference, not '%s'
            }), $param, $value
                unless is_ref $value, 'ARRAY';
            my $constr_method;
            $self->$push_method(map {
                my $proto = $_;
                is_ref($proto, 'HASH')
                  ? $self->can( $constr_method
                        ||= $self->$GetAttr($class_attr)->constructor
                    )->($self, %$proto)
                  : $proto;
            } @$value);
        }
    };

    with qw(
        ReUI::Role::OnBuild
    );
};

1;
