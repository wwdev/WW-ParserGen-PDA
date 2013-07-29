package WW::ParserGen::PDA::OpGraph::RuleStartNode;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::OpGraph::Node';

has rule_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has rule_vars => (
    is          => 'ro',
    isa         => 'ArrayRef',
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub needs_2_out_nodes { 1 }
sub needs_defined_out_nodes { 1 }
sub needs_identical_out_nodes { 1 }

sub to_string_short {
    my ($self, $indent) = @_;
    return $self->SUPER::to_string_short ($indent) .
#        ' RuleDef: ' . $self->rule_name .
        ($self->rule_vars ? ' { ' . join (' ', @{$self->rule_vars}) . ' }' : '');
}

sub rule_start_node($$$) {
    my ($rule_name, $rule_vars, $match) = @_;
    return __PACKAGE__->new (
        node_type   => 'rule_start',
        rule_name   => $rule_name,
        ($rule_vars ? ( rule_vars => $rule_vars ) : ( )),
        out_nodes   => [ $match, $match ],
    );
}

use Exporter qw( import );

our @EXPORT_OK = qw( rule_start_node );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

