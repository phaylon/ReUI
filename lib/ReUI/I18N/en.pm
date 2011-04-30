use strictures 1;

# ABSTRACT: English core I18N messages

package ReUI::I18N::en;
use parent 'ReUI::I18N';

use ReUI::Util qw( flatten_hashref );

use syntax qw( function method );
use namespace::autoclean;

method thousands_sep { ',' }
method decimal_point { '.' }

our %Lexicon = flatten_hashref({
    reui => {
        label => {
            ok          => 'OK',
            cancel      => 'Cancel',
            submit      => 'Submit',
            save        => 'Save',
            add         => 'Add',
            create      => 'Create',
            delete      => 'Delete',
            search      => 'Search',
            register    => 'Register',
            signin      => 'Sign In',
            signout     => 'Sign Out',
            send        => 'Send',
        },
        bool => {
            yes_no          => '[bool,_1,Yes,No]',
            true_false      => '[bool,_1,True,False]',
            on_off          => '[bool,_1,On,Off]',
            active_inactive => '[bool,_1,Active,Inactive]',
        },
        control => {
            invalid     => 'Invalid value for [i18n,_1]',
            missing     => 'Value is missing',
            hidden      => {
                missing     => 'Missing value for [i18n,_1]',
            },
            password    => {
                mismatch    => 'Password is not the same as in [i18n,_2]',
            },
        },
    },
    __PACKAGE__->common_messages,
}, deref => 1);

1;
