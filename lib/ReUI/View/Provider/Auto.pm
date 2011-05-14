use strictures 1;

# ABSTRACT: Markup file autodiscovery

package ReUI::View::Provider::Auto;
use Moose;

use ReUI::Types     qw( DirList );
use ReUI::Util      qw( file_by_object );
use ReUI::Traits    qw( Lazy Array );
use Moose::Util     qw( does_role );
use HTML::Zoom;
use Carp            qw( confess );

use constant DEFAULT_MARKUP => 'base';

use syntax qw( function method );
use namespace::autoclean;


=attr search_paths

This is a L<DirList|ReUI::Types::Common/DirList> containing the paths that
should be searched for markup files.

=method search_paths

    ( Dir, ... ) = $object->search_paths;

Returns a list of paths to search markup files in.

=method has_search_paths

    Bool = $object->has_search_paths;

Returns true if any search paths were specified, false otherwise.

=method _build_search_paths

    DirList = $object->_build_search_paths;

Returns an empty L<dirList|ReUI::Types::Common/DirList> by default.

=cut

has search_paths => (
    traits      => [ Lazy, Array ],
    isa         => DirList,
    required    => 1,
    coerce      => 1,
    handles     => {
        search_paths        => 'elements',
        has_search_paths    => 'count',
    },
);

method _build_search_paths { [] }


=method markup_for

See L<ReUI::View::Provider::API/markup_for>. This method will throw an error
if no markup file cound be found. It uses L</locate_markup_file> to find the
markup to load.

=cut

method markup_for ($object, $name) {
    $name = does_role($object, 'ReUI::Widget::API::Styled')
            ? $object->style
            : DEFAULT_MARKUP
        unless defined $name;
    (my $file = ref($name)
        ? $name
        : $self->locate_markup_file($object, $name)
    ) or confess "No markup file found for $object";
    return HTML::Zoom->from_file($file);
}


=method locate_markup_file

    File = $object->locate_markup_file( $object, $part );

Returns a file object for the closest markup file for the passed C<$object>
and corresponding to the C<$part> string. The details are outlined in the
L</Markup Discovery> section.

=cut

method locate_markup_file ($object, $partname) {
    my $filename = $partname . '.html';
    return file_by_object($object, $filename, [$self->search_paths]);
}


with qw(
    ReUI::View::Provider::API
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=head1 SYNOPSIS

    my $provider = ReUI::View::Provider::Auto->new(
        search_paths => [ '/foo/bar' ],
    );

    my $file = $provider->locate_markup_file($object, 'part');
    my $zoom = $provider->markup_for($object, 'part');

=head1 DESCRIPTION

This markup provider will try to discover markup files on disk that relate
to the objects inheritance tree.

=head2 Markup Discovery

To find a markup file for an object, this provider will first calculate
all classes in the inheritance tree of the object. For each non-anonymous
class it will look for a file named after the part with an C<html> extension,
transforming the class in to a path rooted in each of the L</search_paths>.

If any of the classes consume any roles, the paths for the roles will be
searched before the classes, with the exception of the C<base> part, which
can only be supplied by a class.

This means that given

    class Foo does Baz
    class Bar extends Foo, does Qux

A search for the C<base> part would look for the following paths inside the
L</search_paths> when handed a C<Bar> object:

    bar/base.html
    foo/base.html

In comparison, a search for an C<extended> part would look in

    qux/extended.html
    bar/extended.html
    baz/extended.html
    foo/extended.html

The conversion of package names is pretty simple. Here are a few examples:

    Foo         -> foo
    Foo::Bar    -> foo/bar
    FooBar      -> foo_bar

=head1 METHODS

=head1 ATTRIBUTES

=head1 IMPLEMENTS

=over

=item * L<ReUI::View::Provider::API>

=back

=head1 SEE ALSO

=over

=item * L<ReUI::View::Provider::API>

=item * L<ReUI::View>

=item * L<HTML::Zoom>

=back

=cut
