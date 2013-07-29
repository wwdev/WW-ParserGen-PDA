package WW::ParserGen::PDA::OpGraph;
use feature qw(:5.12);
use strict;

use Scalar::Util qw( refaddr );

use WW::ParserGen::PDA::OpGraph::DebugBreakOpNode qw( :all );
use WW::ParserGen::PDA::OpGraph::TraceFlagsNode qw( :all );
use WW::ParserGen::PDA::OpGraph::FailNode qw( :all );
use WW::ParserGen::PDA::OpGraph::FatalNode qw( :all );
use WW::ParserGen::PDA::OpGraph::LiteralMatchNode qw( :all );
use WW::ParserGen::PDA::OpGraph::RegexMatchNode qw( :all );
use WW::ParserGen::PDA::OpGraph::TokenMatchNode qw( :all );
use WW::ParserGen::PDA::OpGraph::RuleMatchNode qw( :all );
use WW::ParserGen::PDA::OpGraph::RuleCallNode qw( :all );
use WW::ParserGen::PDA::OpGraph::CustomMatchNode qw( :all );
use WW::ParserGen::PDA::OpGraph::ExprOpNode qw( :all );
use WW::ParserGen::PDA::OpGraph::ExprOpRightArgNode qw( :all );
use WW::ParserGen::PDA::OpGraph::ExprTreeNode qw( :all );
use WW::ParserGen::PDA::OpGraph::KeyMatchNode qw( :all );
use WW::ParserGen::PDA::OpGraph::RuleStartNode qw( :all );
use WW::ParserGen::PDA::OpGraph::PkgReturnNode qw( :all );
use WW::ParserGen::PDA::OpGraph::HashReturnNode qw( :all );
use WW::ParserGen::PDA::OpGraph::OKReturnNode qw( :all );
use WW::ParserGen::PDA::OpGraph::FailReturnNode qw( :all );
use WW::ParserGen::PDA::OpGraph::BackTrackNode qw( :all );
use WW::ParserGen::PDA::OpGraph::IterSlotOpNode qw( :all );
use WW::ParserGen::PDA::OpGraph::VarSetConstNode qw( :all );
use WW::ParserGen::PDA::OpGraph::VarSetOpNode qw( :all );
use WW::ParserGen::PDA::OpGraph::VarMoveNode qw( :all );
use WW::ParserGen::PDA::OpGraph::TestMatchNode qw( :all );
use WW::ParserGen::PDA::OpGraph::NotMatchNode qw( :all );
use WW::ParserGen::PDA::OpGraph::IfTestNode qw( :all );
use WW::ParserGen::PDA::OpGraph::JumpNode qw( :all );
use WW::ParserGen::PDA::OpGraph::NOPNode qw( :all );
use WW::ParserGen::PDA::OpGraph::SlotAllocs qw( _SlotAllocs );

use Moose;

has [qw( rule_def_asts token_def_asts )] => (
    is          => 'ro',
    isa         => 'HashRef',
    required    => 1,
);

