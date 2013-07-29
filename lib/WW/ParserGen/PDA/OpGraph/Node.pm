package WW::ParserGen::PDA::OpGraph::Node;
use feature qw(:5.12);
use strict;

use Moose;

has node_type => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    writer      => 'set_node_type',
);

has topo_sequence_index => (
    is          => 'rw',
    isa         => 'Int',
    default     => 0,
);

has set_match => (
    is          => 'ro',
    isa         => 'Bool',
    writer      => 'set_match_attr',
);

has out_nodes => (
    is          => 'ro',
    isa         => 'ArrayRef',
);

has op_comment => (
    is          => 'ro',
    isa         => 'Str',
);

sub ok_node {
    my $self = shift @_;
    return $self->out_nodes->[0] unless @_;
    return $self->out_nodes->[0] = $_[0];
}

sub fail_node {
    my $self = shift @_;
    return $self->out_nodes->[1] unless @_;
    return $self->out_nodes->[1] = $_[0];
}

sub replace_out_node {
    my ($self, $old_node, $new_node) = @_;
    my $out_nodes = $self->out_nodes;
    if ($out_nodes) {
        for (@$out_nodes) {
            $_ = $new_node if $_ == $old_node;
        }
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub is_sequential_node { 1 }
sub is_terminal_node { undef }
sub is_nop_on_fall_through { undef }

sub is_uncond_jump {
    my ($self) = @_;
    my $out_nodes = $self->out_nodes;
    return $out_nodes && $out_nodes->[0] == $out_nodes->[1] &&
           $out_nodes->[0];
}

sub is_uncond_jump_to {
    my ($self, $dest) = @_;
    my $out_nodes = $self->out_nodes;
    return $out_nodes && $out_nodes->[0] == $out_nodes->[1] &&
           $out_nodes->[0] == $dest;
}

use Scalar::Util qw( refaddr );

sub topo_out_nodes {
    my ($self) = @_;
    my @list;
    if (my $out_nodes = $self->out_nodes) {
        my $topo_index = $self->topo_sequence_index;
        if ($topo_index < @$out_nodes) {
            push @list, $out_nodes->[$topo_index];
        }
        for (my $i=0; $i<@$out_nodes; $i++) {
            next if $i == $topo_index;
            push @list, $out_nodes->[$i];
        }
    }
    return grep { defined } @list;
}

sub reachable_out_nodes {
    my ($self) = @_;
    my @nodes;
    my %seen = ( refaddr ($self) => 1 );
    my @scan_queue = $self->topo_out_nodes;
    while (my $node = shift @scan_queue) {
        my $ref_key = refaddr ($node);
        next if $seen{$ref_key};

        push @nodes, $node;
        $seen{$ref_key} = 1;

        unshift @scan_queue, $node->topo_out_nodes;
    }
    return @nodes;
}

sub needs_2_out_nodes { undef }
sub needs_defined_out_nodes { undef }
sub needs_identical_out_nodes { undef }

sub check {
    my ($self) = @_;
    my $out_nodes = $self->out_nodes;

    die ($self->node_type . " needs out nodes")
        if (!$out_nodes || !@$out_nodes) && (
            $self->needs_2_out_nodes || 
            $self->needs_defined_out_nodes || 
            $self->needs_identical_out_nodes
        );

    die ($self->node_type . " needs 2 out nodes")
        if $self->needs_2_out_nodes && 2 != @$out_nodes;

    die ($self->node_type . " needs identical out nodes")
        if $self->needs_identical_out_nodes &&
            $out_nodes->[0] != $out_nodes->[1];

    die ($self->node_type . " needs defined out nodes")
        if $self->needs_identical_out_nodes &&
            (!$out_nodes->[0] || !$out_nodes->[1]);
}

use Scalar::Util qw( refaddr );

sub to_string_short {
    my ($self, $indent) = @_;
    $indent ||= '';
    my $text = $self->node_type . sprintf ('[%08X] ', refaddr ($self)) .
        ($self->is_sequential_node ? 'SEQ ' : '') .
        ($self->is_terminal_node ? 'TERM ' : '') .
        ($self->is_nop_on_fall_through && $self->is_uncond_jump ? 'NOP ' : '');
    if ($self->is_uncond_jump) {
        $text .= 'next: ['. $self->ok_node->node_type . sprintf ('@%08lX', refaddr ($self->ok_node)) . ']';
    }
    else {
        my $out_nodes = $self->out_nodes;
        if ($out_nodes && @$out_nodes) {
            $text .= ' out: [';
            for (my $i=0; $i<@$out_nodes; $i++) {
                my $node = $out_nodes->[$i];
                $text .= ($i ? ' ' : '') .
                    $node->node_type . (
                        ref ($node) ? sprintf ('@%08X', refaddr ($node)) :
                        defined ($node) ? "$node" : '<undef>'
                    );
            }
            $text .= ']';
        }
    }
    return $text;
}

sub op_tree_to_string {
    my ($self, $seen, $indent) = @_;
    $indent ||= '';
    $seen ||= {};
    return '' if $seen->{refaddr ($self)};
    $seen->{refaddr ($self)} = 1;
    my $text = $self->to_string_short ($indent);
    for my $out_node ($self->topo_out_nodes) {
        $text .= "\n$indent   " . $out_node->op_tree_to_string ($seen, '   ' . $indent)
            if defined ($out_node) && !$seen->{refaddr ($out_node)};
    }
    return $text;
}

use overload '""'       => '_to_string',
             'bool'     => '_bool',
             '==',      => '_eqeq',
             '<=>'      => '_cmp_ref',
             fallback   => 1;

sub _to_string {
    return $_[0]->to_string_short;
}

sub _bool {
    no overloading;
    return defined ($_[0]);
}

sub _eqeq {
    no overloading;
    return defined ($_[1]) && refaddr ($_[0]) == refaddr ($_[1]);
}

sub _cmp_ref {
    no overloading;
    my ($self, $arg, $reverse) = @_;
    my $a = refaddr ($self);
    my $b = defined ($arg) ? refaddr ($arg) : 0;
    return $reverse ? $b <=> $a : $a <=> $b;
}

1;

