package WW::ParserGen::PDA::AST::RuleMatch;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has rule_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has quantifier => (
    is          => 'ro',
    writer      => 'set_quantifier',
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

#sub rule_match_ast {
#    return __PACKAGE__->new (
#        node_type => 'rule_match', @_
#    );
#}

#use Exporter qw( import );

#our @EXPORT_OK = qw( rule_match_ast );
#our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

