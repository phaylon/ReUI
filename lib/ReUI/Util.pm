use strictures 1;

# ABSTRACT: General utility functions

package ReUI::Util;

use Class::MOP;
use Scalar::Util    qw( blessed );
use Carp            qw( confess );
use File::ShareDir  qw( module_file );
use Try::Tiny;

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
        file_by_object
        lineup
        empty_stream
    )],
};

fun empty_stream { HTML::Zoom->from_events([]) }

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

fun file_by_object ($object, $file, $paths) {
    $paths = []
        unless defined $paths;
    my @classes = grep {
        not $_->meta->is_anon_class;
    } $object->meta->linearized_isa;
    my %seen;
    while (my $class = shift @classes) {
        unshift @classes,
                grep { not $seen{ $_ }++; } $class->meta->calculate_all_roles
            if $class->meta->isa('Moose::Meta::Class');
        (my $class_path = $class) =~ s/::/-/g;
        for my $root (@$paths) {
            my $full = $root->file('module', $class_path, $file);
            return $full
                if -e $full;
        }
        if (my $installed = try { module_file($class, $file) }) {
            return $installed;
        }
    }
    return undef;
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
