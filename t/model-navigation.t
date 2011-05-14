use strictures 1;
use Test::More;
use Test::Fatal;
use ReUI::Test;

use aliased 'ReUI::Model::Navigation';

my $model = Navigation->new(
    children => [
        { id => 'home', title => 'Home', uri => 'http://example.com/' },
        { id => 'news', title => 'News', uri => 'http://example.com/news' },
        { id => 'help', title => 'Help', uri => 'http://example.com/help' },
    ],
);

$model->get('news')->add(
    id      => 'archive',
    title   => 'Archive',
    uri     => 'http://example.com/archive',
);
$model->get('news')->add(
    id      => 'feeds',
    title   => 'Feeds',
    uri     => 'http://example.com/feeds',
);

is $model->has_children, 3, 'correct number of children';
is $model->get('news')->has_children, 2, 'correct number of child children';

grouped('trail', sub {
    my $trail = $model->trail;
    $trail->into('news');
    $trail->into('feeds');
    is $trail->has_nodes, 2, 'correct number of nodes';

    $trail->into({
        id      => 'dynamic',
        title   => 'Dynamic',
        uri     => 'http://example.com/dynamic',
    });
    is $trail->has_nodes, 3, 'correct number of nodes with dynamic';

    my $submodel = Navigation->new(
        children => [
            {   id          => 'edge parent',
                title       => 'Edge Parent',
                uri         => 'http://example.com/edge',
                children    => [
                    {   id      => 'edge child',
                        title   => 'Edge Child',
                        uri     => 'http://example.com/edge/child',
                    },
                ],
            },
        ],
    );
    $trail->into($submodel->get('edge parent'));
    $trail->into('edge child');
    is $trail->has_nodes, 5, 'correct number of nodes with subtree';

    grouped('collected', sub {
        my @expected = (
            { id => 'news',         uri => 'http://example.com/news' },
            { id => 'feeds',        uri => 'http://example.com/feeds' },
            { id => 'dynamic',      uri => 'http://example.com/dynamic' },
            { id => 'edge parent',  uri => 'http://example.com/edge' },
            { id => 'edge child',   uri => 'http://example.com/edge/child' },
        );
        for my $idx (0 .. $#expected) {
            grouped("node $idx", sub {
                is $trail->node($idx)->id,  $expected[$idx]{id},  "id";
                is $trail->node($idx)->uri, $expected[$idx]{uri}, "uri";
            });
        }
    });
});

done_testing;
