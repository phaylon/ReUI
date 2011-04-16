use strictures 1;

# ABSTRACT: The processing state of a single request

package ReUI::State;
use Moose;

use ReUI::Traits        qw( Lazy LazyRequire RelatedClass Array Hash Code );
use ReUI::Types         qw(
    Request ArrayRef HashRef Namespace Language Str CodeRef
);
use Carp                qw( confess );
use Params::Classify    qw( is_blessed is_ref is_string );
use Moose::Util         qw( does_role );

use aliased 'ReUI::Reactor';
use aliased 'ReUI::Response::Markup';
use aliased 'ReUI::Event::Validate';

use syntax qw( function method );
use namespace::autoclean;


=attr root_class

The class used to build the root container widget.

=method make_root

    Object = $object->make_root( %arguments );

Returns a new root container object. You shouldn't need to ever call this
yourself.

=method root_class

    Str = $object->root_class;

Returns the root class.

=method _build_root_class

    Str = $object->_build_root_class;

Defaults to L<ReUI::Widget::Container>.

=method root_arguments

    ( Str => Any, ... ) = $object->root_arguments;

Can be optionally provided for default root constructor arguments.

=cut

has root_class => (
    traits      => [ RelatedClass ],
);

method _build_root_class { 'ReUI::Widget::Container' }


=attr root

Holds the root container widget. Must be an object implementing
L<ReUI::Widget::Container::API>, which will also be fully delegated to this
attribute. This cannot be passed in as constructor argument.

=method root

    Object = $object->root;

Returns the root container widget.

=method _build_root

    Object = $self->_build_root;

Defaults to calling L</make_root>.

=cut

has root => (
    traits      => [ Lazy ],
    is          => 'ro',
    does        => 'ReUI::Widget::Container::API',
    handles     => 'ReUI::Widget::Container::API',
    init_arg    => undef,
);

method _build_root { $self->make_root }


=attr view

Holds the view that this state originated from. Must be an object that
implements L<ReUI::View::API>, which is also fully delegated to this
attribute. The value is required at construction time.

=method view

    Object = $object->view;

Returns the view object.

=cut

has view => (
    is          => 'ro',
    does        => 'ReUI::View::API',
    handles     => 'ReUI::View::API',
    required    => 1,
);


=attr request

Holds the request object this state corresponds to. Must be an object
implementing L<ReUI::Request::API>, which is also fully delegated to this
attribute. This value is required at construction time, but can be coerced
from a hash reference continaing request construction arguments instead.

=cut

has request => (
    isa         => Request,
    handles     => Request,
    required    => 1,
    coerce      => 1,
);


=attr namespace

Contains the namespace this state currently operates in. A lower state can
be achieved via L</descend>. It must be a valid
L<Namespace|ReUI::Types::Common/Namespace> but is coercable.

=method namespace

Returns the current namespace in form of a string.

=method _build_namespace

Defaults to an empty namespace.

=cut

has namespace => (
    traits      => [ Array, Lazy ],
    isa         => Namespace,
    coerce      => 1,
    handles     => {
        namespace   => [join => '.'],
    },
);

method _build_namespace { [] }


=attr variables

Holds the user supplied variables that can be used by the widgets during
rendering and other processes. Must be a hash reference.

=method variables

    HashRef = $object->variables;
    $object->variables({ ... });

Getter/setter for the user-supplied variables.

=method add_variables

    $object->add_variables( $key, $value, ... );

Adds key/value pairs to the L</variables>.

=method _build_variables

    HashRef = $object->_build_variables;

Defaults to an empty hash reference.

=cut

has variables => (
    traits      => [ Hash, Lazy ],
    is          => 'rw',
    isa         => HashRef,
    handles     => {
        add_variables   => 'set',
    },
);

method _build_variables { {} }


=attr validation

Holds the validation event that is used to validate all forms and controls
in the widget tree. Needs to be a L<ReUI::Event::Validate>.

=method validation

Returns the validation event.

=method _build_validation

Defaults to a new instance of L<ReUI::Event::Validate>.

=cut

has validation => (
    traits      => [ Lazy ],
    is          => 'ro',
    isa         => Validate,
    init_arg    => undef,
);

method _build_validation {
    return Validate->new(state => $self->variant(
        variables   => $self->variables,
    ));
}


=attr reactor

Contains the reactor managing user-supplied reactions in case an action is
to be performed in a form. Must be an object implementing
L<ReUI::Reactor::API>, which will also be fully delegated to this attribute.

=method _build_reactor

    Object = $object->_build_reactor;

Returns a bare L<ReUI::Reactor>.

=cut

has reactor => (
    traits      => [ Lazy ],
    does        => 'ReUI::Reactor::API',
    handles     => 'ReUI::Reactor::API',
    init_arg    => undef,
);

method _build_reactor {
    return Reactor->new;
}


=attr language

The language used to render internationalised content. Must be a
L<Language|ReUI::Types::Common/Language>.

