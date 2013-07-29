package WW::ParserGen::PDA::OpGraph::IfTestNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has var_refs => (
    is          => 'rw',
    isa         => 'ArrayRef',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub is_sequential_node { undef }
sub is_terminal_node { 1 }
sub is_nop_on_fall_through { 1 }

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { undef }

sub to_string_short {
    my ($self, $indent) = @_;
    return $self->SUPER::to_string_short ($indent) .
        ' if_test: ' . join (' ', @{$self->var_refs});
}

sub if_test_node($$$) {
    my ($var_refs, $ok_node, $fail_node) = @_;
    return __PACKAGE__->new (
        node_type => 'if_test', 
        var_refs  => $var_refs,
        out_nodes => [ $ok_node, $fail_node ]
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( if_test_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

