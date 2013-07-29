package WW::ParserGen::PDA::AST::InfixOpTable;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

# descending order
has operator_lengths => (
    is          => 'ro',
    isa         => 'ArrayRef',
    init_arg    => undef,
);

has operators => (
    is          => 'ro',
#    isa         => 'HashRef',
    required    => 1,
);

sub BUILD {
    my ($self, $args) = @_;

    if (ref (my $op_info_list = $self->operators) eq 'ARRAY') {
        my %operators;
        for (@$op_info_list) {
            $_->{word_mode} = 1 unless $_->{operator} =~ m/[^_a-zA-Z0-9]$/;
            $operators{$_->{operator}} =  $_;
        };
        $self->{operators} = \%operators;
    }

    my %op_lens = map { ( length ($_), 1 ) } keys %{$self->operators};
    $self->{operator_lengths} = [
        sort  { $b <=> $a } keys %op_lens
    ];
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 0 };

1;


