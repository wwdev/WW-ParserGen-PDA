package WW::ParserGen::PDA::EBNFParser;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::Parse::PDA::ParserBase';

sub _parse_ops_pkg { 'WW::ParserGen::PDA::GrammarOps' }

# returns ( $match_result, $error_message )
sub parse_ebnf {
    my ($self, $ident, $text, $trace_flags) = @_;
    return $self->_parse_text ($ident, 'rule_defs', \$text, $trace_flags);
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub parse_ebnf_rule_defs($$;$) {
    my ($ident, $text, $trace_flags) = @_;
    return __PACKAGE__->new->parse_ebnf ($ident, $text, $trace_flags);
}

use Exporter qw( import );

our @EXPORT_OK = qw ( parse_ebnf_rule_defs );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

