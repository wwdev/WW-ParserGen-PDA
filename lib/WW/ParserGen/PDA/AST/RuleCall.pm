package WW::ParserGen::PDA::AST::RuleCall;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has rule_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has reg_numbers => (
    is          => 'ro',
    isa         => 'ArrayRef',
);

has quantifier => (
    is          => 'ro',
    writer      => 'set_quantifier',
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

1;

