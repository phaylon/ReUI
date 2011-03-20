use strictures 1;

# ABSTRACT: Internationalization handler

package ReUI::I18N;
use parent 'Locale::Maketext';

use ReUI::Util                  qw( flatten_hashref );
use DateTime::Format::Strptime;
use Number::Format;
use Carp                        qw( confess );
use charnames                   qw( :full );

use syntax qw( function method );
use namespace::autoclean;

method include_currency_signs { 1 }

method common_messages ($class:) {
    return flatten_hashref({
        _AUTO => 1,
        reui => {
            numeric => {
                bytes       => '[bytes,_1,precision,2,mode,trad]',
                float       => '[number,_1]',
                int         => '[number,_1,0]',
                currency    => '[i18n,_1] [number,_2,2,1]',
            },
        },
        $class->include_currency_signs ? (
            EUR => "\N{EURO SIGN}",
            USD => "\N{DOLLAR SIGN}",
            GBP => "\N{POUND SIGN}",
            YEN => "\N{YEN SIGN}",
        ) : (),
    }, deref => 1);
}

method bool ($value, $true, $false) {
    return $value ? $true : $false;
}

method strftime ($dt, $format) {
    return $dt->strftime($format);
}

method i18n ($msg) {
    confess "Undefined I18N message"
        unless defined $msg;
    return $self->maketext((ref($msg) eq 'ARRAY') ? @$msg : $msg);
}

method qcase ($num, @args) {
    confess "qcase requires odd amount of arguments"
        unless @args %2;
    while (@args > 1) {
        my $if   = shift @args;
        my $then = shift @args;
        return $then
            if $if == $num;
    }
    return shift @args;
}

method thousands_sep        { die "$self did not provide thousand_sep\n" }
method decimal_point        { die "$self did not provide decimal_point\n" }

method _number_formatter {
    return $self->{__reui_number_formatter} ||= Number::Format->new(
        thousands_sep   => $self->thousands_sep,
        decimal_point   => $self->decimal_point,
    );
}

method bytes ($number, %args) {
    return $self->_number_formatter->format_bytes($number, %args);
}

method number ($number, $precision, $trailing) {
    $precision = 2
        unless defined $precision;
    $trailing = 0
        unless defined $trailing;
    return $self->_number_formatter->format_number(
        $number,
        $precision,
        $trailing,
    );
}

method datetime_formats { die "$self did not provide datetime_formats\n" }
method date_formats     { die "$self did not provide date_formats\n" }
method time_formats     { die "$self did not provide time_formats\n" }
method datetime_locale  { die "$self did not provide datetime_locale\n" }

my $Strptime = DateTime::Format::Strptime->new(
    pattern  => '%T',
    on_error => 'undef',
);

method _try_datetime_parse ($string, @formats) {
    $Strptime->locale($self->datetime_locale);
    for my $format (@formats) {
        $Strptime->pattern($format);
        my $dt = $Strptime->parse_datetime($string)
            or next;
        return $dt;
    }
    return undef;
}

method datetime_parse ($string) {
    return $self->_try_datetime_parse(
        $string,
        $self->datetime_formats,
    );
}

method date_parse ($string) {
    my $dt = $self->_try_datetime_parse(
        $string,
        $self->date_formats,
    ) or return undef;
    return $dt->truncate(to => 'day');
}

method time_parse ($string) {
    my $dt = $self->_try_datetime_parse(
        $string,
        $self->time_formats,
    ) or return undef;
    return [$_->hour, $_->minute, $_->second];
}

1;
