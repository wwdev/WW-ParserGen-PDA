package WWTest::ParserGen::ASTPkg;
use feature qw(:5.12);
use strict 1;

use Moose;

has a => (
    is          => 'ro',
    isa         => 'Str',
);

has b => (
    is          => 'ro',
    isa         => 'Int',
);

no Moose;
__PACKAGE__->meta->make_immutable;

1;

