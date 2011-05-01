use strictures 1;

# ABSTRACT: Common values

package ReUI::Constants;

use Params::Classify qw( is_ref );

use syntax qw( function );
use namespace::clean;

my (%Constant, %I18N, %SkinFile);
BEGIN {
    my $prepare = fun ($prefix, @to) {
        return map {
            (   join('_', $prefix, $_->[0]),
                $_->[1],
            );
        } @to;
    };
    %I18N = $prepare->('I18N',
        [ VALUE_INVALID         => 'reui.control.invalid' ],
        [ VALUE_MISSING         => 'reui.control.missing' ],
        [ VALUE_HIDDEN_MISSING  => 'reui.control.hidden.missing' ],
        [ PASSWORD_MISMATCH     => 'reui.control.password.mismatch' ],
    );
    %SkinFile = $prepare->('SKINFILE',
        [ MESSAGE_ICON_PATH     => \[qw( message icon )] ],
    );
    %Constant = (%I18N, %SkinFile);
};

#use constant \%Constant;

use constant ();
BEGIN {
    for my $name (keys %Constant) {
        my $value = $Constant{ $name };
        constant->import(
            $name,
            ( is_ref($value, 'SCALAR') and is_ref($$value, 'ARRAY') )
                ? @{ $$value }
                : $value
        );
    }
}

use Sub::Exporter -setup => {
    exports => [keys %Constant],
    groups  => {
        i18n        => [keys %I18N],
        skinfiles   => [keys %SkinFile],
    },
};

1;

__END__

=head1 SYNOPSIS

    use ReUI::Constants qw(
        # :i18n group
        I18N_VALUE_INVALID
        I18N_VALUE_MISSING
        I18N_PASSWORD_MISMATCH
    );

=head1 DESCRIPTION

This module contains common values used across L<ReUI>.

=head1 CONSTANTS

=head2 I18N_VALUE_INVALID

I18N key used to indicate an invalid value.

=head2 I18N_VALUE_MISSING

I18N key used to indicate a missing value.

=head2 I18N_PASSWORD_MISMATCH

I18N key used to indicate that two password fields that should have been
equal aren't.

=cut
