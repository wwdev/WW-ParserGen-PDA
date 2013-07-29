package WW::ParserGen::PDA::AST::ConstValue;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has value_type => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has value => (
    is          => 'ro',
);

no Moose;
__PACKAGE__->meta->make_immutable;

##sub const_value_ast {
##    return __PACKAGE__->new (
##        node_type => 'const_value', @_
##    );
##}
##
##use Exporter qw( import );
##
##our @EXPORT_OK = qw( const_value_ast );
##our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

