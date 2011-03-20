use strictures 1;

package ReUI::Test;

use Test::More  ();
use FindBin     qw( $Bin );
use Carp        qw( croak );

use aliased 'ReUI::View';
use aliased 'ReUI::Widget::Raw';

use syntax qw( function );
use namespace::clean;

use Sub::Exporter -setup => {
    exports => [qw(
        test_processing
        test_markup
        grouped
        test_widget
        test_require_call
        VIEW
    )],
    groups => {
        default => [qw(
            test_processing
            test_markup
            grouped
            test_widget
            test_require_call
        )],
    },
};

my $View = View->new(
    search_paths => ["$Bin/../share/templates"],
);

sub VIEW () { $View }

our $LEVEL = 0;
our @REQUIRE_CALL;

fun test_require_call ($title, $count) {
    $count = 1 unless defined $count;
    my $seen = 0;
    my $test = fun ($cmd) {
        if (not defined $cmd) {
            Test::More::note("$title was called");
            $seen++;
        }
        elsif ($cmd eq 'check') {
            Test::More::is($seen, $count, "$title was called $count time(s)");
        }
        else {
            die "Unknown test_require_call command '$cmd'\n";
        }
    };
    push @REQUIRE_CALL, $test;
    return $test;
}

fun grouped ($title, $code) {
    if ($ENV{REUI_TEST_FLAT}) {
        Test::More::note(sprintf '%s%s',
            $LEVEL ? sprintf(' %s ', '*' x $LEVEL) : '',
            $title,
        );
        local $LEVEL = $LEVEL + 1;
        $code->();
    }
    else {
        Test::More::note($title);
        Test::More::subtest($title, sub {
            $code->();
            Test::More::done_testing;
        });
    }
}

fun test_widget ($id) {
    Raw->new(content => sprintf
        '<span id="test-value-%s">Test Value %s</span>',
        $id, $id,
    );
}

fun test_processing ($title, $args, @tests) {
    local $ENV{REUI_SKIP_DISTDIR} = 1;
    local @REQUIRE_CALL;
    grouped($title, sub {
        my $widget = $args->{widget}
            or croak "Missing widget argument";
        my $request = +{
            parameters  => {},
            method      => 'GET',
            %{ $args->{request} || {} },
        };
        my $state = $View->prepare(
            request => $request,
        );
        $widget = $state->$widget
            if ref $widget eq 'CODE';
        $state->add($widget);
        $state->add_variables(%{ $args->{variables} })
            if $args->{variables};
        my $response = $state->process;
        $_->($response)
            for @tests;
        if (@REQUIRE_CALL) {
            grouped('callbacks', sub {
                $_->('check')
                    for @REQUIRE_CALL;
            });
        }
        else {
            Test::More::note('no callbacks');
        }
    });
}

fun test_markup ($test) {
    return fun ($response) {
        my $body = $response->body;
        warn "MARKUP:\n$body\n"
            if $ENV{REUI_MARKUP};
        require ReUI::Test::XPath;
        my $xpath = ReUI::Test::XPath->new(xml => $body, is_html => 1);
        grouped('markup', sub {
            $test->($xpath);
        });
    };
}

1;
