use strictures 1;

# ABSTRACT: Container interface

package ReUI::Widget::Container::API;
use Moose::Role;

use syntax qw( function method );
use namespace::autoclean;

requires qw(
    widgets
    add
    is_empty
    widget
    compile
);

1;
