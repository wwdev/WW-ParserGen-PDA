package WW::ParserGen::PDA::OpGraph::JumpNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

no Moose;
__PACKAGE__->meta->make_immutable;

sub is_sequential_node { undef }
sub is_terminal_node { 1 }
sub is_nop_on_fall_through { 1 }

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { 1 }

sub jump_node($) {
    return __PACKAGE__->new (
        node_type => 'jump',
        out_nodes => [ $_[0], $_[0] ],
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( jump_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

