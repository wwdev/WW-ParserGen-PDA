package WW::ParserGen::PDA::OpGraph::VarMoveNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has [qw( dest_name op src_name )] => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { 1 }

use WW::Parse::PDA::VarSetOps qw( :all );

sub to_string_short {
    my ($self, $indent) = @_;
    return $self->SUPER::to_string_short ($indent) .
        ' $' . $self->dest_name . ' ' . $self->op . ' $' . $self->src_name;
}

sub var_move_node($$$$) {
    return __PACKAGE__->new (
        node_type => 'var_move', dest_name => $_[0], op => $_[1],
        src_name => $_[2], out_nodes => [ $_[3], $_[3] ],
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( var_move_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

