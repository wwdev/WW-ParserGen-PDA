package WW::ParserGen::PDA::OpGraph::ExprOpRightArgNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

no Moose;
__PACKAGE__->meta->make_immutable;

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { 1 }

# use super class's version
#sub to_string_short {
#    my ($self, $prefix) = @_;
#    return $self->SUPER::to_string_short ($prefix);
#}

sub expr_op_right_arg_node {
    return __PACKAGE__->new (node_type => 'expr_op_right_arg', @_);
}

use Exporter qw( import );

our @EXPORT_OK = qw( expr_op_right_arg_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

