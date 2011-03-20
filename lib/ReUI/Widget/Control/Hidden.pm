use strictures 1;

# ABSTRACT: Hidden value

package ReUI::Widget::Control::Hidden;
use Moose;

use ReUI::Traits    qw( LazyRequire Resolvable );
use ReUI::Constants qw( :i18n );
use JSON::XS;

use syntax qw( function method );
use namespace::autoclean;

extends 'ReUI::Widget::Control::Value';

my $JSON = JSON::XS->new->utf8->allow_nonref;

around find_value => fun ($orig, $self, $state) {
    my $value = $self->$orig($state);
    return undef
        unless defined($value) and length($value);
    return $JSON->decode($value);
};

around register_validation_error => fun ($orig, $self, $ev, $name, @err) {
    my $error = [I18N_VALUE_INVALID, $self->label];
    $ev->add_global_errors($error);
    return $self->$orig($ev, $name, $error);
};

around render_value => fun ($orig, $self, $state, $value) {
    return $JSON->encode($self->$orig($state, $value));
};

1;
