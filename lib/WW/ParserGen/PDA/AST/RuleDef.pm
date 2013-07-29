package WW::ParserGen::PDA::AST::RuleDef;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has rule_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has node_pkg => (
    is          => 'ro',
#    isa         => 'Str',
    writer      => 'set_node_pkg',
);

has rule_vars => (
    is          => 'ro',
#    isa         => 'ArrayRef',
);

has match => (
    is          => 'ro',
    isa         => 'Object',
    required    => 1,
    writer      => 'set_match',
);


no Moose;
__PACKAGE__->meta->make_immutable;

#sub rule_def_ast {
#    return __PACKAGE__->new (
#        node_type => 'rule_def', @_
#    );
#}

#use Exporter qw( import );
#our @EXPORT_OK = qw( rule_def_ast );
#our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

