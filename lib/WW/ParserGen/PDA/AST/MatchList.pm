package WW::ParserGen::PDA::AST::MatchList;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has match_list => (
    is          => 'ro',
    isa         => 'ArrayRef',
    required    => 1,
);

has quantifier => (
    is          => 'ro',
    writer      => 'set_quantifier',
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 
    my ($self) = @_;
    return scalar (@{ $self->match_list });
}

sub needs_grouping {
    my ($self) = @_;
    return 1 < @{ $self->match_list };
}

1;

