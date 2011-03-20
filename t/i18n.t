use strictures 1;
use Test::More;

use utf8;
use charnames ':full';
use syntax qw( function );
use ReUI::Test qw( :all VIEW );

my %tested;

fun test_with_language ($language, @tests) {
    my $state = VIEW->prepare(request => {
        parameters  => {},
        method      => 'GET',
    })->with_language($language);
    grouped("language $language", sub {
        for my $test (@tests) {
            my ($msg, $expected) = @$test;
            my $key = ref($msg) ? $msg->[0] : $msg;
            $tested{ $_ }{ $key }++
                for $language, 'all';
            is  $state->render($msg),
                $expected,
                ref($msg)
                    ? join(', ', @$msg)
                    : $msg;
        }
    });
}

my @common = (
    ['fnord',                           'fnord'],
    ['[i18n,fnord]',                    'fnord'],
    ['[bool,1,Y,N]',                    'Y'],
    ['[bool,0,Y,N]',                    'N'],
    [['[qcase,_1,0,no,1,one,_1]', 0],   'no'],
    [['[qcase,_1,0,no,1,one,_1]', 1],   'one'],
    [['[qcase,_1,0,no,1,one,_1]', 2],   '2'],
);

my %test = (
    en => [
        @common,
        ['reui.label.ok',                   'OK'],
        ['reui.label.cancel',               'Cancel'],
        ['reui.label.submit',               'Submit'],
        ['reui.label.save',                 'Save'],
        ['reui.label.create',               'Create'],
        ['reui.label.add',                  'Add'],
        ['reui.label.delete',               'Delete'],
        ['reui.label.search',               'Search'],
        ['reui.label.register',             'Register'],
        ['reui.label.signin',               'Sign In'],
        ['reui.label.signout',              'Sign Out'],
        ['reui.label.send',                 'Send'],
        [['reui.bool.yes_no', 1],           'Yes'],
        [['reui.bool.yes_no', 0],           'No'],
        [['reui.bool.true_false', 1],       'True'],
        [['reui.bool.true_false', 0],       'False'],
        [['reui.bool.on_off', 1],           'On'],
        [['reui.bool.on_off', 0],           'Off'],
        [['reui.bool.active_inactive', 1],  'Active'],
        [['reui.bool.active_inactive', 0],  'Inactive'],
        [   ['reui.control.invalid', 'reui.label.search'],
            'Invalid value for Search',
        ],
        [   ['reui.control.password.mismatch', 'Foo', 'Bar'],
            'Password is not the same as in Bar',
        ],
        ['reui.control.missing',            'Value is missing'],
        [['reui.numeric.bytes', 2048],      '2K'],
        [['reui.numeric.float', 1234.56],   '1,234.56'],
        [['reui.numeric.int', 12000],       '12,000'],
        [   ['reui.numeric.currency', EUR => 2323],
            "\N{EURO SIGN} 2,323.00",
        ],
        [   ['reui.numeric.currency', USD => 2323],
            '$ 2,323.00',
        ],
        [   ['reui.numeric.currency', GBP => 2323],
            "\N{POUND SIGN} 2,323.00",
        ],
        [   ['reui.numeric.currency', YEN => 2323],
            "\N{YEN SIGN} 2,323.00",
        ],
    ],
    de => [
        @common,
        ['reui.label.ok',                   'OK'],
        ['reui.label.cancel',               'Abbruch'],
        ['reui.label.submit',               'Absenden'],
        ['reui.label.save',                 'Speichern'],
        ['reui.label.create',               'Anlegen'],
        ['reui.label.add',                  'Hinzufügen'],
        ['reui.label.delete',               'Löschen'],
        ['reui.label.search',               'Suche'],
        ['reui.label.register',             'Registrieren'],
        ['reui.label.signin',               'Anmelden'],
        ['reui.label.signout',              'Abmelden'],
        ['reui.label.send',                 'Senden'],
        [['reui.bool.yes_no', 1],           'Ja'],
        [['reui.bool.yes_no', 0],           'Nein'],
        [['reui.bool.true_false', 1],       'Wahr'],
        [['reui.bool.true_false', 0],       'Falsch'],
        [['reui.bool.on_off', 1],           'An'],
        [['reui.bool.on_off', 0],           'Aus'],
        [['reui.bool.active_inactive', 1],  'Aktiv'],
        [['reui.bool.active_inactive', 0],  'Inaktiv'],
        [   ['reui.control.invalid', 'reui.label.search'],
            'Ungültiger Wert für Suche',
        ],
        [   ['reui.control.password.mismatch', 'Foo', 'Bar'],
            'Passwort ist nicht mit dem in Bar identisch',
        ],
        ['reui.control.missing',            'Fehlende Eingabe'],
        [['reui.numeric.bytes', 2048],      '2K'],
        [['reui.numeric.float', 1234.56],   '1.234,56'],
        [['reui.numeric.int', 12000],       '12.000'],
        [   ['reui.numeric.currency', EUR => 2323],
            "\N{EURO SIGN} 2.323,00",
        ],
        [   ['reui.numeric.currency', USD => 2323],
            '$ 2.323,00',
        ],
        [   ['reui.numeric.currency', GBP => 2323],
            "\N{POUND SIGN} 2.323,00",
        ],
        [   ['reui.numeric.currency', YEN => 2323],
            "\N{YEN SIGN} 2.323,00",
        ],
    ],
);

test_with_language($_, @{ $test{ $_ } })
    for keys %test;

grouped('test completeness', sub {
    my @all = sort keys %{ $tested{all} };
    for my $language (keys %test) {
        grouped("language $language", sub {
            for my $key (@all) {
                ok $tested{ $language }{ $key }, "$key was tested";
            }
        });
    }
});

done_testing;
