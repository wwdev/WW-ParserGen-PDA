package WW::ParserGen::PDA::AST::VarSetConst;
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

has value => (
    is          => 'ro',
    required    => 1,
);

has quantifier => (
    is          => 'ro',
);

sub set_quantifier {
    my ($self, $q) = @_;
    $self->{quantifier} = $q;
}

sub BUILDARGS {
    my ($self, @args) = @_;
    return { @args };
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

#sub var_set_const_ast {
#    return __PACKAGE__->new (
#        node_type => 'var_set_const', @_
#    );
#}

#use Exporter qw( import );

#our @EXPORT_OK = qw( var_set_const_ast );
#our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

