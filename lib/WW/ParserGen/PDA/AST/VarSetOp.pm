package WW::ParserGen::PDA::AST::VarSetOp;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has var_ref => (
    is          => 'ro',
    required    => 1,
);

has op => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has match => (
    is          => 'ro',
    isa         => 'Object',
    required    => 1,
);

has quantifier => (
    is          => 'ro',
);

sub set_quantifier {
    my ($self, $q) = @_;
#    die ("var_set_op only allows ? quantifier, not $q")
#        if $q && $q ne '?';
    $self->{quantifier} = $q;
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size {
    return 1 + $_[0]->match->_inline_size;
}

#sub var_set_op_ast {
#    return __PACKAGE__->new (
#        node_type => 'var_set_op', @_
#    );
#}

#use Exporter qw( import );

#our @EXPORT_OK = qw( var_set_op_ast );
#our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

