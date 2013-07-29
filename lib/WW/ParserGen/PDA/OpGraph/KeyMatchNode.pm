package WW::ParserGen::PDA::OpGraph::KeyMatchNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has key_lengths => (
    is          => 'ro',
    isa         => 'ArrayRef',
    required    => 1,
);

has match_map => (
    is          => 'ro',
    isa         => 'HashRef',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub is_sequential_node { undef }
sub is_terminal_node { 1 }

sub needs_2_out_nodes { undef }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { undef }

sub to_string_short {
    my ($self, $indent) = @_;
    return $self->SUPER::to_string_short ($indent) . 
        ' keys: ' . join (' ', keys %{$self->match_map});
}

sub key_match_node($$$$$) {
    my ($topo_seq_index, $set_match, $key_lengths, $match_map, $fail_node) = @_;
    return __PACKAGE__->new (
        node_type           => 'key_match', 
        topo_sequence_index => $topo_seq_index,
        ($set_match ? ( set_match => $set_match ) : ( )),
        key_lengths         => $key_lengths,
        match_map           => $match_map,
        out_nodes           => [ 
            $fail_node, $fail_node, values %$match_map
        ],
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( key_match_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

