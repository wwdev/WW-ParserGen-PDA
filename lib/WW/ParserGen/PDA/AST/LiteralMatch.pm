package WW::ParserGen::PDA::AST::LiteralMatch;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has match_text => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has quantifier => (
    is          => 'ro',
    writer      => 'set_quantifier',
);

has case_insensisitve => (
    is          => 'ro',
);

sub BUILD {
    my ($self, $args) = @_;
    if (defined (my $code_point = $args->{code_point})) {
        $self->{match_text} = chr (hex ($code_point));
    }
}

sub make_case_insensitive {
    $_[0] = 1;
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

sub needs_grouping { undef }

#sub literal_match_ast {
#    return __PACKAGE__->new (
#        node_type => 'literal_match', @_
#    );
#}

#use Exporter qw( import );

#our @EXPORT_OK = qw( literal_match_ast );
#our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

