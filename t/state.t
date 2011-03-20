use strictures 1;
use Test::More;

use aliased 'ReUI::View';
use aliased 'ReUI::State';

my $view  = View->new;
my $state = $view->prepare(
    request => {
        parameters  => { foo => 23 },
        method      => 'get',
    },
);
is $state->method, 'GET', 'request method coerced';
is $state->parameter('foo'), 23, 'parameter access';

done_testing;
