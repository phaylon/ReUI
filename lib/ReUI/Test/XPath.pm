use strictures 1;

# ABSTRACT: Test::XPath extension

package ReUI::Test::XPath;
use parent 'Test::XPath';

use Test::More          ();
use ReUI::Test          qw( grouped );
use Lingua::EN::Numbers qw( num2en_ordinal );

use syntax qw( function method );
use namespace::clean;

method content_is ($value) {
    $self->is('.', $value, 'content');
}

method attr_is ($attr, $value) {
    $self->is(sprintf('./@%s', $attr), $value, "$attr attribute");
}

method attr_value ($attr) {
    return $self->xpc->findvalue(
        $self->{filter}->(sprintf('./@%s', $attr)),
        $self->node,
    );
}

method attr_doesnt_contain ($attr, @values) {
    my %value = map { ($_, 1) } split m{ }, $self->attr_value($attr);
    grouped("$attr attribute contents do not include", sub {
        Test::More::ok(not($value{ $_ }), "'$_'")
            for @values;
    });
}

method attr_contains ($attr, @values) {
    my %value = map { ($_, 1) } split m{ }, $self->attr_value($attr);
    grouped("$attr attribute contents include", sub {
        Test::More::ok($value{ $_ }, "'$_'")
            for @values;
    });
}

method contains_test_value ($id) {
    $self->ok(
        sprintf('//span[@id="test-value-%s"]', $id),
        "contains $id",
    );
}

method into ($path, @tests) {
    my $idx    = 1;
    my $single = (@tests == 1);
    $self->ok($path, method {
        if (@tests) {
            my $test = shift @tests;
            grouped(
                sprintf('%s %s',
                    $single ? 'single' : num2en_ordinal($idx++),
                    $path,
                ),
                sub { $self->$test },
            );
        }
        else {
            Test::More::fail("unexpected $path element");
        }
    }, "found $path");
    if (@tests) {
        Test::More::fail(
            sprintf 'missing %d %s elements', scalar(@tests), $path,
        );
    }
}

1;
