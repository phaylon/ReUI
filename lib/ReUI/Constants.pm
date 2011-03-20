use strictures 1;

# ABSTRACT: Common values

package ReUI::Constants;

my (%Constant, %I18N);
BEGIN {
    %I18N = ( map { ('I18N_' . $_->[0], $_->[1]) }
        [ VALUE_INVALID     => 'reui.control.invalid' ],
        [ VALUE_MISSING     => 'reui.control.missing' ],
        [ PASSWORD_MISMATCH => 'reui.control.password.mismatch' ],
    );
    %Constant = (%I18N);
};

use constant \%Constant;
use Sub::Exporter -setup => {
    exports => [keys %Constant],
    groups  => {
        i18n    => [keys %I18N],
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
