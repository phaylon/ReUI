use strictures 1;

package ReUI::Widget::Navigation::API;
use Moose::Role;

use ReUI::Traits    qw( Resolvable );
use ReUI::Types     qw( Does InstanceOf );

use syntax qw( function method );
use namespace::autoclean;


has trail => (
    traits      => [ Resolvable ],
    is          => 'rw',
    isa         => InstanceOf['ReUI::Model::Navigation::Trail'],
    required    => 1,
);


method trail_marker ($trail) {
    my $id_map  = $trail->id_map;
    my $last_id = $id_map->{last};
    return fun ($node, $after_cb) {
        my $current_id = $node->internal_id;
        my $is_active  = $id_map->{ $current_id };
        my $is_current = ($is_active && $last_id && $last_id eq $current_id);
        my $after_node = $after_cb && $after_cb->(
            is_active   => $is_active,
            is_current  => $is_current,
        );
        return sub {
            $_->apply_if($is_active, sub {
                $_->select('li')
                  ->add_to_attribute(class => 'active')
                  ->apply_if($is_current, sub {
                      $_->then
                        ->add_to_attribute(class => 'current');
                  })
                  ->apply_if($after_node, $after_node);
            });
        };
    };
}

1;
