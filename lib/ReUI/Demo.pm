use strictures 1;

package ReUI::Demo;
use Moose;

use ReUI::Traits        qw( Lazy Hash );
use ReUI::Types         qw( HashRef Dict NonEmptySimpleStr CodeRef );
use Carp                qw( confess );
use Params::Classify    qw( is_blessed );
use FindBin;
use Try::Tiny;

use aliased 'ReUI::View';
use aliased 'ReUI::Widget::Page';
use aliased 'ReUI::Widget::Content';
use aliased 'ReUI::Widget::Link';
use aliased 'ReUI::Widget::List';
use aliased 'ReUI::Widget::List::Item';
use aliased 'Plack::App::URLMap';
use aliased 'Plack::Request';
use aliased 'Plack::Response';
use aliased 'IO::File::WithPath';
use aliased 'MIME::Types';

use syntax qw( function method );
use namespace::autoclean;


has root_map => (
    traits      => [ Lazy ],
    isa         => URLMap,
    handles     => [qw( to_app )],
);

method _build_root_map {
    my $app = URLMap->new;
    $app->map('/static' => $self->_make_static_handler);
    $app->map('/'       => $self->_make_dynamic_handler);
    return $app;
}


has skin_class => (
    traits      => [ Lazy ],
    is          => 'ro',
    required    => 1,
);

method _build_skin_class { $ENV{REUI_SKIN} || 'ReUI::Skin::Base' }


has view => (
    traits      => [ Lazy ],
    isa         => View,
    handles     => [qw( locate_skin_file prepare )],
);

method _build_view {
    return View->new(
        search_paths    => ["$FindBin::Bin/../share"],
        skins           => {
            base    => {
                class   => $self->skin_class,
                title   => 'Demo Skin',
            },
        },
    );
}


has screens => (
    traits      => [ Hash, Lazy ],
    isa         => HashRef[ HashRef ],
    handles     => {
        screen_names    => 'keys',
        screen          => 'get',
        has_screens     => 'count',
        has_screen      => 'exists',
    },
);

method _build_screens { +{ $self->_build_screen_options } }

method _build_screen_options { () }


method _uri_for ($state, @args) {
    my $req = $state->variables->{plack};
    return join '', $req->base, join '/', @args;
}

method _make_index_widgets ($state) {
    return List->new(
        items => [ map {
            my $screen = $self->screen($_);
            Item->new(widgets => [
                Link->new(
                    href    => $self->_uri_for($state, $_),
                    widgets => [
                        Content->new(
                            content => $screen->{title},
                        ),
                    ],
                ),
            ]);
        } $self->screen_names ],
    );
}

method _make_screen_widgets ($state, $name, @path) {
    my $screen = $self->screen($name)
        or $self->_throw_status(404, 'Not found');
    return $screen->{builder}->($self, $state, @path);
}

method _make_page_widgets ($state, @path) {
    unless (@path) {
        return $self->_make_index_widgets($state);
    }
    return $self->_make_screen_widgets($state, @path);
}

method _throw_status ($code, $msg) {
    die bless { code => $code, msg => $msg }, 'ReUI::Demo::Error';
}

method _prepare_request ($req) {
    return $self->prepare(
        request => {
            parameters  => $req->parameters->as_hashref_mixed,
            method      => $req->method,
        },
        variables => {
            plack       => $req,
        },
    );
}

method _make_page ($state, $req, $path) {
    return Page->new(
        skin                => 'base',
        title               => sub {
            return join ' - ',
                __PACKAGE__,
                $_{title} ? $_{title} : ();
        },
        widgets             => [
            $self->_make_page_widgets($state, split m{/}, $path),
        ],
        skin_uri_callback   => fun (@args) {
            return sprintf '%sstatic/%s',
                $req->base,
                join '/', @args;
        },
    );
}

method _make_dynamic_handler {
    return $self->_wrap_handler(fun ($req) {
        my $state = $self->_prepare_request($req);
        (my $path = $req->path_info) =~ s{(?:^/|/$)}{}g;
        my $is_failed;
        try {
            $state->add($self->_make_page($state, $req, $path));
        }
        catch {
            if (is_blessed($_, 'ReUI::Demo::Error')) {
                $is_failed = $_;
            }
            else {
                die $_;
            }
        };
        return $req->new_response($is_failed->{code}, [], $is_failed->{msg})
            if $is_failed;
        return $req->new_response(
            200,
            ['Content-Type', 'text/html'],
            $state->process->body,
        );
    });
}

method _make_static_handler {
    my $mime = Types->new;
    return $self->_wrap_handler(fun ($req) {
        (my $path = $req->path_info || '') =~ s{^/}{};
        my ($skin, $file) = split m{/}, $path, 2;
        if ($skin and $file) {
            my $found = try {
                $self->locate_skin_file($skin, $file);
            };
            if ($found) {
                return $req->new_response(
                    200,
                    [   'Content-Type',
                        try { $mime->mimeTypeOf($file)->type }
                        catch { 'binary/x-unknown' },
                    ],
                    WithPath->new($found),
                );
            }
        }
        return $req->new_response(404);
    });
}


method _wrap_handler ($code) {
    return fun ($env) {
        my $req = Request->new($env);
        my $res = $code->($req);
        confess sprintf q{Expected a %s object, got %s},
                Response, defined($res) ? $res : 'undef'
            unless is_blessed($res, Response);
        return $res->finalize;
    };
}


with qw(
    ReUI::Demo::Screen::Forms
);

1;
