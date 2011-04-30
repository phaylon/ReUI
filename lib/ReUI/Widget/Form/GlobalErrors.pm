use strictures 1;

package ReUI::Widget::Form::GlobalErrors;
use Moose;

use ReUI::Util qw( empty_stream );

use syntax qw( function method );
use namespace::autoclean;


method compile ($state) {
    return empty_stream
        unless $state->isa('ReUI::State::Result') and $state->has_result;
    my @errors = $state->global_errors;
    return empty_stream
        unless @errors;
    return $state->markup_for($self)
        ->apply($self->identity_populator_for('.global-errors'))
        ->select('.global-errors')
        ->repeat([ map {
            my $error = $_;
            sub {
                $_  ->select('.error')
                    ->replace_content($state->render($error));
            };
        } @errors ]);
}


with qw(
    ReUI::Widget::API
    ReUI::Widget::API::Styled
    ReUI::Role::ElementClasses
);

1;
