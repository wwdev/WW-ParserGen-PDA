package WW::ParserGen::PDA::OpGraph::SlotAllocs;
use feature qw(:5.12);
use strict 1;

use Moose;


has bt_depth => (
    is          => 'ro',
    isa         => 'Int',
    default     => 0,
);

has max_bt_slot => (
    is          => 'ro',
    default     => -1,
);

no Moose;
__PACKAGE__->meta->make_immutable;

sub alloc_bt_slot {
    my ($self) = @_;
    my $idx = $self->{bt_depth}++;
    my $max_idx = $self->{max_bt_slot};
    $self->{max_bt_slot} = $idx 
        if !$max_idx || $max_idx < $idx;
    return $idx;
}

sub free_bt_slot {
    my ($self) = @_;
    $self->{bt_depth}--;
}

sub _SlotAllocs() { __PACKAGE__ }

use Exporter qw( import );
our @EXPORT_OK = qw( _SlotAllocs );

1;

