package WW::ParserGen::PDA::OpGraph::FatalNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has msg_params => (
    is          => 'rw',
#    isa         => 'ArrayRef', or undef
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub is_sequential_node { undef }
sub is_terminal_node { 1 }

sub clone {
    return __PACKAGE__->new (
        node_type => 'fatal', msg_params => $$_[0]->msg_params
    );
}

sub to_string_short {
    my ($self, $indent) = @_;
    return $self->SUPER::to_string_short ($indent) .
        ' msg params: ' . 
        ($self->msg_params ? '[ ' . join (' ', @{$self->msg_params}) . ' ]' : '');
}

sub fatal_node($) {
    my ($msg_params) = @_;
    return __PACKAGE__->new (
        node_type => 'fatal', 
        msg_params => $msg_params,
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( fatal_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

