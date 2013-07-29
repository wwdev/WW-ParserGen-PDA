package WW::ParserGen::PDA::AST::RegexMatch;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has [qw( regex delimiter )] => (
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

has [qw( is_char_class code_points class_chars char_ranges )] => (
    is          => 'ro',
);

sub _char_class_escape($);
sub BUILD {
    my ($self, $args) = @_;
    return unless $self->is_char_class;

    my %code_points;
    if (my $cp_list = $self->code_points) {
        %code_points = map { ( hex ($_), 1 ) } @$cp_list;
    }
    if (defined (my $chr_str = $self->class_chars)) {
        for (my $i=0; $i<length ($chr_str); $i++) {
            $code_points{ord(substr ($chr_str, $i, 1))} = 1;
        }
    }

    my $l = scalar (keys %code_points);
    die ("no characters specified in character class")
        unless $l || $self->char_ranges;

    my $has_hypen = $code_points{ord('-')};
    my $has_caret = $code_points{ord('^')};
    delete $code_points{ord('-')};
    delete $code_points{ord('^')};

    my $text = ($has_hypen ? '-' : '') .
               _char_class_escape (join ('', map { chr ($_) } sort { $a <=> $b } keys %code_points)) .
               ($has_caret ? '\\^' : '');
    $self->_add_char_ranges (\$text);

    my $q = $self->quantifier || '';
    $self->{regex} = 
        ($q eq '!' ? '(?!' : '') .
        ($self->node_type eq 'not_char_class' ? '[^' : '[') .
        $text . ']' . ($q eq '!' ? ')' : $q);
    $self->{node_type} = 'regex_match';
    $self->{quantifier} = '';
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub _inline_size { 1 }

sub needs_grouping {
    my ($self) = @_;
    return index ($self->regex, '|') >= 0;
}

our %_TEXT_ESCAPES;
BEGIN {
    return if keys %_TEXT_ESCAPES;
    my $bs = chr (92); # back slash
    our %_TEXT_ESCAPES = (
        9       => $bs . 't',       # tab
        10      => $bs . 'x0A',     # lf
        13      => $bs . 'x0D',     # cr
        36      => $bs . '$',       # $
        37      => $bs . '%',       # %
        47      => $bs . '/',       # /
        64      => $bs . '@',       # @
        91      => $bs . '[',       # [
        92      => $bs . $bs,       # \
        93      => $bs . ']',       # ]
        94      => $bs . '^',       # ^
    );
}

sub _add_char_ranges {
    my ($self, $text_ref) = @_;
    my $ranges = $self->char_ranges;
    return unless $ranges;

    my %range_cp;
    for (@$ranges) {
        my ($start, $end, $except) = @$_{qw( start end except )};
        my $start_cp = length ($start) > 1 ? hex ($start) : ord ($start);
        my $end_cp   = length ($end) > 1   ? hex ($end)   : ord ($end);
        die ("char class range start/end reversed: $start_cp > $end_cp")
            if $start_cp > $end_cp || $start_cp < 0 || $end_cp < 0; # 0xfff....ff wraparound

        while ($start_cp <= $end_cp) {
            $range_cp{$start_cp++} = 1;
        }

        if ($except) {
            for (@$except) {
                delete $range_cp{length ($_) > 1 ? hex ($_) : ord ($_)};
            }
        }
    }

    my ($start_cp, $end_cp) = ( undef, undef );
    for my $code_point (sort { $a <=> $b } keys %range_cp) {
        unless (defined $start_cp) { 
            $start_cp = $end_cp = $code_point; next;
        }
        if ($end_cp + 1 == $code_point) {
            $end_cp++; next;
        }
        $$text_ref .= _char_class_escape (chr ($start_cp));
        if ($start_cp != $end_cp) {
            $$text_ref .= '-' . _char_class_escape (chr ($end_cp));
        }
        $start_cp = $end_cp = $code_point;
    }
    if (defined ($start_cp)) {
        $$text_ref .= _char_class_escape (chr ($start_cp));
        if ($start_cp != $end_cp) {
            $$text_ref .= '-' . _char_class_escape (chr ($end_cp));
        }
    }
}

sub _char_class_escape($) {
    my $text = $_[0];
    my $escaped_text = '';
    for (my $i=0; $i<length($text); $i++) {
       my $code_point = ord (substr ($text, $i, 1));
        if (my $escape = $_TEXT_ESCAPES{$code_point}) {
            $escaped_text .= $escape;
            next;
        }
        if ($code_point < 32 || 127 <= $code_point && $code_point <= 255) {
            $escaped_text .= '\x' . sprintf ('%02X', $code_point);
            next;
        }
        if ($code_point > 255) {
            $escaped_text .= '\x{' . sprintf('%04X', $code_point) . '}';
            next;
        }
        $escaped_text .= chr ($code_point);
    }
    return $escaped_text;
}

1;

