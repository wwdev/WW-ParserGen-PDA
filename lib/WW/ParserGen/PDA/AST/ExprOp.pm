package WW::ParserGen::PDA::AST::ExprOp;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has op_table_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

sub quantifier { undef }

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 0 };

1;

