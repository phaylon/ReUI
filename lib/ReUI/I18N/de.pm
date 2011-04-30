use strictures 1;

# ABSTRACT: German core I18N messages

package ReUI::I18N::de;
use parent 'ReUI::I18N';

use ReUI::Util qw( flatten_hashref );

use utf8;
use syntax qw( function method );
use namespace::autoclean;

method thousands_sep { '.' }
method decimal_point { ',' }

our %Lexicon = flatten_hashref({
    reui => {
        label => {
            ok          => 'OK',
            cancel      => 'Abbruch',
            submit      => 'Absenden',
            save        => 'Speichern',
            add         => 'Hinzufügen',
            create      => 'Anlegen',
            delete      => 'Löschen',
            search      => 'Suche',
            register    => 'Registrieren',
            signin      => 'Anmelden',
            signout     => 'Abmelden',
            send        => 'Senden',
        },
        bool => {
            yes_no          => '[bool,_1,Ja,Nein]',
            true_false      => '[bool,_1,Wahr,Falsch]',
            on_off          => '[bool,_1,An,Aus]',
            active_inactive => '[bool,_1,Aktiv,Inaktiv]',
        },
        control => {
            invalid     => 'Ungültiger Wert für [i18n,_1]',
            missing     => 'Fehlende Eingabe',
            hidden      => {
                missing     => 'Fehlender Wert für [i18n,_1]',
            },
            password    => {
                mismatch =>
                    'Passwort ist nicht mit dem in [i18n,_2] identisch',
            },
        },
    },
    __PACKAGE__->common_messages,
}, deref => 1);

1;

