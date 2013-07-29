package WW::ParserGen::PDA::AST::CustomMatch;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has match_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has match_args => (
    is          => 'ro',
    isa         => 'ArrayRef',
);

has quantifier => (
    is          => 'ro',
    writer      => 'set_quantifier',
);

sub BUILD {
    my ($self, $args) = @_;
    my @args;
    if (my $match_args = $self->match_args) {
        @args = grep { ref ($_) } @$match_args;
    }
    $self->{match_args} = @args ? \@args : undef
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

1;

