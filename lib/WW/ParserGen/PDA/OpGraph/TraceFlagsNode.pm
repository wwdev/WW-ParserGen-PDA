package WW::ParserGen::PDA::OpGraph::TraceFlagsNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has trace_flags => (
    is          => 'rw',
    isa         => 'Int',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { 1 }

sub to_string_short {
    my ($self, $indent) = @_;
    return $self->SUPER::to_string_short ($indent) .
        ' trace flags: ' . $self->trace_flags;
}

sub trace_flags_node($$) {
    my ($trace_flags, $next_node) = @_;
    return __PACKAGE__->new (
        node_type => 'trace_flags', 
        trace_flags => $trace_flags,
        out_nodes => [ $next_node, $next_node ]
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( trace_flags_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

