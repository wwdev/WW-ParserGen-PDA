package WW::ParserGen::PDA::Generator;
use feature qw(:5.12);
use strict 1;

our $VERSION = '0.12.1';

use Scalar::Util qw( blessed refaddr );
use WW::ParserGen::PDA::OpGraph;
use WW::ParserGen::PDA::Info;
use WW::ParserGen::PDA::Op qw( :all );
use WW::ParserGen::PDA::OpGraph::SlotAllocs qw( _SlotAllocs );
use WW::Parse::PDA::VarSetOps qw( :all );
use WW::Parse::PDA::OpDefs qw( :all );

use Moose;

has rule_defs_ast => (
    is          => 'ro',
);

has rule_def_pdas => (
    is          => 'ro',
);

has op_defs => (
    is          => 'ro',
    isa         => 'HashRef',
);

has [qw( literal_map regex_map token_map rule_def_index_map )] => (
    is          => 'rw',
    isa         => 'HashRef',
);

sub BUILD {
    my ($self, $args) = @_;
    $self->{op_defs} = { map { ( $_->op_type, $_ ) } @{get_op_defs ()} };
    $self->token_map ({});
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub rule_def_pdas_list {
    my ($self) = @_;
    my $rule_def_pdas = $self->rule_def_pdas;
    return map { $rule_def_pdas->{$_} } sort (keys (%$rule_def_pdas));
}

# top-level entry point
sub generate_for_rule_defs {
    my ($self, $rule_defs_ast) = @_;
    $self->_set_rule_defs_ast ($rule_defs_ast);
    $self->_init_pdas;

    my $op_index            = 0;
    my $literal_map         = $self->literal_map ({});
    my $regex_map           = $self->regex_map ({});
    my $rule_def_index_map  = $self->rule_def_index_map ({});
    for ($self->rule_def_pdas_list) {
        $_->map_args_phase_1 ($literal_map, $regex_map);
        $_->op_list_reduce;
        $op_index = $_->map_args_phase_2 ($op_index, $rule_def_index_map);
    }
    for ($self->rule_def_pdas_list) {
        $_->map_args_phase_3 ($rule_def_index_map);
    }
}

sub _set_rule_defs_ast {
    my ($self, $rule_defs_ast) = @_;
    die (
        "rule_defs is a " . ref ($rule_defs_ast) .
        " not a WW::ParserGen::PDA::AST::RuleDefs"
    ) unless blessed ($rule_defs_ast) && $rule_defs_ast->isa ('WW::ParserGen::PDA::AST::RuleDefs');
    $self->{rule_defs_ast} = $rule_defs_ast;

    if (my $custom_matches = $rule_defs_ast->custom_match_list) {
        for (@$custom_matches) {
            die ("redefining parse engine op " . $_->match_name . " as custom op")
                if $self->op_defs->{$_->match_name};
            $self->op_defs->{$_->match_name} = WW::Parse::PDA::OpDef->new (
                op_type      => $_->match_name,
                is_custom_op => 1,
                op_func      => undef,
                arg_names    => [ 'match_args' ],
                arg_types    => [ 'HashRef' ],
                trace_flags  => $self->_get_op_def ('custom_match')->trace_flags,
            );
        }
    }
    if (my $token_defs = $rule_defs_ast->token_defs) {
        die (ref ($token_defs) . ': token_defs must be a HASH')
            unless ref ($token_defs) eq 'HASH';
        $self->{token_map} = $token_defs;
        for (sort (keys (%$token_defs))) {
            my $token_op_name = "token_$_";
            die ("token name $_ conflicts with op_def $token_op_name")
                if $self->op_defs->{$token_op_name};
            die ("token name $_ conflicts with rule def $_")
                if $self->rule_defs_ast->rule_defs->{$_};
        }
    }
}

sub _init_pdas {
    my ($self) = @_;
    my %rule_def_pdas;
    my $op_graph_util = WW::ParserGen::PDA::OpGraph->new (
        rule_def_asts   => $self->rule_defs_ast->rule_defs,
        token_def_asts  => $self->rule_defs_ast->token_defs,
    );

    for (values (%{$self->rule_defs_ast->rule_defs})) {
        my $rule_name   = $_->rule_name;
        my $slot_allocs = _SlotAllocs->new;
        my $op_graph    = $op_graph_util->make_ast_graph (
            $slot_allocs, 0, undef, undef, undef, $_
        );
        my $pda_info    = $rule_def_pdas{$rule_name} = WW::ParserGen::PDA::Info->new (
            rule_name       => $rule_name,
            rule_ast        => $_,
            op_graph        => $op_graph,
            num_bt_slots    => 1 + $slot_allocs->max_bt_slot,
        );
        $pda_info->set_op_list ($self->_make_op_list ($pda_info, $pda_info->op_graph, $op_graph_util));
    }

    $self->{rule_def_pdas} = \%rule_def_pdas;
}

sub _make_op_list {
    my ($self, $pda_info, $op_graph, $op_graph_util) = @_;
    $op_graph->check;
    my $graph_nodes = $pda_info->set_graph_nodes ([ 
        $op_graph_util->linearize_graph ($op_graph)
    ]);

    my @op_list;
    for (@$graph_nodes) {
        $_->check;
        if ($_->node_type =~ 'rule_(?:match|call)') {
            die ("rule " . $_->rule_name . ' not defined')
                unless $self->rule_defs_ast->rule_defs->{$_->rule_name} ||
                       $self->token_map->{$_->rule_name};
        }
        my $op_def = $self->_get_op_def ($_->node_type);
        my $op_method = '_make_op_' . $_->node_type;
        push @op_list, $self->$op_method ($pda_info, $op_def, $_);
    }
    return \@op_list;
}

sub _make_op_debug_break_op {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op ($graph_node, $op_def, $graph_node->message);
}

sub _make_op_trace_flags {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op ($graph_node, $op_def, $graph_node->trace_flags);
}

sub _make_op_fail {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op ($graph_node, $op_def);
}

sub _make_op_fatal {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op ($graph_node, $op_def, $graph_node->msg_params);
}

sub _make_op_rule_start {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return (
        pda_op (
            $graph_node, $op_def, $graph_node->rule_name, $pda_info->num_bt_slots
        ),
        ($graph_node->rule_vars && @{$graph_node->rule_vars} ? (
            pda_op (
                undef, $self->_get_op_def ('set_rule_vars'),
                { map  { ( $_, undef ) } @{$graph_node->rule_vars} },
            ),
        ) : ( )),
    );
}

sub _make_op_pkg_return {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op ($graph_node, $op_def, $graph_node->node_pkg);
}

sub _make_op_hash_return {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op ($graph_node, $op_def);
}

sub _make_op_ok_return {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op ($graph_node, $op_def);
}

sub _make_op_fail_return {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op ($graph_node, $op_def);
}

sub _make_op_jump {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op ($graph_node, $op_def, $graph_node->ok_node);
}

sub _make_op_literal_match {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, 
        ($graph_node->set_match ? $op_def : $self->_get_op_def ('literal_test')), 
        $graph_node->match_text
    );
}

