package WW::ParserGen::PDA::OpGraph::LiteralMatchNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has match_text => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { 1 }

sub to_string_short {
    my ($self, $prefix) = @_;
    return $self->SUPER::to_string_short ($prefix) .
        ' << ' . $self->match_text . ' >>';
}

sub literal_match_node {
    return __PACKAGE__->new (node_type => 'literal_match', @_);
}

use Exporter qw( import );

our @EXPORT_OK = qw( literal_match_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

