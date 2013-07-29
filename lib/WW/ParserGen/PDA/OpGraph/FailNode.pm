package WW::ParserGen::PDA::OpGraph::FailNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

no Moose;
__PACKAGE__->meta->make_immutable;

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { 1 }

sub fail_node($) {
    my ($next_node) = @_;
    return __PACKAGE__->new (
        node_type => 'fail', out_nodes => [ $next_node, $next_node ]
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( fail_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