sub _make_op_regex_match {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        'm' . $graph_node->delimiter . '\\G' .
            ($graph_node->set_match ? '(' : '') .
            $graph_node->regex . 
            ($graph_node->set_match ? ')' : '') .
            $graph_node->delimiter . 'gc'
    );
}

sub _make_op_token_match {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $self->_get_op_def ('token_match'),
        $graph_node->set_match ? 1 : 0,
    );
}

sub _make_op_rule_match {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node,
        ($graph_node->set_match ? $op_def : $self->_get_op_def ('rule_test')),
        $graph_node->rule_name, $graph_node->ok_node, $graph_node->fail_node,
    );
}

sub _make_op_rule_call {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node,
        ($graph_node->set_match ? $op_def : $self->_get_op_def ('rule_call_test')),
        $graph_node->rule_name, $graph_node->ok_node, $graph_node->fail_node,
        $graph_node->reg_numbers
    );
}

sub _make_op_custom_match {
    my ($self, $pda_info, $op_def, $graph_node) = @_;

    my $defined_op = $self->op_defs->{$graph_node->match_name};
    die ("custom match ". $graph_node->match_name . " not defined\n")
        unless $defined_op;
    die (
        "Calling parse engine op " . $graph_node->match_name .
            " as a custom match op\n"
    ) unless $defined_op->is_custom_op;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->match_args,
    );
}

sub _make_op_expr_op {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    die ('no infix operator table defined with name ' . $graph_node->op_table_name . "\n")
        unless $self->rule_defs_ast->infix_op_tables->{$graph_node->op_table_name};
    return pda_op (
        $graph_node, $op_def,
        $graph_node->op_table_name
    );
}

sub _make_op_expr_op_right_arg {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
    );
}

sub _make_op_expr_tree {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
    );
}

sub _make_op_key_match {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->key_lengths, $graph_node->match_map, $graph_node->fail_node
    );
}

sub _make_op_test_match {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->ok_node, $graph_node->fail_node,
    );
}

sub _make_op_not_match {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->ok_node, $graph_node->fail_node,
    );
}

sub _make_op_if_test {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->ok_node, $graph_node->fail_node,
        $graph_node->var_refs,
    );
}

sub _make_op_var_set_const {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->var_name,
        var_set_op_from_str ($graph_node->op),
        $graph_node->value,
    );
}

sub _make_op_var_move {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->dest_name,
        var_set_op_from_str ($graph_node->op),
        $graph_node->src_name,
    );
}

sub _make_op_var_set_op {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->var_name, 
        var_set_op_from_str ($graph_node->op),
    );
}

sub _make_op_set_bt {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op_w_comment (
        $graph_node, $op_def, $graph_node->op_comment,
        $graph_node->bt_slot_index,
    );
}

sub _make_op_goto_bt {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op_w_comment (
        $graph_node, $op_def, $graph_node->op_comment,
        $graph_node->bt_slot_index,
    );
}

sub _make_op_set_iter_slot {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->iter_slot_index, $graph_node->value,
    );
}

sub _make_op_add_iter_slot {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->iter_slot_index, $graph_node->value,
    );
}

sub _make_op_gt_iter_slot {
    my ($self, $pda_info, $op_def, $graph_node) = @_;
    return pda_op (
        $graph_node, $op_def,
        $graph_node->iter_slot_index, $graph_node->value,
        $graph_node->ok_node, $graph_node->fail_node,
    );
}

sub _get_op_def {
    my ($self, $graph_node_type) = @_;
    my $op_def = $self->op_defs->{$graph_node_type};
    return $op_def if $op_def;

    require Carp;
    Carp::confess (
        "no op def for graph node type '", $graph_node_type, "'"
    );
}

sub pda_op_generator {
    return __PACKAGE__->new;
}

use Exporter qw( import );

our @EXPORT_OK = qw( pda_op_generator );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

