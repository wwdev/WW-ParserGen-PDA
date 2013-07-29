package WW::ParserGen::PDA::OpGraph::IterSlotOpNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has iter_slot_index => (
    is          => 'ro',
    isa         => 'Int',
    required    => 1,
);

has iter_op => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has value => (
    is          => 'ro',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub is_sequential_node { $_[0]->iter_op ne 'gt' }
sub is_terminal_node { $_[0]->iter_op eq 'gt' }

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { $_[0]->iter_op ne 'gt' }

sub set_iter_slot_node($$$) {
    return __PACKAGE__->new (
        node_type => 'set_iter_slot', iter_slot_index => $_[0], 
        iter_op => 'set', value => $_[1],
        out_nodes => [ $_[2], $_[2] ],
    );
}

sub add_iter_slot_node($$$) {
    return __PACKAGE__->new (
        node_type => 'add_iter_slot', iter_slot_index => $_[0], 
        iter_op => 'add', value => $_[1],
        out_nodes => [ $_[2], $_[2] ],
    );
}

sub cmpgt_iter_slot_node($$$$) {
    return __PACKAGE__->new (
        node_type => 'gt_iter_slot', iter_slot_index => $_[0], 
        iter_op => 'gt', value => $_[1],
        out_nodes => [ $_[2], $_[3] ],
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( set_iter_slot_node add_iter_slot_node cmpgt_iter_slot_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

