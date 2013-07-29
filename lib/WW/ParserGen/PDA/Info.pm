package WW::ParserGen::PDA::Info;
use feature qw(:5.10);
use strict;

use WW::Parse::PDA::OpDefs qw ( :all );

use Moose;

has rule_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has rule_ast => (
    is          => 'ro',
    required    => 1,
);

has op_graph => (
    is          => 'ro',
);

has num_bt_slots => (
    is          => 'ro',
);

has graph_nodes => (
    is          => 'ro',
    isa         => 'ArrayRef',
    writer      => 'set_graph_nodes',
);

has op_list => (
    is          => 'ro',
    isa         => 'ArrayRef',
    writer      => 'set_op_list',
);

sub ops_as_list {
    my ($self) = @_;
    my $op_list = $self->op_list;
    return $op_list ? @$op_list : ();
}

no Moose;
__PACKAGE__->meta->make_immutable;

use Scalar::Util qw( blessed refaddr );

sub start_index {
    return $_->{op_list}->[0]->list_index;
}

sub _scan_ops {
    my ($self, $method, @args) = @_;
    my $op_list = $self->op_list;
    return unless $op_list;

    for (my $i=0; $i<@$op_list; $i++) {
        $self->$method ($i, $op_list, $op_list->[$i], @args);
    }
}

sub map_args_phase_1 {
    my ($self, $literal_map, $regex_map) = @_;

    my $node_map = $self->_graph_node_map;
    $self->_scan_ops (_map_args_1 => $node_map, $literal_map, $regex_map);
}

sub _map_args_1 {
    my ($self, $op_index, $op_list, $op, $node_map, $literal_map, $regex_map) = @_;
    my $op_def      = $op->op_def;
    my $args        = $op->args;
    my $arg_types   = $op_def->arg_types;

    my $arg_index   = -1;
    for (@$arg_types) {
        $arg_index++;
        when ('OpIndex') {
            my $graph_node = $args->[$arg_index];
            $args->[$arg_index] = $graph_node ?
                $node_map->{refaddr ($graph_node)} :
                $self->_do_die ($op_index, $arg_index, 'OpIndex map error, arg is undef');
            $self->_do_die (
                $op_index, $arg_index, " OpIndex map error, arg is a ", ref ($args->[$arg_index])
            ) unless blessed ($args->[$arg_index]) && $args->[$arg_index]->isa ('WW::ParserGen::PDA::Op');
        }
        when ('OpIndexMap') {
            my $match_map = $args->[$arg_index];
            while (my ($k, $v) = each %$match_map) {
                $v = $v ?  $node_map->{refaddr ($v)} :
                           $self->_do_die ($op_index, $arg_index, 'OpIndex map error, arg is undef');
                $self->_do_die (
                    $op_index, $arg_index, " OpIndex map error, arg is a ", ref ($v)
                ) unless blessed ($v) && $v->isa ('WW::ParserGen::PDA::Op');
                $match_map->{$k} = $v;
            }
        }
        when ('Str') {
            my $str = $args->[$arg_index];
            $self->_do_die ($op_index, $arg_index, 'undef or empty string') 
                unless defined ($str) && length ($str);
            my $idx = $literal_map->{$str};
            unless (defined $idx) {
                $idx = scalar (keys %$literal_map);
                $literal_map->{$str} = $idx;
            }
            $args->[$arg_index] = $idx;
        }
        when ('Regex') {
            my $regex = $args->[$arg_index];
            $self->_do_die ($op_index, $arg_index, 'undef or empty regex') 
                unless defined ($regex) && length ($regex);
            my $idx = $regex_map->{$regex};
            unless (defined $idx) {
                $idx = scalar (keys %$regex_map);
                $regex_map->{$regex} = $idx;
            }
            $args->[$arg_index] = $idx;
        }
    }
}

sub op_list_reduce {
    my ($self) = @_;
    # TODO -- it may be better to do this change in OpGraph::linearize_graph
    # change test_match into jump_ok/fail when one of the
    #       target ops is a successor
    # remove set_bt ops where there is no corresponding
    #       goto_bt (caused by fail branches being eliminated
    #       when unreachable)
    # change test_match into a jump where ok == fail
}

sub map_args_phase_2 {
    my ($self, $start_index, $rule_def_index_map) = @_;
    my $op_list = $self->op_list;
    $rule_def_index_map->{$self->rule_name} = $start_index;

    for (@$op_list) {
        $_->list_index ($start_index);
        $start_index += 1 + $_->op_def->num_args;
    }

    for (@$op_list) { $self->_map_args_2 ($_) }
    return $start_index;
}

sub _map_args_2 {
    my ($self, $op) = @_;
    my $arg_types = $op->op_def->arg_types;
    my $args = $op->args;
    my $i = -1;
    for (@$arg_types) {
        $i++;
        when ('OpIndex') {
            $args->[$i]->inc_ref_count;
            $args->[$i] = $args->[$i]->list_index;
        }
        when ('OpIndexMap') {
            my $map = $args->[$i];
            for (values %$map) {
                $_->inc_ref_count;
                $_ = $_->list_index;
            }
        }
    }
}

sub map_args_phase_3 {
    my ($self, $rule_def_index_map) = @_;
    for ($self->ops_as_list) { 
        $_->op_def->scan_args (
            $_->args,
            sub {
                my ($i, $args, $arg_type, $arg_name) = @_;
                if ($arg_type eq 'RuleIndex') {
                    $args->[$i] = $rule_def_index_map->{$args->[$i]};
                }
            }
        );
    }
}

sub _do_die {
    my ($self, $op_index, $arg_index, @text) = @_;
    my $op = $self->op_list->[$op_index];
    die $self->rule_name . ' ' . $op->op_def->op_type . 
        ' [' . $op_index . '] arg[' . $arg_index . ']: ' .
        join ('', @text);
}

sub _graph_node_map {
    my ($self) = @_;
    my %node_map;
    for (@{$self->op_list}) {
        my $graph_node = $_->graph_node;
        $node_map{refaddr ($graph_node)} = $_
            if $graph_node;
    }
    return \%node_map;
}

sub to_string {
    my ($self, $indent) = @_;
    $indent ||= '';
    my $text = "PDA<" . $self->rule_name . '/' . sprintf('%08X', refaddr ($self)) . ">\n";
    if (my $op_garph = $self->op_graph) {
        $text .= '  ' . $self->op_graph->op_tree_to_string ({}, '  ');
    }
    return $text . "\nop_list:\n" . $self->op_list_to_string ('  ')
}

sub op_list_to_string {
    my ($self, $indent) = @_;
    $indent ||= '';
    my $op_list = $self->op_list;
    return '<empty>' unless $op_list && @$op_list;

    my $text = '';
    for (my $i=0; $i<@$op_list; $i++) {
        $text .= sprintf ('%3d: ', $i) . 
                 $op_list->[$i]->to_string ('     ' . $indent) . "\n";
    }
    return $text;
}

1;

