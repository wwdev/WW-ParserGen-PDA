package WW::ParserGen::PDA::AST::IfTest;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has var_refs => (
    is          => 'ro',
    isa         => 'ArrayRef',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

1;

