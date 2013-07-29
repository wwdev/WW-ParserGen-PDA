package WW::ParserGen::PDA::ASTBase;
use feature qw(:5.12);
use strict;

use Moose;

has node_type => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

sub quantifier { undef }

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 0 };

1;