has max_inlineable_size => (
    is          => 'rw',
    isa         => 'Int',
    default     => 7,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub make_ast_graph {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;

    my $q = $ast_node->quantifier || '';
    my $node_type = $ast_node->node_type;
    # NOTE: depending on $fail_node really doing a backtrack to reset the parse
    #       postition (since a match of the negation will advance the position).
    $ok_node = $fail_node = not_match_node ($ok_node, $fail_node)
        if $q eq '!';

    my $make_method = '_make_' . $node_type;
    return $self->$make_method (
        $slot_allocs, $topo_seq_index, 
        ($q eq '!' ? undef : $set_match),
        $ok_node, 
        ($q eq '?' ? $ok_node : $fail_node), 
        $ast_node,
    ) if !$q || $q eq '?' || $q eq '!';

    # special case for iteration of sequences -- the sequence being iterated
    # over does not need to maintain it's own backtracking info
    $make_method .= '_iter' if $node_type eq 'sequence_match';

    # NOTE: must pass in the alreadey resolved make_method for the ast node
    # so we don't recurse back here to make the node being iterated over
    my $loop_method = $q eq '*' ? '_make_zero_or_more' : '_make_one_or_more';
    return $self->$loop_method (
        $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node,
        $make_method, $ast_node,
    );
}

sub replace_node {
    my ($self, $old_node, $new_node, $edge_set, @nodes) = @_;
    for my $src_node (@nodes) {
        my $out_nodes = $src_node->out_nodes;
        next unless $out_nodes;
        for (@$out_nodes) {
            $_ = $new_node if $_ == $old_node;
        }       
    }
}

sub linearize_graph {
    my ($self, $start_node) = @_;
    my @topo_list = ( $start_node, $start_node->reachable_out_nodes );
    my @final_list;


    for (my $i=0; $i<@topo_list; $i++) {
        my $curr_node = $topo_list[$i];
        my $next_node = $topo_list[$i+1];

        # falls through to the next node
        if ($next_node && $curr_node->is_uncond_jump_to ($next_node)) {
            if ($curr_node->is_nop_on_fall_through) {
                $self->replace_node ($curr_node, $next_node, @topo_list);
            }
            else {
                push @final_list, $curr_node;
            }
            next;
        }

        # jumping forward or backward
        if ($curr_node->is_uncond_jump) {
            push @final_list, $curr_node;
            if ($curr_node->is_sequential_node) {
                my $next_node = 
                    $curr_node->ok_node->node_type =~ m/^(pkg|hash|ok|fail)_return$/ ?
                        $curr_node->ok_node->clone :
                        jump_node ($curr_node->ok_node);
                $curr_node->ok_node ($next_node);
                $curr_node->fail_node ($next_node);
                push @final_list, $next_node;
            }
            next;
        }

        # 2 way branch
        if ($curr_node->is_terminal_node) {
            push @final_list, $curr_node;
            next;
        }

        # graph linkage error -- sequential node with 2 destinations
        die "sequential node linkage error in rule " .
            $start_node->rule_name . ': ' .
            $curr_node->to_string_short;
    }

    return @final_list;
}

sub _make_rule_def {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    $ok_node = $ast_node->node_pkg  ? pkg_return_node ($ast_node->node_pkg) :
               $ast_node->rule_vars ? hash_return_node :
                                      ok_return_node;

    return rule_start_node (
        $ast_node->rule_name,
        $ast_node->rule_vars,
        $self->make_ast_graph (
            $slot_allocs, 0, undef, $ok_node, fail_return_node, 
            $ast_node->match
        )
    );
}

sub _make_debug_break_op {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return debug_break_op_node ($ast_node->message, $ok_node);
}

sub _make_trace_flags {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return trace_flags_node ($ast_node->trace_flags, $ok_node);
}

sub _make_fail {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return fail_node ($fail_node);
}
sub _make_fatal {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return fatal_node ($ast_node->msg_params);
}

sub _make_first_match {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    $fail_node = match_set_node ('=', undef, $fail_node) if $set_match;
    for (reverse @{$ast_node->match_list}) {
        $fail_node = $self->make_ast_graph ($slot_allocs, 1, $set_match, $ok_node, $fail_node, $_);
    }
    return $fail_node;
}

sub _make_literal_match {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    my $test_match = test_match_node ($ok_node, $fail_node);

    return literal_match_node (
        topo_sequence_index => $topo_seq_index,
        set_match           => $set_match,
        out_nodes           => [ $test_match, $test_match ],
        match_text          => $ast_node->match_text,
    );
}

sub _make_regex_match {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    my $test_match = test_match_node ($ok_node, $fail_node);
    return regex_match_node (
        topo_sequence_index => $topo_seq_index,
        set_match           => $set_match,
        out_nodes           => [ $test_match, $test_match ],
        delimiter           => $ast_node->delimiter,
        regex               => $ast_node->regex,
    );
}

sub _make_token_match {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    my $test_match = test_match_node ($ok_node, $fail_node);
    return token_match_node (
        topo_sequence_index => $topo_seq_index,
        set_match           => $set_match,
        out_nodes           => [ $test_match, $test_match ],
        token_name          => $ast_node->rule_name,
    );
}

sub _make_rule_match {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return _make_token_match (@_) 
        if $self->token_def_asts->{$ast_node->rule_name};
    die ("no rule or token named " . $ast_node->rule_name . " found\n")
        unless $self->rule_def_asts->{$ast_node->rule_name};
    return rule_match_node (
        $ast_node->rule_name,
        $topo_seq_index, $set_match, $ok_node, $fail_node,
    );
}

sub _make_rule_call {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    die ("no rule named " . $ast_node->rule_name . " found\n")
        unless $self->rule_def_asts->{$ast_node->rule_name};
    return rule_call_node (
        $ast_node->rule_name, $ast_node->reg_numbers,
        $topo_seq_index, $set_match, $ok_node, $fail_node,
    );
}
sub _make_custom_match {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return custom_match_node (
        $ast_node->match_name, $ast_node->match_args,
        test_match_node ($ok_node, $fail_node),
    );
}

sub _make_expr_op {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    my $test_match = test_match_node ($ok_node, $fail_node);

    return expr_op_node (
        topo_sequence_index => $topo_seq_index,
        set_match           => $set_match,
        out_nodes           => [ $test_match, $test_match ],
        op_table_name       => $ast_node->op_table_name,
    );
}

sub _make_expr_op_right_arg {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return expr_op_right_arg_node (
        topo_sequence_index => $topo_seq_index,
        set_match           => $set_match,
        out_nodes           => [ $ok_node, $ok_node ],
    );
}

sub _make_expr_tree {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return expr_tree_node (
        topo_sequence_index => $topo_seq_index,
        set_match           => $set_match,
        out_nodes           => [ $ok_node, $ok_node ],
    );
}

sub _make_key_match {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    # link each key's match to our ok/fail
    my $ast_match_map = $ast_node->match_map;
    my %match_map;
    while (my ($key, $match_ast) = each (%$ast_match_map)) {
        $match_map{$key} = $self->make_ast_graph (
            $slot_allocs, 0, $set_match, $ok_node, $fail_node, $match_ast
        );
    }
    return key_match_node (
        $topo_seq_index, $set_match, $ast_node->key_lengths, \%match_map, $fail_node
    );
}

our $_SEQ_NO = 0;
sub _make_sequence_match {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    my @match_list = @{$ast_node->match_list};
    die ("no ast nodes in sequence") unless @match_list;
    return $self->make_ast_graph (
        $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $match_list[0]
    ) if 1 == @match_list;

    # allocate the backtrack slot
    my $bt_slot = $slot_allocs->alloc_bt_slot;
    my $seq_no = $_SEQ_NO++;
    my $bt_exit = goto_bt_node ($bt_slot, $fail_node, 'FAIL SEQ #' . $seq_no);

    my $exit_index = 0; # start with the last match
    while (@match_list) {
        my $match_ast = pop @match_list;
        $ok_node = $self->make_ast_graph (
            $slot_allocs, $topo_seq_index, $set_match,
            $ok_node, (@match_list ? $bt_exit : $fail_node), $match_ast
        );
    }

#    $slot_allocs->free_bt_slot;
    return set_bt_node ($bt_slot, $ok_node, 'START SEQ #' . $seq_no);
}

sub _make_sequence_match_iter {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    my @match_list = @{$ast_node->match_list};
    die ("no ast nodes in sequence") unless @match_list;
    return $self->make_ast_graph (
        $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $match_list[0]
    ) if 1 == @match_list;

    while (my $match_ast = pop @match_list) {
        $ok_node = $self->make_ast_graph (
            $slot_allocs, $topo_seq_index, undef, $ok_node, $fail_node, $match_ast
        );
    }
    return $ok_node;
}

sub _make_test_match {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return test_match_node ($ok_node, $fail_node);
}

sub _make_not_match {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return not_match_node ($ok_node, $fail_node);
}

sub _make_if_true {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return if_test_node ($ast_node->var_refs, $ok_node, $fail_node);
}

# just reversing the ok/fail nodes works because the if_test op
# only changes match_status (leaves match_value_alone)
sub _make_if_false {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return if_test_node ($ast_node->var_refs, $fail_node, $ok_node);
}

sub _make_jump {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    die ("ok and fail nodes not the same") unless $ok_node == $fail_node;
    return jump_node ($ok_node);
}

sub _make_var_set_const {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return var_set_const_node (
        $ast_node->var_ref, $ast_node->op, $ast_node->value, $ok_node
    );
}

sub _make_var_assign {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;
    return var_move_node (
        $ast_node->dest_ref, $ast_node->op, $ast_node->src_ref, $ok_node
    );
}

sub _make_var_set_op {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $ast_node) = @_;

    # drop redundant assignment op
    return $self->make_ast_graph (
        $slot_allocs, $topo_seq_index, 1, $ok_node, $fail_node, $ast_node->match
    ) if $ast_node->var_ref eq '*match_value*' && $ast_node->op eq '=';

    return $self->make_ast_graph (
        $slot_allocs, $topo_seq_index, 1, 
        var_set_op_node ($ast_node->var_ref, $ast_node->op, $ok_node), $fail_node,
        $ast_node->match
    );
}