=method language

    Language = $object->language;
    $object->language( $language );

Getter/setter for the current language.

=method _build_language

    Language = $object->_build_language;

Defaults to C<en>.

=cut

has language => (
    traits      => [ Lazy ],
    is          => 'rw',
    isa         => Language,
);

method _build_language { 'en' }


=attr i18n

Holds the I18N handle used to resolve internationalized messages. Needs to be
a L<Locale::Maketext> subclass.

=method resolve_i18n

    Str = $object->resolve_i18n( $string, @arguments );

Internationalizes the C<$string> with the passed in C<@arguments>.

=method _build_i18n

    Object = $object->_build_i18n;

Defaults to asking L<ReUI::View/i18n_for> for a language handle for the value
in L</language>.

=cut

has i18n => (
    traits      => [ Lazy ],
    isa         => 'Locale::Maketext',
    handles     => {
        resolve_i18n => 'maketext',
    },
);

method _build_i18n {
    return $self->view->i18n_for($self->language);
}


has skin_uri_callback => (
    traits      => [ LazyRequire ],
    is          => 'ro',
    isa         => CodeRef,
);

method has_skin_uri_callback { defined $self->skin_uri_callback }

method uri_for_skin (@args) {
    return $self->resolve($self->skin_uri_callback, @args);
}


has current_skin => (
    is          => 'rw',
    isa         => Str,
);


=method with_language

    Object = $object->with_language( $language );

Returns a variant of the object with the language set to C<$language>.

=cut

method with_language ($language) {
    return $self->variant(
        language    => $language,
        i18n        => $self->view->i18n_for($language),
    );
}


=method descend

    Object = $object->descend( $name );

Returns a variant of the object with a L</namespace> descended by C<$name>.

=cut

method descend ($namespace) {
    return $self->variant(namespace => [$self->namespace, $namespace]);
}


=method resolve

    Any = $object->resolve( $value );

Will evaluate the C<$value> if it is a code reference, otherwise it will
return it untouched. The global hash C<%_> will be aliased to the
L</variables>.

=cut

method resolve ($value, @args) {
    return $value
        unless is_ref $value, 'CODE';
    local *_ = $self->variables;
    return scalar $value->(@args);
}


=method render_root

    HTML::Zoom = $object->render_root;

Renders the root container object.

=cut

method render_root { $self->render_widget($self->root) }


=method render

    Str | HTML::Zoom = $object->render( $value );

Renders strings, L<I18N|ReUI::Types::Common/I18N> messages or widgets into
their respective outputs.

=cut

method render ($value) {
    $value = $self->resolve($value);
    return $self->resolve_i18n($value)
        if is_string $value;
    return $self->resolve_i18n(@$value)
        if is_ref $value, 'ARRAY';
    return $self->render_widget($value)
        if is_blessed($value) and (
               does_role($value, 'ReUI::Widget::API')
            or $value->isa('ReUI::State')
        );
    confess q{Unable to render %s},
        defined($value)
            ? sprintf(q{value '%s'}, $value)
            : 'undefined value';
}


=method render_widget

    HTML::Zoom = $object->render_widget( $widget );

Renders the passed C<$widget>.

=cut

method render_widget ($widget) {
    my $markup = $widget->compile($self);
    confess sprintf q{The widget %s did not return a valid HTML::Zoom object},
            $widget,
        unless is_blessed $markup, 'HTML::Zoom';
    return $markup->memoize;
}


=method process

    Object = $object->process;

Calculates a response object for this state.

=cut

# FIXME: shouldn't be able to call this twice.
method process {
    $self->fire($self->validation);
    return Markup->new(state => $self);
}


with qw(
    ReUI::State::API
    ReUI::Role::Variations
    ReUI::Role::EventHandling
);


=method fire

Extends L<ReUI::Role::EventHandling/fire> to dispatch it to the root
container afterwards.

=cut

after fire => method ($event) { $self->root->fire($event) };

1;

__END__

=head1 SYNOPSIS

    my $view = ReUI::View->new( ... );

    my $state = $view->prepare(
        request => {
            method      => 'GET',
            parameters  => {},
        },
    );

    $state->add( $widget );
    $state->add_variables(foo => 23);
    $state->variables->{bar}{baz} = 42;

    my $response = $state->process;

=head1 DESCRIPTION

An instance of this class represents a request that is to be handled.

It is used as the root for the widget tree that is to be rendered or parsed,
it handles the variables used during those processes, and it collects
reactions to certain actions in the tree.

Objects of this class aren't usually created manually, but by preparing
a request via L<ReUI::View/prepare>.

=head1 METHODS

=head1 ATTRIBUTES

=head1 IMPLEMENTS

=over

=item * L<ReUI::State::API>

=item * L<ReUI::Role::Variations>

=item * L<ReUI::Role::EventHandling>

=back

=head1 SEE ALSO

=over

=item * L<ReUI>

=item * L<ReUI::State::API>

=item * L<ReUI::View>

=back

=cut
