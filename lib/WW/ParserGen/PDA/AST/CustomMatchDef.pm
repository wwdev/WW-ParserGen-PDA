package WW::ParserGen::PDA::AST::CustomMatchDef;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has match_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has arg_names => (
    is          => 'ro',
    isa         => 'ArrayRef',
);

has code => (
    is          => 'ro',
    isa         => 'Str',
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;

