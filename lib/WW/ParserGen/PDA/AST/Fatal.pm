package WW::ParserGen::PDA::AST::Fatal;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has msg_params => (
    is          => 'ro',
    isa         => 'ArrayRef',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

1;