sub _make_zero_or_more {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $make_method, $ast_node) = @_;
    my $bt_slot = $slot_allocs->alloc_bt_slot;

    my $start_node = set_bt_node ($bt_slot, undef);
    my $end_node = goto_bt_node ($bt_slot, $ok_node);
    $start_node->ok_node (
        $start_node->fail_node (
            $self->$make_method (
                $slot_allocs, $topo_seq_index, $set_match, $start_node, 
                $end_node, $ast_node
            )
        )
    );

#    $slot_allocs->free_bt_slot;
    return $start_node;
}

sub _make_one_or_more {
    my ($self, $slot_allocs, $topo_seq_index, $set_match, $ok_node, $fail_node, $make_method, $ast_node) = @_;
    my $bt_slot = $slot_allocs->alloc_bt_slot;
    my $iter_slot = $slot_allocs->alloc_bt_slot;

    my $loop_head_node    = set_bt_node ($bt_slot, undef);
    my $start_node        = set_iter_slot_node ($iter_slot, 0, $loop_head_node);
    my $loop_repeat_node  = add_iter_slot_node ($iter_slot, 1, $loop_head_node);
    $loop_head_node->ok_node (
        $loop_head_node->fail_node (
            $self->$make_method (
                $slot_allocs, $topo_seq_index, $set_match, $loop_repeat_node,
                goto_bt_node ($bt_slot, cmpgt_iter_slot_node ($iter_slot, 0, $ok_node, $fail_node)), 
                $ast_node
            )
        )
    );

#    $slot_allocs->free_bt_slot;
#    $slot_allocs->free_bt_slot;
    return $start_node;
}

1;

