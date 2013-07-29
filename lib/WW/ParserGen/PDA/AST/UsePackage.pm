package WW::ParserGen::PDA::AST::UsePackage;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has fq_package => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has use_args => (
    is          => 'ro',
#    isa         => 'ArrayRef',
);

no Moose;
__PACKAGE__->meta->make_immutable;

#sub use_package_ast {
#    return __PACKAGE__->new (
#        node_type => 'use_package', @_
#    );
#}

#use Exporter qw( import );

#our @EXPORT_OK = qw( use_package_ast );
#our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

