package WW::ParserGen::PDA::AST::ExprTree;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

sub quantifier { undef }

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 0 };

1;

