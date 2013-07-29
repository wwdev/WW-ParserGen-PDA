package WW::ParserGen::PDA::OpGraph::PkgReturnNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has node_pkg => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub is_sequential_node { undef }
sub is_terminal_node { 1 }

sub clone {
    return __PACKAGE__->new (node_type => 'pkg_return', node_pkg => $_[0]->node_pkg);
}

sub to_string_short {
    my ($self, $indent) = @_;
    return $self->SUPER::to_string_short ($indent) .
        ' NodePkg: ' . $self->node_pkg;
}

sub pkg_return_node($) {
    return __PACKAGE__->new (node_type => 'pkg_return', node_pkg => $_[0]);
}

use Exporter qw( import );

our @EXPORT_OK = qw( pkg_return_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

