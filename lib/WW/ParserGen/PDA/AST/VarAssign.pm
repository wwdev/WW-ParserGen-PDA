package WW::ParserGen::PDA::AST::VarAssign;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has dest_ref => (
    is          => 'ro',
    required    => 1,
);

has op => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has src_ref => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

#sub var_assign_ast($$$) {
#    return __PACKAGE__->new (
#        node_type => 'var_assign', dest_ref => $_[0],
#        op => $_[1], src_ref => $_[2],
#    );
#}

#use Exporter qw( import );

#our @EXPORT_OK = qw( var_assign_ast );
#our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

