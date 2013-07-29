package WW::ParserGen::PDA::AST::Fail;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

#sub fail_ast {
#    return __PACKAGE__->new (node_type => 'fail');
#}

#use Exporter qw( import );

#our @EXPORT_OK = qw( fail_ast );
#our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

