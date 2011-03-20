use strictures 1;
use Test::More;

use aliased 'ReUI::View';
use aliased 'ReUI::State';

my $view  = View->new;
my $state = $view->prepare(request => {
    parameters  => {},
    method      => 'get',
});
isa_ok $state,          State,  'state object';
isa_ok $state->view,    View,   'state contained view';

done_testing;
