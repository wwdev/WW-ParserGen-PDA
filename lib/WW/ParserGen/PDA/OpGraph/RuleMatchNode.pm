package WW::ParserGen::PDA::OpGraph::RuleMatchNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has rule_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub is_sequential_node { undef }
sub is_terminal_node { 1 }

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { undef }

sub to_string_short {
    my ($self, $indent) = @_;
    return $self->SUPER::to_string_short ($indent) . 
        ' Call: ' . $self->rule_name;
}

sub rule_match_node($$$$$) {
    my ($rule_name, $topo_seq_index, $set_match, $ok_node, $fail_node,) = @_;
    return __PACKAGE__->new (
        node_type           => 'rule_match', 
        rule_name           => $rule_name,
        topo_sequence_index => $topo_seq_index,
        ($set_match ? ( set_match => $set_match ) : ( )),
        out_nodes           => [ $ok_node, $fail_node ],
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( rule_match_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

