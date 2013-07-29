package WW::ParserGen::PDA::AST::TokenDef;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has token_name => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has is_case_insensitive => (
    is          => 'ro',
    isa         => 'Bool',
);

has token_match => (
    is          => 'ro',
    isa         => 'Object',
    required    => 1,
    writer      => 'set_token_match',
);

has token_regex => (
    is          => 'ro',
);

has custom_args => (
    is          => 'ro',
    isa         => 'ArrayRef[Str]',
);

has custom_code => (
    is          => 'ro',
    isa         => 'Str',
);

sub BUILD {
    my ($self, $args) = @_;
    $self->{token_regex} = '\G' . $self->_build_regex ($self->token_match, 1);
}

no Moose;
__PACKAGE__->meta->make_immutable;

our %_TEXT_ESCAPES;
BEGIN {
    return if keys %_TEXT_ESCAPES;
    my $bs = chr (92); # back slash
    # ord ("'") = 34
    # ord ("'") = 39
    our %_TEXT_ESCAPES = (
        9       => $bs . 't',       # tab
        10      => $bs . 'x0A',     # lf
        13      => $bs . 'x0D',     # cr
        36      => "[$bs\$]",       # $
        37      => $bs . '%',       # %
        40      => '[(]',           # (
        41      => '[)]',           # )
        42      => '[*]',           # *
        43      => '[+]',           # +
        46      => '[.]',           # .
        47      => $bs . '/',       # /
        63      => '[?]',           # ?
        64      => $bs . '@',       # @
        91      => '[\[]',          # [
        92      => $bs . $bs,       # \
        93      => '[\]]',          # ]
        94      => $bs . '^',       # ^
        123     => '[{]',           # {
        124     => '[|]',           # |
        125     => '[}]',           # }
    );
}

sub _regex_text_escape($) {
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

sub _build_regex {
    my ($self, $match, $needs_group) = @_;
    my $q = $match->{quantifier} || '';
    my ($prefix, $suffix) = ( '', '' );

    if ($q eq '!')          { ($prefix, $suffix) = ( '(?!', ')'      ); }
    elsif ($q)              { ($prefix, $suffix) = ( '(?:', ')' . $q ); }
    elsif ($needs_group)    { ($prefix, $suffix) = ( '(?:', ')'      ); }

    for ($match->node_type) {
        when ('literal_match') {
            return $prefix . _regex_text_escape ($match->{match_text}) . $suffix;
        }
        when ('regex_match') {
            my $nonconst = '' . $match->regex;
            $nonconst =~ s!/!\\/!g unless $match->is_char_class;
            return $prefix . $nonconst . $suffix;
        }
        when ('token_match_seq') {
            my $seq_text = '';
            for my $seq_match (@{$match->match_list}) {
                $seq_text .= _build_regex (
                    $self, $seq_match, 
                    $seq_match->node_type eq 'token_match_or' ||
                        $seq_match->needs_grouping
                );
            }
            return $prefix . $seq_text . $suffix;
        }
        when ('token_match_or') {
            my ( $or_text, $or_op ) = ( '', '' );
            for my $seq_match (@{$match->match_list}) {
                $or_text .= $or_op . _build_regex ($self, $seq_match, $needs_group);
                $or_op = '|';
            }
            return $prefix . $or_text . $suffix;
        }
        default { die $self->token_name . ' unsupported match ' . $_; }
    }
}

1;

