package WW::ParserGen::PDA::AST::DebugBreakOp;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has message => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

sub debug_break_op_ast($) {
    return __PACKAGE__->new (
        node_type => 'debug_break_op', message => $_[0]
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( debug_break_op_ast );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

