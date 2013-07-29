package WW::ParserGen::PDA::OpGraph::HashReturnNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

no Moose;
__PACKAGE__->meta->make_immutable;

sub is_sequential_node { undef }
sub is_terminal_node { 1 }

sub clone {
    return __PACKAGE__->new (node_type => 'hash_return');
}

sub hash_return_node {
    return __PACKAGE__->new (node_type => 'hash_return');
}

use Exporter qw( import );

our @EXPORT_OK = qw( hash_return_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

