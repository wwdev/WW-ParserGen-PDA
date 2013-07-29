package WW::ParserGen::PDA::Op;
use feature qw(:5.12);
use strict;

use Moose;

has list_index => (
    is              => 'rw',
);

has graph_node => (
    is              => 'ro',
);

has op_def => (
    is              => 'ro',
    writer          => 'set_op_def',
);

has op_comment => (
    is              => 'ro',
    isa             => 'Str',
);

has args => (
    is              => 'ro',
    isa             => 'ArrayRef',
    writer          => 'set_args',
);

has ref_count => (
    is              => 'ro',
    isa             => 'Int',
    default         => 0,
);

sub clear_args {
    $_[0]->{args} = undef;
}

sub inc_ref_count {
    $_[0]->{ref_count}++;
}

sub BUILD {
    my ($self) = @_;
    my $args = $self->args;
    $self->{args} = undef if $args && !@$args;
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub check_args {
    my ($self) = @_;
    $self->op_def->check_args ($self->args);
}

sub pda_op($$@) {
    my ($graph_node, $op_def, @args) = @_;
    return __PACKAGE__->new (
        graph_node      => $graph_node,
        op_def          => $op_def,
        (@args ? ( args => \@args ) : ( )),
    );
}

sub pda_op_w_comment($$$@) {
    my ($graph_node, $op_def, $op_comment, @args) = @_;
    return __PACKAGE__->new (
        graph_node      => $graph_node,
        op_def          => $op_def,
        ( $op_comment ? ( op_comment      => $op_comment ) : ( )),
        (@args ? ( args => \@args ) : ( )),
    );
}

use Scalar::Util qw( blessed refaddr );
use overload '""'       => '_to_string',
             'bool'     => '_bool',
             fallback   => 1;

sub _to_string {
    return $_[0]->to_string ('');
}

sub to_string {
    my ($self, $indent) = @_;
    $indent ||= '';
    my $index = $self->list_index;
    my $text = sprintf ('op[%08X] %-12s ', 
                    refaddr ($self),
                    (defined ($self->op_def) ? $self->op_def->op_type : '<no op def>')
               ) .
               (defined ($self->list_index) ? ' list_index: ' . $self->list_index : '');
    if (my $graph_node = $self->graph_node) {
        $text .= "\n${indent}gnode:  <" . $graph_node->to_string_short . '>';
    }
    $text .= "\n${indent}op_def: " . $self->op_def if defined $self->op_def;
    if (my $args = $self->args) {
        $text .= "\n${indent}args:  "; 
        for (@$args) {
            unless (defined $_) {
                $text .= ' <undef>';
                next;
            }
            unless (blessed $_) {
                $text .= ' ' . $_;
                next;
            }
            if ($_->isa ('WW::ParserGen::OpGraph::Node')) {
                $text .= sprintf (' gnode[%08X]', refaddr ($_));
                next;
            }
            if ($_->isa (__PACKAGE__)) {
                $text .= sprintf (' op[%08X]', refaddr ($_));
                next;
            }
            $text .= ' ' . $_;
        }
    }
    return $text;
}

sub _bool {
    no overloading;
    return defined ($_[0]);
}

use Exporter qw( import );

our @EXPORT_OK = qw( pda_op pda_op_w_comment );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

