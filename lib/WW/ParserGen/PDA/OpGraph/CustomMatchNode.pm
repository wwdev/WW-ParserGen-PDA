package WW::ParserGen::PDA::OpGraph::CustomMatchNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has match_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has match_args => (
    is          => 'rw',
#    isa         => 'ArrayRef', or undef
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { 1 }

sub to_string_short {
    my ($self, $indent) = @_;
    return $self->SUPER::to_string_short ($indent) .
        ' custom match: ' . $self->match_name .
        ($self->match_args ? '[ ' . join (' ', @{$self->match_args}) . ' ]' : '');
}

sub custom_match_node($$$) {
    my ($match_name, $match_args, $next_node) = @_;
    return __PACKAGE__->new (
        node_type => 'custom_match', 
        match_name => $match_name, match_args => $match_args,
        out_nodes => [ $next_node, $next_node ]
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( custom_match_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

