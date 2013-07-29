package WW::ParserGen::PDA::OpGraph::BackTrackNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has bt_slot_index => (
    is          => 'ro',
    isa         => 'Int',
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { 1 }

sub set_bt_node($$;$) {
    my ($bt_slot_index, $next_node, $op_comment) = @_;
    return __PACKAGE__->new (
        node_type => 'set_bt', bt_slot_index => $bt_slot_index,
        ($op_comment ? ( op_comment => $op_comment ) : ( )),
        out_nodes => [ $next_node, $next_node ]
    );
}

sub goto_bt_node($$;$) {
    my ($bt_slot_index, $next_node, $op_comment) = @_;
    return __PACKAGE__->new (
        node_type => 'goto_bt', bt_slot_index => $bt_slot_index,
        ($op_comment ? ( op_comment => $op_comment ) : ( )),
        out_nodes => [ $next_node, $next_node ]
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( set_bt_node goto_bt_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

