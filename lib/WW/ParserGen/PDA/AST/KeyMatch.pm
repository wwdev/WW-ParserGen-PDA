package WW::ParserGen::PDA::AST::KeyMatch;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has key_lengths => (
    is          => 'ro',
    isa         => 'ArrayRef',
    init_arg    => undef,
);

has match_map => (
    is          => 'ro',
    isa         => 'HashRef',
);

has quantifier => (
    is          => 'ro',
    writer      => 'set_quantifier',
);

sub BUILD {
    my ($self, $args) = @_;
    if (ref (my $match_list = $args->{key_match_list})) {
        my %match_map;
        for (my $i=0; $i<@$match_list; $i+=2) {
            my ($key, $match) = @$match_list[$i,$i+1];
            die ("duplicate match_key $key") if $match_map{$key};
            $match_map{$key} = $match;
        }
        $self->{match_map} = \%match_map;
    }
    elsif (ref ($self->match_map) ne 'HASH') {
        die "match_map must be a hash";
    }

    my $match_map = $self->match_map;
    my %key_lens = map { ( length ($_), 1) } keys %$match_map;
    $self->{key_lengths} = [ sort { $b <=> $a } keys %key_lens ];
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 
    my ($self) = @_;
    return scalar (@{ $self->match_list });
}

1;

