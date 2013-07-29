package WW::ParserGen::PDA::AST::TraceFlags;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has trace_flags => (
    is          => 'ro',
    isa         => 'Int',
    required    => 1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

#sub trace_flags_ast($) {
#    return __PACKAGE__->new (
#        node_type => 'trace_flags', trace_flags => $_[0]
#    );
#}

#use Exporter qw( import );

#our @EXPORT_OK = qw( trace_flags_ast );
#our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

