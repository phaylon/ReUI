use strictures 1;

# ABSTRACT: General utility functions

package ReUI::Util;

use Class::MOP;

use syntax qw( function );
use namespace::clean;

use Sub::Exporter -setup => {
    exports => [qw(
        load_class
        human_join_with
        class_to_path
        deflatten_hashref
        flatten_hashref
        filter_flat_hashref
        lineup
    )],
};

fun lineup ($str) {
    return  join ' ',
            grep { length }
            map { s/(?:^\s+|\s+$)//g ;; $_ }
            split qr/\n/, $str;
}

fun filter_flat_hashref ($prefix, $data) {
    return +{
        map  {
            my $val = $data->{ $_ };
            s/^\Q$prefix\E\.//;
            ($_, $val);
        }
        grep { m/^\Q$prefix\E\..+/ }
        keys %$data,
    };
}

fun flatten_hashref ($original, %opt) {
    my $flatten = fun ($data, $flatten, @prefix) {
        return map {
            my $key = $_;
            my $val = $data->{ $_ };
            ref($val) eq 'HASH'
                ? ( $flatten->($val, $flatten, @prefix, $key) )
                : ( join('.', @prefix, $key), $val );
        } keys %$data;
    };
    my %done = $flatten->($original, $flatten);
    return $opt{deref} ? %done : \%done;
}

fun deflatten_hashref ($data) {
    my %done;
    my %collected;
    for my $namespace (keys %$data) {
        my ($top, @rest) = split m{\.}, $namespace;
        if (@rest) {
            $collected{ $top }{ join '.', @rest } = $data->{ $namespace };
        }
        else {
            $done{ $top } = $data->{ $namespace };
        }
    }
    delete $collected{ $_ } for keys %done;
    my $rec = +{
        ( map {
            ($_, deflatten_hashref($collected{ $_ }));
        } keys %collected ),
        %done,
    };
    return $rec;
}

fun class_to_path ($class) {
    join '/',
    map lc,
    map { s/ ([A-Z]*) ([A-Z]) ([^A-Z0-9]) /$1_$2$3/gx ;; $_ }
    map lcfirst,
    split qr{::}, $class;
}

fun human_join_with ($word, @parts) {
    return(
        ( @parts == 0 ) ? ''
      : ( @parts == 1 ) ? $parts[0]
      : ( @parts == 2 ) ? join(" $word ", @parts)
      : join(', ',
            $parts[0],
            human_join_with($word, @parts[ 1 .. $#parts ]),
        ),
    );
}

fun load_class ($class) {
    Class::MOP::load_class($class);
    return $class;
}

1;
