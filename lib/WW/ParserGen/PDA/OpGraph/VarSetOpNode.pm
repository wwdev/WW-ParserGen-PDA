package WW::ParserGen::PDA::OpGraph::VarSetOpNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has var_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has op => (
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
        ' $' . $self->var_name . ' ' . $self->op;
}

sub var_set_op_node($$$) {
    return __PACKAGE__->new (
        node_type => 'var_set_op', var_name => $_[0], op => $_[1],
        out_nodes => [ $_[2], $_[2] ],
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( var_set_op_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

