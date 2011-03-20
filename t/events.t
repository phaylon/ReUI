use strictures 1;
use Test::More;
use ReUI::Test qw( VIEW );

use aliased 'ReUI::View';
use aliased 'ReUI::Widget::Page';
use aliased 'ReUI::Widget::Container';
use aliased 'ReUI::Widget::Raw';

my $state = VIEW->prepare(request => {
    method      => 'GET',
    parameters  => {},
});

my $page = Page->new(
    title   => 'Test Title',
    id      => 'page',
    widgets => [
        Container->new(
            id      => 'first',
            widgets => [
                Raw->new(
                    id      => 'first_content',
                    content => 'first',
                ),
            ],
        ),
        Container->new(
            id      => 'second',
            widgets => [
                Raw->new(
                    id      => 'second_content',
                    content => 'second',
                ),
            ],
        ),
    ],
);

$state->add($page);

do {
    package My::TestEvent;
    use Moose;
    use syntax qw( method );
    has found => (is => 'rw', default => sub { {} });
    method apply_to ($object) {
        $self->found->{ $object->id } = $object
            if $object->can('id') and $object->id;
    }
    with qw( ReUI::Event::API );
};

my $event = $state->fire(My::TestEvent->new(state => $state));

isa_ok $event->found->{page},           Page;
isa_ok $event->found->{first},          Container;
isa_ok $event->found->{second},         Container;
isa_ok $event->found->{first_content},  Raw;
isa_ok $event->found->{second_content}, Raw;

done_testing;
