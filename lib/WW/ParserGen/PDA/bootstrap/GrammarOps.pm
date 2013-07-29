#################################################################################
# WW::ParserGen::PDA::GrammarOps PDA ENGINE VERSION: 0.012001
#################################################################################
package WW::ParserGen::PDA::GrammarOps;
use feature qw(:5.12);
use strict;

use Scalar::Util qw( refaddr );
use WW::Parse::PDA::OpDefs qw( :op_funcs :op_helpers );
use WW::ParserGen::PDA::AST::ConstValue;
use WW::ParserGen::PDA::AST::CustomMatch;
use WW::ParserGen::PDA::AST::CustomMatchDef;
use WW::ParserGen::PDA::AST::DebugBreakOp;
use WW::ParserGen::PDA::AST::ExprOp;
use WW::ParserGen::PDA::AST::ExprOpRightArg;
use WW::ParserGen::PDA::AST::ExprTree;
use WW::ParserGen::PDA::AST::Fail;
use WW::ParserGen::PDA::AST::Fatal;
use WW::ParserGen::PDA::AST::FirstMatch;
use WW::ParserGen::PDA::AST::IfTest;
use WW::ParserGen::PDA::AST::InfixOpTable;
use WW::ParserGen::PDA::AST::KeyMatch;
use WW::ParserGen::PDA::AST::LiteralMatch;
use WW::ParserGen::PDA::AST::MatchList;
use WW::ParserGen::PDA::AST::RegexMatch;
use WW::ParserGen::PDA::AST::RuleCall;
use WW::ParserGen::PDA::AST::RuleDef;
use WW::ParserGen::PDA::AST::RuleDefs;
use WW::ParserGen::PDA::AST::RuleMatch;
use WW::ParserGen::PDA::AST::SequenceMatch;
use WW::ParserGen::PDA::AST::TokenDef;
use WW::ParserGen::PDA::AST::TraceFlags;
use WW::ParserGen::PDA::AST::UsePackage;
use WW::ParserGen::PDA::AST::VarAssign;
use WW::ParserGen::PDA::AST::VarSetConst;
use WW::ParserGen::PDA::AST::VarSetOp;

BEGIN {
    die (__PACKAGE__ . ' needs at least version 0.012001 of WW::Parse::PDA::OpDefs')
        unless $WW::Parse::PDA::OpDefs::MIN_COMPAT_VERSION le '0.012001';
}

#================================================================================
# Regex/Token/Perl Match Ops
#================================================================================
sub regex0($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([^\x0D\x10'\\]+)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex1($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([^\x0D\x10])/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex2($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G(\d)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex3($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([_a-zA-Z][_a-zA-Z0-9]*)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex4($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([0-9])/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex5($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G[_a-zA-Z0-9]/gc;
    return $idx + 2;
}

sub regex6($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([0-9]+)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex7($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([-+]?\d+)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex8($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G(.)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex9($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([^\x0A\x0D'\\]+)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex10($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G[a-zA-Z]/gc;
    return $idx + 2;
}

sub regex11($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G[\\]/gc;
    return $idx + 2;
}

sub regex12($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([^"\\]+)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex13($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m!\G([^/\\]+)!gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex14($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m!\G([\\].)!gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex15($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([^!\\]+)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex16($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([^'\x0D\x0A]+)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex17($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G(\d+)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub regex18($$$) {
    my ($ctx, $idx, $op_list) = @_;
    my $text_ref = $ctx->{text_ref};
    $ctx->{match_status} = $$text_ref =~ m/\G([^\s)]+)/gc;
    $ctx->{match_value} = $1;
    return $idx + 2;
}

sub token__arg_def($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:[\$](?:(?:[\$]text_ref)|(?:[\$]offset)|(?:[\$]rule_vars)|(?:[\$]r[0-9])|(?:[\$])|(?:[_A-Za-z][_0-9A-Za-z]*)))/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token__custom_match_code($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:[ -~]*(?:(?!\n})(?:\x0D)?(?:\x0A)?[ -~]*)*)/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token__not_char_class($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:(?:M[\[])|(?:!m[\[]))/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token_assign_op($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:(?:=)|(?:[+]=)|(?:[?]=)|(?:<<<?))/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token_class_chars($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:[!-&(-;=?-Z\\\^-~])/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token_ext_quantifier($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:[!*+?])/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token_fq_package($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:[_A-Za-z][_0-9A-Za-z]*(?:::[_A-Za-z][_0-9A-Za-z]*)*)/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token_hex_code_point($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:[0-9A-Fa-f][0-9A-Fa-f]+(?![A-Za-z]))/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token_name($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:[_A-Za-z][_0-9A-Za-z]*)/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token_range_char($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:[!-,.-;=?-~])/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token_std_quantifier($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:[*+?])/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub token_ws($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $set_match = $op_list->[$op_index + 1];
    my $text_ref = $ctx->{text_ref};

    my $start_pos = pos ($$text_ref);
    if ($$text_ref =~ m/\G(?:(?:[\t\x0A\x0D ]+)|(?:#[^\x0A]*(?:\x0A)?))*/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = substr (
            $$text_ref, $start_pos, pos ($$text_ref) - $start_pos
        ) if $set_match;
    }
    else {
        $ctx->{match_status} = undef;
        $ctx->{match_value}   = undef if $set_match;
    }
    return $op_index + 2;
}

sub _hex_or_int_char($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $text_ref    = $ctx->{text_ref};
    if ($$text_ref =~ m/\G(0x([0-9a-fA-F]+)|([0-9]+))/gc) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = chr (
            defined ($2) && length ($2) ? hex ($2) : int ($3)
        );
    }
    else {
        $ctx->{match_status} = undef;
    }
    return $op_index + 2;
}

sub at_eof($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $text_ref    = $ctx->{text_ref};
    $ctx->{match_status} = pos ($$text_ref) >= length ($$text_ref);
    return $op_index + 2;
}

sub get_const_value($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    if (my $const_value = $ctx->{match_value}) {
        $ctx->{match_status} = 1;
        $ctx->{match_value} = $const_value->value;
    }
    else {
        $ctx->{match_status} = undef;
    }
    return $op_index + 2;
}

sub make_group_match($$$) {
    my ($ctx, $op_index, $op_list) = @_;
    my $m = $ctx->register (0);
    my $q = $ctx->register (1);
    if ($q && $m->quantifier) {
        $ctx->{match_status} = undef;
    }
    else {
        $m->set_quantifier ($q) if $q;
        $ctx->{match_value} = $m;
        $ctx->{match_status} = 1;
    }
    return $op_index + 2;
}

#================================================================================
# Op Addresses to Names
#================================================================================
our %OP_ADDRESS_NAMES;
BEGIN {
    return if scalar (keys (%OP_ADDRESS_NAMES));
    %OP_ADDRESS_NAMES = (
        refaddr (\&_hex_or_int_char)                   => '_hex_or_int_char',
        refaddr (\&add_iter_slot)                      => 'add_iter_slot',
        refaddr (\&at_eof)                             => 'at_eof',
        refaddr (\&custom_match)                       => 'custom_match',
        refaddr (\&debug_break_op)                     => 'debug_break_op',
        refaddr (\&expr_op)                            => 'expr_op',
        refaddr (\&expr_op_right_arg)                  => 'expr_op_right_arg',
        refaddr (\&expr_tree)                          => 'expr_tree',
        refaddr (\&fail)                               => 'fail',
        refaddr (\&fail_return)                        => 'fail_return',
        refaddr (\&fatal)                              => 'fatal',
        refaddr (\&get_const_value)                    => 'get_const_value',
        refaddr (\&goto_bt)                            => 'goto_bt',
        refaddr (\&gt_iter_slot)                       => 'gt_iter_slot',
        refaddr (\&hash_return)                        => 'hash_return',
        refaddr (\&if_test)                            => 'if_test',
        refaddr (\&jump)                               => 'jump',
        refaddr (\&jump_fail)                          => 'jump_fail',
        refaddr (\&jump_ok)                            => 'jump_ok',
        refaddr (\&key_match)                          => 'key_match',
        refaddr (\&literal_match)                      => 'literal_match',
        refaddr (\&literal_test)                       => 'literal_test',
        refaddr (\&make_group_match)                   => 'make_group_match',
        refaddr (\&not_match)                          => 'not_match',
        refaddr (\&ok_return)                          => 'ok_return',
        refaddr (\&pkg_return)                         => 'pkg_return',
        refaddr (\&regex_match)                        => 'regex_match',
        refaddr (\&rule_call)                          => 'rule_call',
        refaddr (\&rule_call_test)                     => 'rule_call_test',
        refaddr (\&rule_match)                         => 'rule_match',
        refaddr (\&rule_start)                         => 'rule_start',
        refaddr (\&rule_test)                          => 'rule_test',
        refaddr (\&set_bt)                             => 'set_bt',
        refaddr (\&set_iter_slot)                      => 'set_iter_slot',
        refaddr (\&set_rule_vars)                      => 'set_rule_vars',
        refaddr (\&test_match)                         => 'test_match',
        refaddr (\&token_match)                        => 'token_match',
        refaddr (\&trace_flags)                        => 'trace_flags',
        refaddr (\&var_move)                           => 'var_move',
        refaddr (\&var_set_const)                      => 'var_set_const',
        refaddr (\&var_set_op)                         => 'var_set_op',
        refaddr (\&regex0)                             => "<< [^\\x0D\\x10'\\\\]+ >>",
        refaddr (\&regex1)                             => "<< [^\\x0D\\x10] >>",
        refaddr (\&regex2)                             => "<< \\d >>",
        refaddr (\&regex3)                             => '<< [_a-zA-Z][_a-zA-Z0-9]* >>',
        refaddr (\&regex4)                             => '<< [0-9] >>',
        refaddr (\&regex5)                             => '<< [_a-zA-Z0-9] >>',
        refaddr (\&regex6)                             => '<< [0-9]+ >>',
        refaddr (\&regex7)                             => "<< [-+]?\\d+ >>",
        refaddr (\&regex8)                             => '<< . >>',
        refaddr (\&regex9)                             => "<< [^\\x0A\\x0D'\\\\]+ >>",
        refaddr (\&regex10)                            => '<< [a-zA-Z] >>',
        refaddr (\&regex11)                            => "<< [\\\\] >>",
        refaddr (\&regex12)                            => "<< [^\"\\\\]+ >>",
        refaddr (\&regex13)                            => "<< [^/\\\\]+ >>",
        refaddr (\&regex14)                            => "<< [\\\\]. >>",
        refaddr (\&regex15)                            => "<< [^!\\\\]+ >>",
        refaddr (\&regex16)                            => "<< [^'\\x0D\\x0A]+ >>",
        refaddr (\&regex17)                            => "<< \\d+ >>",
        refaddr (\&regex18)                            => "<< [^\\s)]+ >>",
        refaddr (\&_hex_or_int_char)                   => '_hex_or_int_char',
        refaddr (\&at_eof)                             => 'at_eof',
        refaddr (\&get_const_value)                    => 'get_const_value',
        refaddr (\&make_group_match)                   => 'make_group_match',
        refaddr (\&token__arg_def)                     => '_arg_def',
        refaddr (\&token__custom_match_code)           => '_custom_match_code',
        refaddr (\&token__not_char_class)              => '_not_char_class',
        refaddr (\&token_assign_op)                    => 'assign_op',
        refaddr (\&token_class_chars)                  => 'class_chars',
        refaddr (\&token_ext_quantifier)               => 'ext_quantifier',
        refaddr (\&token_fq_package)                   => 'fq_package',
        refaddr (\&token_hex_code_point)               => 'hex_code_point',
        refaddr (\&token_name)                         => 'name',
        refaddr (\&token_range_char)                   => 'range_char',
        refaddr (\&token_std_quantifier)               => 'std_quantifier',
        refaddr (\&token_ws)                           => 'ws',
    );
}

#================================================================================
# Op Addresses to Trace Flags
#================================================================================
our %OP_ADDRESS_TRACE_FLAGS;
BEGIN {
    return if scalar (keys (%OP_ADDRESS_TRACE_FLAGS));
    %OP_ADDRESS_TRACE_FLAGS = (
        refaddr (\&_hex_or_int_char)                   => 9,
        refaddr (\&add_iter_slot)                      => 12,
        refaddr (\&at_eof)                             => 9,
        refaddr (\&custom_match)                       => 9,
        refaddr (\&debug_break_op)                     => 9,
        refaddr (\&expr_op)                            => 9,
        refaddr (\&expr_op_right_arg)                  => 9,
        refaddr (\&expr_tree)                          => 9,
        refaddr (\&fail)                               => 9,
        refaddr (\&fail_return)                        => 10,
        refaddr (\&fatal)                              => 11,
        refaddr (\&get_const_value)                    => 9,
        refaddr (\&goto_bt)                            => 12,
        refaddr (\&gt_iter_slot)                       => 12,
        refaddr (\&hash_return)                        => 10,
        refaddr (\&if_test)                            => 9,
        refaddr (\&jump)                               => 8,
        refaddr (\&jump_fail)                          => 9,
        refaddr (\&jump_ok)                            => 9,
        refaddr (\&key_match)                          => 9,
        refaddr (\&literal_match)                      => 9,
        refaddr (\&literal_test)                       => 9,
        refaddr (\&make_group_match)                   => 9,
        refaddr (\&not_match)                          => 9,
        refaddr (\&ok_return)                          => 10,
        refaddr (\&pkg_return)                         => 10,
        refaddr (\&regex_match)                        => 9,
        refaddr (\&rule_call)                          => 9,
        refaddr (\&rule_call_test)                     => 9,
        refaddr (\&rule_match)                         => 9,
        refaddr (\&rule_start)                         => 10,
        refaddr (\&rule_test)                          => 9,
        refaddr (\&set_bt)                             => 12,
        refaddr (\&set_iter_slot)                      => 12,
        refaddr (\&set_rule_vars)                      => 10,
        refaddr (\&test_match)                         => 9,
        refaddr (\&token_match)                        => 9,
        refaddr (\&trace_flags)                        => 8,
        refaddr (\&var_move)                           => 9,
        refaddr (\&var_set_const)                      => 9,
        refaddr (\&var_set_op)                         => 9,
        refaddr (\&regex0)                             => 9,
        refaddr (\&regex1)                             => 9,
        refaddr (\&regex2)                             => 9,
        refaddr (\&regex3)                             => 9,
        refaddr (\&regex4)                             => 9,
        refaddr (\&regex5)                             => 9,
        refaddr (\&regex6)                             => 9,
        refaddr (\&regex7)                             => 9,
        refaddr (\&regex8)                             => 9,
        refaddr (\&regex9)                             => 9,
        refaddr (\&regex10)                            => 9,
        refaddr (\&regex11)                            => 9,
        refaddr (\&regex12)                            => 9,
        refaddr (\&regex13)                            => 9,
        refaddr (\&regex14)                            => 9,
        refaddr (\&regex15)                            => 9,
        refaddr (\&regex16)                            => 9,
        refaddr (\&regex17)                            => 9,
        refaddr (\&regex18)                            => 9,
        refaddr (\&token__arg_def)                     => 9,
        refaddr (\&token__custom_match_code)           => 9,
        refaddr (\&token__not_char_class)              => 9,
        refaddr (\&token_assign_op)                    => 9,
        refaddr (\&token_class_chars)                  => 9,
        refaddr (\&token_ext_quantifier)               => 9,
        refaddr (\&token_fq_package)                   => 9,
        refaddr (\&token_hex_code_point)               => 9,
        refaddr (\&token_name)                         => 9,
        refaddr (\&token_range_char)                   => 9,
        refaddr (\&token_std_quantifier)               => 9,
        refaddr (\&token_ws)                           => 9,
    );
}

#================================================================================
# Literal List
#================================================================================
our @LITERAL_LIST = (
    '_arg_defs',
    '*0',
    '*match_value*',
    '_custom_match_part',
    'node_type',
    'match_name',
    'arg_names',
    '*1',
    '{',
    'code',
    '}',
    'WW::ParserGen::PDA::AST::CustomMatchDef',
    '_make_first_match',
    'match_list',
    'WW::ParserGen::PDA::AST::FirstMatch',
    '_make_sequence_match',
    'WW::ParserGen::PDA::AST::SequenceMatch',
    '_string_value',
    '\'',
    "\\",
    '_token_def_part',
    'token_name',
    ':',
    'case_insensitive',
    'is_case_insensitive',
    '::=',
    'token_match',
    '.',
    'WW::ParserGen::PDA::AST::TokenDef',
    '_var_assign',
    'dest_ref',
    'op',
    "\$",
    'src_ref',
    'WW::ParserGen::PDA::AST::VarAssign',
    '_var_ref',
    "\$rule_vars",
    "\$r",
    "\$offset",
    '_var_set_const',
    'var_ref',
    '0x',
    'value',
    'WW::ParserGen::PDA::AST::VarSetConst',
    '_var_set_match',
    'match',
    'quantifier',
    'WW::ParserGen::PDA::AST::VarSetOp',
    'array_const',
    '[',
    ']',
    'value_type',
    'WW::ParserGen::PDA::AST::ConstValue',
    'char_constant',
    '&&char[',
    'char_range',
    '<',
    'start',
    '-',
    'end',
    '!',
    'except',
    '>',
    'const_args',
    'custom_match',
    'WW::ParserGen::PDA::AST::CustomMatch',
    'match_args',
    'custom_match_def',
    "\@match",
    'debug_break',
    'debug_break[',
    'message',
    'WW::ParserGen::PDA::AST::DebugBreakOp',
    'digit_const',
    'expr_op',
    'infix_operator[',
    'op_table_name',
    'WW::ParserGen::PDA::AST::ExprOp',
    'expr_op_right_arg',
    'infix_operator_arg',
    'WW::ParserGen::PDA::AST::ExprOpRightArg',
    'expr_tree',
    'infix_expr_tree',
    'WW::ParserGen::PDA::AST::ExprTree',
    'fail',
    'WW::ParserGen::PDA::AST::Fail',
    'fatal',
    'msg_params',
    'WW::ParserGen::PDA::AST::Fatal',
    'hash_const',
    'if_false',
    'if_false[',
    'var_refs',
    'WW::ParserGen::PDA::AST::IfTest',
    'if_true',
    'if_true[',
    'infix_op_info',
    'operator',
    'left',
    'assoc',
    'precedence',
    '&',
    'constructor_op',
    'right',
    'infix_op_table',
    "\@infix_operators",
    'name',
    'WW::ParserGen::PDA::AST::InfixOpTable',
    'operators',
    'int_const',
    'key_match',
    'key_match_list',
    '=>',
    '|',
    'WW::ParserGen::PDA::AST::KeyMatch',
    'literal_match',
    'match_text',
    'WW::ParserGen::PDA::AST::LiteralMatch',
    'code_point',
    'literal_var_ref',
    'make_match_list',
    '*2',
    'WW::ParserGen::PDA::AST::MatchList',
    'match_atom',
    'match_group',
    '(',
    ')',
    'node_package_prefix',
    "\@node_package_prefix",
    'operator_string',
    "\"",
    'parser_package',
    "\@package",
    'regex_match',
    'm/',
    'regex',
    '/',
    'delimiter',
    'WW::ParserGen::PDA::AST::RegexMatch',
    'm!',
    'is_char_class',
    'code_points',
    'class_chars',
    'char_ranges',
    'm[',
    'rule_call',
    'call[',
    'rule_name',
    "\$\$r",
    'WW::ParserGen::PDA::AST::RuleCall',
    'reg_numbers',
    'rule_def',
    'node_pkg',
    'WW::ParserGen::PDA::AST::RuleDef',
    'rule_vars',
    'rule_defs',
    'parser_pkg',
    'node_pkg_prefix',
    'pkg_use_list',
    'custom_match_list',
    'infix_op_tables',
    'WW::ParserGen::PDA::AST::RuleDefs',
    'token_defs',
    'rule_match',
    'WW::ParserGen::PDA::AST::RuleMatch',
    'sequence_match',
    'string_const',
    'token_def',
    'token_match_atom',
    'token_match_group',
    'token_match_seq',
    'trace_flags',
    'trace_flags[',
    'WW::ParserGen::PDA::AST::TraceFlags',
    'undef_const',
    '<undef>',
    'use_package',
    "\@use",
    'fq_package',
    '::',
    'qw(',
    'use_args',
    'WW::ParserGen::PDA::AST::UsePackage',
    'var_ref_error',
);

#================================================================================
# Regex List
#================================================================================
our @REGEX_LIST = (
    "m/\\G([^\\x0D\\x10'\\\\]+)/gc",
    "m/\\G([^\\x0D\\x10])/gc",
    "m/\\G(\\d)/gc",
    "m/\\G([_a-zA-Z][_a-zA-Z0-9]*)/gc",
    "m/\\G([0-9])/gc",
    "m/\\G[_a-zA-Z0-9]/gc",
    "m/\\G([0-9]+)/gc",
    "m/\\G([-+]?\\d+)/gc",
    "m/\\G(.)/gc",
    "m/\\G([^\\x0A\\x0D'\\\\]+)/gc",
    "m/\\G[a-zA-Z]/gc",
    "m/\\G[\\\\]/gc",
    "m/\\G([^\"\\\\]+)/gc",
    "m!\\G([^/\\\\]+)!gc",
    "m!\\G([\\\\].)!gc",
    "m/\\G([^!\\\\]+)/gc",
    "m/\\G([^'\\x0D\\x0A]+)/gc",
    "m/\\G(\\d+)/gc",
    "m/\\G([^\\s)]+)/gc",
);

#================================================================================
# Rule Def Start Indexes
#================================================================================
our %RULE_DEF_INDEXES = (
    _arg_defs                      => 0,
    _custom_match_part             => 31,
    _make_first_match              => 80,
    _make_sequence_match           => 101,
    _string_value                  => 122,
    _token_def_part                => 182,
    _var_assign                    => 250,
    _var_ref                       => 301,
    _var_set_const                 => 375,
    _var_set_match                 => 455,
    array_const                    => 511,
    char_constant                  => 547,
    char_range                     => 593,
    const_args                     => 746,
    custom_match                   => 805,
    custom_match_def               => 847,
    debug_break                    => 896,
    digit_const                    => 944,
    expr_op                        => 970,
    expr_op_right_arg              => 1012,
    expr_tree                      => 1038,
    fail                           => 1064,
    fatal                          => 1092,
    hash_const                     => 1128,
    if_false                       => 1164,
    if_true                        => 1205,
    infix_op_info                  => 1246,
    infix_op_table                 => 1337,
    int_const                      => 1419,
    key_match                      => 1445,
    literal_match                  => 1598,
    literal_var_ref                => 1705,
    make_match_list                => 1786,
    match                          => 1807,
    match_atom                     => 1876,
    match_group                    => 2004,
    node_package_prefix            => 2057,
    operator_string                => 2101,
    parser_package                 => 2176,
    regex_match                    => 2220,
    rule_call                      => 2529,
    rule_def                       => 2610,
    rule_defs                      => 2714,
    rule_match                     => 2851,
    rule_vars                      => 2881,
    sequence_match                 => 2942,
    string_const                   => 3007,
    token_def                      => 3074,
    token_match                    => 3151,
    token_match_atom               => 3224,
    token_match_group              => 3245,
    token_match_seq                => 3304,
    trace_flags                    => 3366,
    undef_const                    => 3410,
    use_package                    => 3437,
    var_ref_error                  => 3537,
    var_refs                       => 3542,
);

#================================================================================
# Rule Def Names
#================================================================================
our %RULE_DEF_NAMES = (
        0 => '_arg_defs',
       31 => '_custom_match_part',
       80 => '_make_first_match',
      101 => '_make_sequence_match',
      122 => '_string_value',
      182 => '_token_def_part',
      250 => '_var_assign',
      301 => '_var_ref',
      375 => '_var_set_const',
      455 => '_var_set_match',
      511 => 'array_const',
      547 => 'char_constant',
      593 => 'char_range',
      746 => 'const_args',
      805 => 'custom_match',
      847 => 'custom_match_def',
      896 => 'debug_break',
      944 => 'digit_const',
      970 => 'expr_op',
     1012 => 'expr_op_right_arg',
     1038 => 'expr_tree',
     1064 => 'fail',
     1092 => 'fatal',
     1128 => 'hash_const',
     1164 => 'if_false',
     1205 => 'if_true',
     1246 => 'infix_op_info',
     1337 => 'infix_op_table',
     1419 => 'int_const',
     1445 => 'key_match',
     1598 => 'literal_match',
     1705 => 'literal_var_ref',
     1786 => 'make_match_list',
     1807 => 'match',
     1876 => 'match_atom',
     2004 => 'match_group',
     2057 => 'node_package_prefix',
     2101 => 'operator_string',
     2176 => 'parser_package',
     2220 => 'regex_match',
     2529 => 'rule_call',
     2610 => 'rule_def',
     2714 => 'rule_defs',
     2851 => 'rule_match',
     2881 => 'rule_vars',
     2942 => 'sequence_match',
     3007 => 'string_const',
     3074 => 'token_def',
     3151 => 'token_match',
     3224 => 'token_match_atom',
     3245 => 'token_match_group',
     3304 => 'token_match_seq',
     3366 => 'trace_flags',
     3410 => 'undef_const',
     3437 => 'use_package',
     3537 => 'var_ref_error',
     3542 => 'var_refs',
);

#================================================================================
# Infix Op Tables
#================================================================================
our %INFIX_OP_TABLES = (
);

#================================================================================
# Op List
#================================================================================
our @OP_LIST = (
    #--------------------------------------------------------------------------------
    # _arg_defs [0]
    #--------------------------------------------------------------------------------
    \&rule_start,                  0, 2,                     # <<_arg_defs>> slot_count
    \&set_bt,                      0,                        # (START SEQ #29) slot_idx
    \&var_set_const,               1, 0, [  ],               # <<*0>> op:=
# 9:
    \&set_bt,                      1,                        # slot_idx
    \&token__arg_def,              1,                        # set_match
    \&test_match,                  16, 24,                   # ok fail
# 16:
    \&var_set_op,                  1, 3,                     # <<*0>> op:<<
    \&token_ws,                    0,                        # set_match
    \&test_match,                  9, 9,                     # ok fail
# 24:
    \&goto_bt,                     1,                        # slot_idx
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            

    #--------------------------------------------------------------------------------
    # _custom_match_part [31]
    #--------------------------------------------------------------------------------
    \&rule_start,                  3, 1,                     # <<_custom_match_part>> slot_count
    \&set_rule_vars,               { arg_names => undef, code => undef, match_name => undef, node_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #116) slot_idx
    \&var_set_const,               4, 0, 'custom_match_def', 
                                                             # <<node_type>> op:=
    \&var_move,                    5, 0, 1,                  # <<match_name>> op:= <<*0>>
    \&var_move,                    6, 0, 7,                  # <<arg_names>> op:= <<*1>>
    \&token_ws,                    0,                        # set_match
    \&literal_test,                8,                        # <<{>>
    \&test_match,                  57, 76,                   # ok fail
# 57:
    \&token__custom_match_code,    1,                        # set_match
    \&test_match,                  62, 76,                   # ok fail
# 62:
    \&var_set_op,                  9, 0,                     # <<code>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                10,                       # <<}>>
    \&test_match,                  72, 74,                   # ok fail
# 72:
    \&pkg_return,                  11,                       # <<WW::ParserGen::PDA::AST::CustomMatchDef>>
# 74:
    \&fatal,                       [ 'missing closing } in &', "\$match_name", ' (closing } must be first char on the line)' ], 
# 76:
    \&goto_bt,                     0,                        # (FAIL SEQ #116) slot_idx
    \&fatal,                       [ 'expected &', "\$match_name", ' (<arg-defs>*) { <mini-perl> }' ], 

    #--------------------------------------------------------------------------------
    # _make_first_match [80]
    #--------------------------------------------------------------------------------
    \&rule_start,                  12, 1,                    # <<_make_first_match>> slot_count
    \&set_rule_vars,               { match_list => undef, node_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #128) slot_idx
    \&var_set_const,               4, 0, 'first_match',      # <<node_type>> op:=
    \&var_move,                    13, 3, 1,                 # <<match_list>> op:<< <<*0>>
    \&var_move,                    13, 4, 7,                 # <<match_list>> op:<<< <<*1>>
    \&pkg_return,                  14,                       # <<WW::ParserGen::PDA::AST::FirstMatch>>

    #--------------------------------------------------------------------------------
    # _make_sequence_match [101]
    #--------------------------------------------------------------------------------
    \&rule_start,                  15, 1,                    # <<_make_sequence_match>> slot_count
    \&set_rule_vars,               { match_list => undef, node_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #30) slot_idx
    \&var_set_const,               4, 0, 'sequence_match',   # <<node_type>> op:=
    \&var_move,                    13, 3, 1,                 # <<match_list>> op:<< <<*0>>
    \&var_move,                    13, 4, 7,                 # <<match_list>> op:<<< <<*1>>
    \&pkg_return,                  16,                       # <<WW::ParserGen::PDA::AST::SequenceMatch>>

    #--------------------------------------------------------------------------------
    # _string_value [122]
    #--------------------------------------------------------------------------------
    \&rule_start,                  17, 3,                    # <<_string_value>> slot_count
    \&set_bt,                      0,                        # (START SEQ #2) slot_idx
    \&literal_test,                18,                       # <<'>>
    \&test_match,                  132, 181,                 # ok fail
# 132:
    \&var_set_const,               1, 0, '',                 # <<*0>> op:=
# 136:
    \&set_bt,                      1,                        # slot_idx
    \&regex0,                      0,                        # <<m/\G([^\x0D\x10'\\]+)/gc>>
    \&test_match,                  143, 148,                 # ok fail
# 143:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
    \&jump,                        136,                      # next
# 148:
    \&set_bt,                      2,                        # (START SEQ #3) slot_idx
    \&literal_test,                19,                       # <<\>>
    \&test_match,                  155, 167,                 # ok fail
# 155:
    \&regex1,                      1,                        # <<m/\G([^\x0D\x10])/gc>>
    \&test_match,                  160, 165,                 # ok fail
# 160:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
    \&jump,                        136,                      # next
# 165:
    \&goto_bt,                     2,                        # (FAIL SEQ #3) slot_idx
# 167:
    \&goto_bt,                     1,                        # slot_idx
    \&literal_test,                18,                       # <<'>>
    \&test_match,                  174, 179,                 # ok fail
# 174:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 179:
    \&fatal,                       [ 'missing closing quote (\') in string constant' ], 
# 181:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # _token_def_part [182]
    #--------------------------------------------------------------------------------
    \&rule_start,                  20, 2,                    # <<_token_def_part>> slot_count
    \&set_rule_vars,               { is_case_insensitive => undef, node_type => undef, token_match => undef, token_name => undef }, 
    \&set_bt,                      0,                        # (START SEQ #34) slot_idx
    \&var_set_const,               4, 0, 'token_def',        # <<node_type>> op:=
    \&var_move,                    21, 0, 1,                 # <<token_name>> op:= <<*0>>
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #35) slot_idx
    \&literal_test,                22,                       # <<:>>
    \&test_match,                  206, 219,                 # ok fail
# 206:
    \&token_ws,                    0,                        # set_match
    \&literal_test,                23,                       # <<case_insensitive>>
    \&test_match,                  213, 246,                 # ok fail
# 213:
    \&token_ws,                    0,                        # set_match
    \&var_set_const,               24, 0, 1,                 # <<is_case_insensitive>> op:=
# 219:
    \&literal_test,                25,                       # <<::=>>
    \&test_match,                  224, 230,                 # ok fail
# 224:
    \&token_ws,                    0,                        # set_match
    \&rule_match,                  3151, 234, 230,           # token_match ok fail
# 230:
    \&goto_bt,                     0,                        # (FAIL SEQ #34) slot_idx
    \&fatal,                       [ 'token def error in ', "\$token_name" ], 
# 234:
    \&var_set_op,                  26, 0,                    # <<token_match>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                27,                       # <<.>>
    \&test_match,                  244, 230,                 # ok fail
# 244:
    \&pkg_return,                  28,                       # <<WW::ParserGen::PDA::AST::TokenDef>>
# 246:
    \&goto_bt,                     1,                        # (FAIL SEQ #35) slot_idx
    \&jump,                        219,                      # next

    #--------------------------------------------------------------------------------
    # _var_assign [250]
    #--------------------------------------------------------------------------------
    \&rule_start,                  29, 2,                    # <<_var_assign>> slot_count
    \&set_rule_vars,               { dest_ref => undef, node_type => undef, op => undef, src_ref => undef }, 
    \&set_bt,                      0,                        # (START SEQ #10) slot_idx
    \&rule_match,                  301, 261, 300,            # _var_ref ok fail
# 261:
    \&var_set_op,                  30, 0,                    # <<dest_ref>> op:=
    \&token_ws,                    0,                        # set_match
    \&token_assign_op,             1,                        # set_match
    \&test_match,                  271, 298,                 # ok fail
# 271:
    \&var_set_op,                  31, 0,                    # <<op>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #11) slot_idx
    \&literal_test,                32,                       # <<$>>
    \&test_match,                  283, 298,                 # ok fail
# 283:
    \&rule_match,                  301, 287, 296,            # _var_ref ok fail
# 287:
    \&var_set_op,                  33, 0,                    # <<src_ref>> op:=
    \&var_set_const,               4, 0, 'var_assign',       # <<node_type>> op:=
    \&pkg_return,                  34,                       # <<WW::ParserGen::PDA::AST::VarAssign>>
# 296:
    \&goto_bt,                     1,                        # (FAIL SEQ #11) slot_idx
# 298:
    \&goto_bt,                     0,                        # (FAIL SEQ #10) slot_idx
# 300:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # _var_ref [301]
    #--------------------------------------------------------------------------------
    \&rule_start,                  35, 5,                    # <<_var_ref>> slot_count
    \&set_bt,                      4,                        # (START SEQ #121) slot_idx
    \&literal_test,                36,                       # <<$rule_vars>>
    \&test_match,                  311, 316,                 # ok fail
# 311:
    \&var_set_const,               2, 0, '*rule_vars*',      # <<*match_value*>> op:=
# 315:
    \&ok_return,                                            
# 316:
    \&set_bt,                      2,                        # (START SEQ #119) slot_idx
    \&literal_test,                37,                       # <<$r>>
    \&test_match,                  323, 344,                 # ok fail
# 323:
    \&var_set_const,               1, 0, '*',                # <<*0>> op:=
    \&set_bt,                      3,                        # (START SEQ #120) slot_idx
    \&regex2,                      2,                        # <<m/\G(\d)/gc>>
    \&test_match,                  334, 342,                 # ok fail
# 334:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 342:
    \&fatal,                       [ "expected \$\$r<0-9>" ], 
# 344:
    \&set_bt,                      1,                        # (START SEQ #118) slot_idx
    \&literal_test,                38,                       # <<$offset>>
    \&test_match,                  351, 356,                 # ok fail
# 351:
    \&var_set_const,               2, 0, '*offset*',         # <<*match_value*>> op:=
    \&ok_return,                                            
# 356:
    \&set_bt,                      0,                        # (START SEQ #117) slot_idx
    \&literal_test,                32,                       # <<$>>
    \&test_match,                  363, 368,                 # ok fail
# 363:
    \&var_set_const,               2, 0, '*match_value*',    # <<*match_value*>> op:=
    \&ok_return,                                            
# 368:
    \&regex3,                      3,                        # <<m/\G([_a-zA-Z][_a-zA-Z0-9]*)/gc>>
    \&test_match,                  315, 373,                 # ok fail
# 373:
    \&fatal,                       [ "expected \$\$r<0-9> or \$\$offset or \$\$ or \$<name>" ], 

    #--------------------------------------------------------------------------------
    # _var_set_const [375]
    #--------------------------------------------------------------------------------
    \&rule_start,                  39, 2,                    # <<_var_set_const>> slot_count
    \&set_rule_vars,               { node_type => undef, op => undef, quantifier => undef, value => undef, var_ref => undef }, 
    \&set_bt,                      0,                        # (START SEQ #136) slot_idx
    \&rule_match,                  301, 386, 440,            # _var_ref ok fail
# 386:
    \&var_set_op,                  40, 0,                    # <<var_ref>> op:=
    \&token_ws,                    0,                        # set_match
    \&token_assign_op,             1,                        # set_match
    \&test_match,                  396, 438,                 # ok fail
# 396:
    \&var_set_op,                  31, 0,                    # <<op>> op:=
    \&token_ws,                    0,                        # set_match
    \&rule_match,                  3007, 441, 405,           # string_const ok fail
# 405:
    \&set_bt,                      1,                        # (START SEQ #137) slot_idx
    \&literal_test,                41,                       # <<0x>>
    \&not_match,                   412, 418,                 # ok fail
# 412:
    \&rule_match,                  1419, 441, 416,           # int_const ok fail
# 416:
    \&goto_bt,                     1,                        # (FAIL SEQ #137) slot_idx
# 418:
    \&rule_match,                  511, 441, 422,            # array_const ok fail
# 422:
    \&rule_match,                  1128, 441, 426,           # hash_const ok fail
# 426:
    \&rule_match,                  3410, 441, 430,           # undef_const ok fail
# 430:
    \&rule_match,                  547, 441, 434,            # char_constant ok fail
# 434:
    \&var_set_const,               2, 0, undef,              # <<*match_value*>> op:=
# 438:
    \&goto_bt,                     0,                        # (FAIL SEQ #136) slot_idx
# 440:
    \&fail_return,                                          
# 441:
    \&var_set_op,                  42, 0,                    # <<value>> op:=
    \&get_const_value,             undef,                   
    \&test_match,                  449, 438,                 # ok fail
# 449:
    \&var_set_const,               4, 0, 'var_set_const',    # <<node_type>> op:=
    \&pkg_return,                  43,                       # <<WW::ParserGen::PDA::AST::VarSetConst>>

    #--------------------------------------------------------------------------------
    # _var_set_match [455]
    #--------------------------------------------------------------------------------
    \&rule_start,                  44, 2,                    # <<_var_set_match>> slot_count
    \&set_rule_vars,               { match => undef, node_type => undef, op => undef, quantifier => undef, var_ref => undef }, 
    \&set_bt,                      0,                        # (START SEQ #104) slot_idx
    \&rule_match,                  301, 466, 510,            # _var_ref ok fail
# 466:
    \&var_set_op,                  40, 0,                    # <<var_ref>> op:=
    \&token_ws,                    0,                        # set_match
    \&token_assign_op,             1,                        # set_match
    \&test_match,                  476, 508,                 # ok fail
# 476:
    \&var_set_op,                  31, 0,                    # <<op>> op:=
    \&token_ws,                    0,                        # set_match
    \&rule_match,                  1876, 485, 508,           # match_atom ok fail
# 485:
    \&var_set_op,                  45, 0,                    # <<match>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #105) slot_idx
    \&token_std_quantifier,        1,                        # set_match
    \&test_match,                  497, 502,                 # ok fail
# 497:
    \&var_set_op,                  46, 0,                    # <<quantifier>> op:=
    \&token_ws,                    0,                        # set_match
# 502:
    \&var_set_const,               4, 0, 'var_set_op',       # <<node_type>> op:=
    \&pkg_return,                  47,                       # <<WW::ParserGen::PDA::AST::VarSetOp>>
# 508:
    \&goto_bt,                     0,                        # (FAIL SEQ #104) slot_idx
# 510:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # array_const [511]
    #--------------------------------------------------------------------------------
    \&rule_start,                  48, 1,                    # <<array_const>> slot_count
    \&set_rule_vars,               { node_type => undef, value => undef, value_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #49) slot_idx
    \&literal_test,                49,                       # <<[>>
    \&test_match,                  523, 546,                 # ok fail
# 523:
    \&token_ws,                    0,                        # set_match
    \&literal_test,                50,                       # <<]>>
    \&test_match,                  530, 544,                 # ok fail
# 530:
    \&var_set_const,               42, 0, [  ],              # <<value>> op:=
    \&var_set_const,               51, 0, 'Array',           # <<value_type>> op:=
    \&var_set_const,               4, 0, 'const_value',      # <<node_type>> op:=
    \&pkg_return,                  52,                       # <<WW::ParserGen::PDA::AST::ConstValue>>
# 544:
    \&goto_bt,                     0,                        # (FAIL SEQ #49) slot_idx
# 546:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # char_constant [547]
    #--------------------------------------------------------------------------------
    \&rule_start,                  53, 2,                    # <<char_constant>> slot_count
    \&set_rule_vars,               { node_type => undef, value => undef, value_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #8) slot_idx
    \&literal_test,                54,                       # <<&&char[>>
    \&test_match,                  559, 592,                 # ok fail
# 559:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #9) slot_idx
    \&_hex_or_int_char,            undef,                   
    \&test_match,                  568, 590,                 # ok fail
# 568:
    \&var_set_op,                  42, 0,                    # <<value>> op:=
    \&var_set_const,               51, 0, 'Str',             # <<value_type>> op:=
    \&var_set_const,               4, 0, 'const_value',      # <<node_type>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                50,                       # <<]>>
    \&test_match,                  586, 588,                 # ok fail
# 586:
    \&pkg_return,                  52,                       # <<WW::ParserGen::PDA::AST::ConstValue>>
# 588:
    \&goto_bt,                     1,                        # (FAIL SEQ #9) slot_idx
# 590:
    \&fatal,                       [ 'expected &&char[ 0x<hex-digits> | <decimal-digits> ]' ], 
# 592:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # char_range [593]
    #--------------------------------------------------------------------------------
    \&rule_start,                  55, 9,                    # <<char_range>> slot_count
    \&set_rule_vars,               { end => undef, except => undef, start => undef }, 
    \&set_bt,                      0,                        # (START SEQ #58) slot_idx
    \&literal_test,                56,                       # <<<>>
    \&test_match,                  605, 745,                 # ok fail
# 605:
    \&set_bt,                      1,                        # (START SEQ #59) slot_idx
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      8,                        # (START SEQ #64) slot_idx
    \&literal_test,                41,                       # <<0x>>
    \&test_match,                  616, 735,                 # ok fail
# 616:
    \&token_hex_code_point,        1,                        # set_match
    \&test_match,                  621, 733,                 # ok fail
# 621:
    \&var_set_op,                  57, 0,                    # <<start>> op:=
# 624:
    \&token_ws,                    0,                        # set_match
    \&literal_test,                58,                       # <<->>
    \&test_match,                  631, 713,                 # ok fail
# 631:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      7,                        # (START SEQ #63) slot_idx
    \&literal_test,                41,                       # <<0x>>
    \&test_match,                  640, 723,                 # ok fail
# 640:
    \&token_hex_code_point,        1,                        # set_match
    \&test_match,                  645, 721,                 # ok fail
# 645:
    \&var_set_op,                  59, 0,                    # <<end>> op:=
# 648:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      2,                        # (START SEQ #60) slot_idx
    \&literal_test,                60,                       # <<!>>
    \&test_match,                  657, 707,                 # ok fail
# 657:
    \&set_bt,                      3,                        # (START SEQ #61) slot_idx
    \&token_ws,                    0,                        # set_match
    \&set_iter_slot,               5, 0,                     # slot_idx value
# 664:
    \&set_bt,                      4,                        # slot_idx
    \&set_bt,                      6,                        # (START SEQ #62) slot_idx
    \&literal_test,                41,                       # <<0x>>
    \&test_match,                  673, 690,                 # ok fail
# 673:
    \&token_hex_code_point,        1,                        # set_match
    \&test_match,                  678, 688,                 # ok fail
# 678:
    \&var_set_op,                  61, 3,                    # <<except>> op:<<
# 681:
    \&token_ws,                    0,                        # set_match
    \&add_iter_slot,               5, 1,                     # slot_idx value
    \&jump,                        664,                      # next
# 688:
    \&goto_bt,                     6,                        # (FAIL SEQ #62) slot_idx
# 690:
    \&token_range_char,            1,                        # set_match
    \&test_match,                  695, 700,                 # ok fail
# 695:
    \&var_set_op,                  61, 3,                    # <<except>> op:<<
    \&jump,                        681,                      # next
# 700:
    \&goto_bt,                     4,                        # slot_idx
    \&gt_iter_slot,                5, 0, 707, 717,           # slot_idx value ok fail
# 707:
    \&literal_test,                62,                       # <<>>>
    \&test_match,                  712, 713,                 # ok fail
# 712:
    \&hash_return,                                          
# 713:
    \&goto_bt,                     1,                        # (FAIL SEQ #59) slot_idx
    \&fatal,                       [ 'expected < ( 0x<hex-digits> | <char> ) - ( 0x<hex-digits> | <char> ) ( ! <exclusion-list> )? >' ], 
# 717:
    \&goto_bt,                     3,                        # (FAIL SEQ #61) slot_idx
    \&fatal,                       [ 'expected ! ( 0x<hex_digits> | <range-char> )+' ], 
# 721:
    \&goto_bt,                     7,                        # (FAIL SEQ #63) slot_idx
# 723:
    \&token_range_char,            1,                        # set_match
    \&test_match,                  728, 713,                 # ok fail
# 728:
    \&var_set_op,                  59, 0,                    # <<end>> op:=
    \&jump,                        648,                      # next
# 733:
    \&goto_bt,                     8,                        # (FAIL SEQ #64) slot_idx
# 735:
    \&token_range_char,            1,                        # set_match
    \&test_match,                  740, 713,                 # ok fail
# 740:
    \&var_set_op,                  57, 0,                    # <<start>> op:=
    \&jump,                        624,                      # next
# 745:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # const_args [746]
    #--------------------------------------------------------------------------------
    \&rule_start,                  63, 3,                    # <<const_args>> slot_count
    \&set_bt,                      0,                        # (START SEQ #90) slot_idx
    \&literal_test,                49,                       # <<[>>
    \&test_match,                  756, 804,                 # ok fail
# 756:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #91) slot_idx
# 760:
    \&set_bt,                      2,                        # slot_idx
    \&rule_match,                  3007, 796, 766,           # string_const ok fail
# 766:
    \&rule_match,                  1419, 796, 770,           # int_const ok fail
# 770:
    \&rule_match,                  1705, 796, 774,           # literal_var_ref ok fail
# 774:
    \&var_set_const,               2, 0, undef,              # <<*match_value*>> op:=
    \&goto_bt,                     2,                        # slot_idx
    \&literal_test,                50,                       # <<]>>
    \&test_match,                  785, 792,                 # ok fail
# 785:
    \&token_ws,                    0,                        # set_match
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 792:
    \&goto_bt,                     1,                        # (FAIL SEQ #91) slot_idx
    \&fatal,                       [ 'expected [(<string const>|<int const>|<var ref>)*]' ], 
# 796:
    \&var_set_op,                  1, 3,                     # <<*0>> op:<<
    \&token_ws,                    0,                        # set_match
    \&test_match,                  760, 760,                 # ok fail
# 804:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # custom_match [805]
    #--------------------------------------------------------------------------------
    \&rule_start,                  64, 1,                    # <<custom_match>> slot_count
    \&set_rule_vars,               { match_args => undef, match_name => undef, node_type => undef, quantifier => undef }, 
    \&set_bt,                      0,                        # (START SEQ #73) slot_idx
    \&token_name,                  1,                        # set_match
    \&test_match,                  817, 845,                 # ok fail
# 817:
    \&var_set_op,                  5, 0,                     # <<match_name>> op:=
    \&var_set_const,               4, 0, 'custom_match',     # <<node_type>> op:=
    \&rule_match,                  746, 840, 828,            # const_args ok fail
# 828:
    \&token_ext_quantifier,        1,                        # set_match
    \&test_match,                  833, 836,                 # ok fail
# 833:
    \&var_set_op,                  46, 0,                    # <<quantifier>> op:=
# 836:
    \&token_ws,                    0,                        # set_match
    \&pkg_return,                  65,                       # <<WW::ParserGen::PDA::AST::CustomMatch>>
# 840:
    \&var_set_op,                  66, 0,                    # <<match_args>> op:=
    \&jump,                        828,                      # next
# 845:
    \&fatal,                       [ 'expected &<name>[ (<int const>|<string_ const>)* ]' ], 

    #--------------------------------------------------------------------------------
    # custom_match_def [847]
    #--------------------------------------------------------------------------------
    \&rule_start,                  67, 2,                    # <<custom_match_def>> slot_count
    \&set_rule_vars,               { arg_types => undef, code => undef, match_name => undef, node_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #100) slot_idx
    \&literal_test,                68,                       # <<@match>>
    \&test_match,                  859, 895,                 # ok fail
# 859:
    \&token_ws,                    0,                        # set_match
    \&test_match,                  864, 893,                 # ok fail
# 864:
    \&set_bt,                      1,                        # (START SEQ #101) slot_idx
    \&token_name,                  1,                        # set_match
    \&test_match,                  871, 891,                 # ok fail
# 871:
    \&var_set_op,                  5, 0,                     # <<match_name>> op:=
    \&token_ws,                    0,                        # set_match
    \&var_set_const,               4, 0, 'custom_match_def', 
                                                             # <<node_type>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                27,                       # <<.>>
    \&test_match,                  887, 889,                 # ok fail
# 887:
    \&pkg_return,                  11,                       # <<WW::ParserGen::PDA::AST::CustomMatchDef>>
# 889:
    \&goto_bt,                     1,                        # (FAIL SEQ #101) slot_idx
# 891:
    \&fatal,                       [ "expected \@match <name>." ], 
# 893:
    \&goto_bt,                     0,                        # (FAIL SEQ #100) slot_idx
# 895:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # debug_break [896]
    #--------------------------------------------------------------------------------
    \&rule_start,                  69, 2,                    # <<debug_break>> slot_count
    \&set_rule_vars,               { message => undef, node_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #15) slot_idx
    \&literal_test,                70,                       # <<debug_break[>>
    \&test_match,                  908, 943,                 # ok fail
# 908:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #16) slot_idx
    \&var_set_const,               4, 0, 'debug_break_op',   # <<node_type>> op:=
    \&rule_match,                  3007, 924, 920,           # string_const ok fail
# 920:
    \&goto_bt,                     1,                        # (FAIL SEQ #16) slot_idx
    \&fatal,                       [ 'expected &&debug_break[ <string const> ]' ], 
# 924:
    \&get_const_value,             undef,                   
    \&test_match,                  929, 920,                 # ok fail
# 929:
    \&var_set_op,                  71, 0,                    # <<message>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                50,                       # <<]>>
    \&test_match,                  939, 920,                 # ok fail
# 939:
    \&token_ws,                    0,                        # set_match
    \&pkg_return,                  72,                       # <<WW::ParserGen::PDA::AST::DebugBreakOp>>
# 943:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # digit_const [944]
    #--------------------------------------------------------------------------------
    \&rule_start,                  73, 1,                    # <<digit_const>> slot_count
    \&set_rule_vars,               { node_type => undef, value => undef, value_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #68) slot_idx
    \&regex4,                      4,                        # <<m/\G([0-9])/gc>>
    \&test_match,                  956, 969,                 # ok fail
# 956:
    \&var_set_op,                  42, 0,                    # <<value>> op:=
    \&var_set_const,               51, 0, 'Int',             # <<value_type>> op:=
    \&var_set_const,               4, 0, 'const_value',      # <<node_type>> op:=
    \&pkg_return,                  52,                       # <<WW::ParserGen::PDA::AST::ConstValue>>
# 969:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # expr_op [970]
    #--------------------------------------------------------------------------------
    \&rule_start,                  74, 2,                    # <<expr_op>> slot_count
    \&set_rule_vars,               { node_type => undef, op_table_name => undef }, 
    \&set_bt,                      0,                        # (START SEQ #102) slot_idx
    \&literal_test,                75,                       # <<infix_operator[>>
    \&test_match,                  982, 1011,                # ok fail
# 982:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #103) slot_idx
    \&var_set_const,               4, 0, 'expr_op',          # <<node_type>> op:=
    \&token_name,                  1,                        # set_match
    \&test_match,                  995, 1007,                # ok fail
# 995:
    \&var_set_op,                  76, 0,                    # <<op_table_name>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                50,                       # <<]>>
    \&test_match,                  1005, 1007,               # ok fail
# 1005:
    \&pkg_return,                  77,                       # <<WW::ParserGen::PDA::AST::ExprOp>>
# 1007:
    \&goto_bt,                     1,                        # (FAIL SEQ #103) slot_idx
    \&fatal,                       [ 'expected &&infix_operator[<op-table-name>]' ], 
# 1011:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # expr_op_right_arg [1012]
    #--------------------------------------------------------------------------------
    \&rule_start,                  78, 1,                    # <<expr_op_right_arg>> slot_count
    \&set_rule_vars,               { node_type => undef },  
    \&set_bt,                      0,                        # (START SEQ #129) slot_idx
    \&literal_test,                79,                       # <<infix_operator_arg>>
    \&test_match,                  1024, 1037,               # ok fail
# 1024:
    \&regex5,                      5,                        # <<m/\G[_a-zA-Z0-9]/gc>>
    \&not_match,                   1029, 1035,               # ok fail
# 1029:
    \&var_set_const,               4, 0, 'expr_op_right_arg', 
                                                             # <<node_type>> op:=
    \&pkg_return,                  80,                       # <<WW::ParserGen::PDA::AST::ExprOpRightArg>>
# 1035:
    \&goto_bt,                     0,                        # (FAIL SEQ #129) slot_idx
# 1037:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # expr_tree [1038]
    #--------------------------------------------------------------------------------
    \&rule_start,                  81, 1,                    # <<expr_tree>> slot_count
    \&set_rule_vars,               { node_type => undef },  
    \&set_bt,                      0,                        # (START SEQ #133) slot_idx
    \&literal_test,                82,                       # <<infix_expr_tree>>
    \&test_match,                  1050, 1063,               # ok fail
# 1050:
    \&regex5,                      5,                        # <<m/\G[_a-zA-Z0-9]/gc>>
    \&not_match,                   1055, 1061,               # ok fail
# 1055:
    \&var_set_const,               4, 0, 'expr_tree',        # <<node_type>> op:=
    \&pkg_return,                  83,                       # <<WW::ParserGen::PDA::AST::ExprTree>>
# 1061:
    \&goto_bt,                     0,                        # (FAIL SEQ #133) slot_idx
# 1063:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # fail [1064]
    #--------------------------------------------------------------------------------
    \&rule_start,                  84, 1,                    # <<fail>> slot_count
    \&set_rule_vars,               { node_type => undef },  
    \&set_bt,                      0,                        # (START SEQ #22) slot_idx
    \&literal_test,                84,                       # <<fail>>
    \&test_match,                  1076, 1091,               # ok fail
# 1076:
    \&regex5,                      5,                        # <<m/\G[_a-zA-Z0-9]/gc>>
    \&not_match,                   1081, 1089,               # ok fail
# 1081:
    \&token_ws,                    0,                        # set_match
    \&var_set_const,               4, 0, 'fail',             # <<node_type>> op:=
    \&pkg_return,                  85,                       # <<WW::ParserGen::PDA::AST::Fail>>
# 1089:
    \&goto_bt,                     0,                        # (FAIL SEQ #22) slot_idx
# 1091:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # fatal [1092]
    #--------------------------------------------------------------------------------
    \&rule_start,                  86, 2,                    # <<fatal>> slot_count
    \&set_rule_vars,               { msg_params => undef, node_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #134) slot_idx
    \&literal_test,                86,                       # <<fatal>>
    \&test_match,                  1104, 1127,               # ok fail
# 1104:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #135) slot_idx
    \&var_set_const,               4, 0, 'fatal',            # <<node_type>> op:=
    \&rule_match,                  746, 1120, 1116,          # const_args ok fail
# 1116:
    \&goto_bt,                     1,                        # (FAIL SEQ #135) slot_idx
    \&fatal,                       [ "expected &&fatal[(<int_const>|<string_const>|\$\$r<digit>|\$\$|\$\$offset|\$<name>)*" ], 
# 1120:
    \&var_set_op,                  87, 0,                    # <<msg_params>> op:=
    \&token_ws,                    0,                        # set_match
    \&pkg_return,                  88,                       # <<WW::ParserGen::PDA::AST::Fatal>>
# 1127:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # hash_const [1128]
    #--------------------------------------------------------------------------------
    \&rule_start,                  89, 1,                    # <<hash_const>> slot_count
    \&set_rule_vars,               { node_type => undef, value => undef, value_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #36) slot_idx
    \&literal_test,                8,                        # <<{>>
    \&test_match,                  1140, 1163,               # ok fail
# 1140:
    \&token_ws,                    0,                        # set_match
    \&literal_test,                10,                       # <<}>>
    \&test_match,                  1147, 1161,               # ok fail
# 1147:
    \&var_set_const,               42, 0, {  },              # <<value>> op:=
    \&var_set_const,               51, 0, 'Hash',            # <<value_type>> op:=
    \&var_set_const,               4, 0, 'const_value',      # <<node_type>> op:=
    \&pkg_return,                  52,                       # <<WW::ParserGen::PDA::AST::ConstValue>>
# 1161:
    \&goto_bt,                     0,                        # (FAIL SEQ #36) slot_idx
# 1163:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # if_false [1164]
    #--------------------------------------------------------------------------------
    \&rule_start,                  90, 2,                    # <<if_false>> slot_count
    \&set_rule_vars,               { node_type => undef, var_refs => undef }, 
    \&set_bt,                      0,                        # (START SEQ #114) slot_idx
    \&literal_test,                91,                       # <<if_false[>>
    \&test_match,                  1176, 1204,               # ok fail
# 1176:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #115) slot_idx
    \&var_set_const,               4, 0, 'if_false',         # <<node_type>> op:=
    \&rule_match,                  3542, 1192, 1188,         # var_refs ok fail
# 1188:
    \&goto_bt,                     1,                        # (FAIL SEQ #115) slot_idx
    \&fatal,                       [ 'expected &&if_false[ <var_ref>+ ]' ], 
# 1192:
    \&var_set_op,                  92, 0,                    # <<var_refs>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                50,                       # <<]>>
    \&test_match,                  1202, 1188,               # ok fail
# 1202:
    \&pkg_return,                  93,                       # <<WW::ParserGen::PDA::AST::IfTest>>
# 1204:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # if_true [1205]
    #--------------------------------------------------------------------------------
    \&rule_start,                  94, 2,                    # <<if_true>> slot_count
    \&set_rule_vars,               { node_type => undef, var_refs => undef }, 
    \&set_bt,                      0,                        # (START SEQ #86) slot_idx
    \&literal_test,                95,                       # <<if_true[>>
    \&test_match,                  1217, 1245,               # ok fail
# 1217:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #87) slot_idx
    \&var_set_const,               4, 0, 'if_true',          # <<node_type>> op:=
    \&rule_match,                  3542, 1233, 1229,         # var_refs ok fail
# 1229:
    \&goto_bt,                     1,                        # (FAIL SEQ #87) slot_idx
    \&fatal,                       [ 'expected &&if_true[ <var_ref>+ ]' ], 
# 1233:
    \&var_set_op,                  92, 0,                    # <<var_refs>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                50,                       # <<]>>
    \&test_match,                  1243, 1229,               # ok fail
# 1243:
    \&pkg_return,                  93,                       # <<WW::ParserGen::PDA::AST::IfTest>>
# 1245:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # infix_op_info [1246]
    #--------------------------------------------------------------------------------
    \&rule_start,                  96, 8,                    # <<infix_op_info>> slot_count
    \&set_rule_vars,               { assoc => undef, constructor_op => undef, operator => undef, precedence => undef }, 
    \&set_bt,                      0,                        # (START SEQ #106) slot_idx
    \&set_bt,                      7,                        # (START SEQ #113) slot_idx
    \&rule_match,                  2101, 1261, 1259,         # operator_string ok fail
# 1259:
    \&fatal,                       [ "expected \"<operator>\"" ], 
# 1261:
    \&var_set_op,                  97, 0,                    # <<operator>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      4,                        # (START SEQ #110) slot_idx
    \&set_bt,                      6,                        # (START SEQ #112) slot_idx
    \&literal_test,                98,                       # <<left>>
    \&test_match,                  1275, 1324,               # ok fail
# 1275:
    \&var_set_const,               99, 0, -1,                # <<assoc>> op:=
# 1279:
    \&token_ws,                    0,                        # set_match
    \&test_match,                  1284, 1320,               # ok fail
# 1284:
    \&set_bt,                      3,                        # (START SEQ #109) slot_idx
    \&regex6,                      6,                        # <<m/\G([0-9]+)/gc>>
    \&test_match,                  1291, 1318,               # ok fail
# 1291:
    \&var_set_op,                  100, 0,                   # <<precedence>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #107) slot_idx
    \&literal_test,                101,                      # <<&>>
    \&test_match,                  1303, 1315,               # ok fail
# 1303:
    \&set_bt,                      2,                        # (START SEQ #108) slot_idx
    \&token_name,                  1,                        # set_match
    \&test_match,                  1310, 1316,               # ok fail
# 1310:
    \&var_set_op,                  102, 0,                   # <<constructor_op>> op:=
    \&token_ws,                    0,                        # set_match
# 1315:
    \&hash_return,                                          
# 1316:
    \&fatal,                       [ 'expected &<constructor-op-name>' ], 
# 1318:
    \&fatal,                       [ 'expected <precedence-int>' ], 
# 1320:
    \&goto_bt,                     4,                        # (FAIL SEQ #110) slot_idx
# 1322:
    \&fatal,                       [ 'expected left | right' ], 
# 1324:
    \&set_bt,                      5,                        # (START SEQ #111) slot_idx
    \&literal_test,                103,                      # <<right>>
    \&test_match,                  1331, 1322,               # ok fail
# 1331:
    \&var_set_const,               99, 0, 1,                 # <<assoc>> op:=
    \&jump,                        1279,                     # next

    #--------------------------------------------------------------------------------
    # infix_op_table [1337]
    #--------------------------------------------------------------------------------
    \&rule_start,                  104, 4,                   # <<infix_op_table>> slot_count
    \&set_rule_vars,               { name => undef, node_type => undef, operators => undef }, 
    \&set_bt,                      0,                        # (START SEQ #6) slot_idx
    \&literal_test,                105,                      # <<@infix_operators>>
    \&test_match,                  1349, 1418,               # ok fail
# 1349:
    \&token_ws,                    0,                        # set_match
    \&token_name,                  1,                        # set_match
    \&test_match,                  1356, 1416,               # ok fail
# 1356:
    \&var_set_op,                  106, 0,                   # <<name>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                8,                        # <<{>>
    \&test_match,                  1366, 1416,               # ok fail
# 1366:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #7) slot_idx
    \&var_set_const,               4, 0, 'infix_op_table',   # <<node_type>> op:=
    \&set_iter_slot,               3, 0,                     # slot_idx value
# 1377:
    \&set_bt,                      2,                        # slot_idx
    \&literal_test,                10,                       # <<}>>
    \&not_match,                   1384, 1388,               # ok fail
# 1384:
    \&rule_match,                  1246, 1408, 1388,         # infix_op_info ok fail
# 1388:
    \&goto_bt,                     2,                        # slot_idx
    \&gt_iter_slot,                3, 0, 1395, 1404,         # slot_idx value ok fail
# 1395:
    \&literal_test,                10,                       # <<}>>
    \&test_match,                  1400, 1402,               # ok fail
# 1400:
    \&pkg_return,                  107,                      # <<WW::ParserGen::PDA::AST::InfixOpTable>>
# 1402:
    \&fatal,                       [ 'missing closing } in infix op table ', "\$name" ], 
# 1404:
    \&goto_bt,                     1,                        # (FAIL SEQ #7) slot_idx
    \&fatal,                       [ "expected \"<operator>\" (left|right) <precdence-int> (&<constructor-op-name>)?" ], 
# 1408:
    \&var_set_op,                  108, 3,                   # <<operators>> op:<<
    \&add_iter_slot,               3, 1,                     # slot_idx value
    \&jump,                        1377,                     # next
# 1416:
    \&goto_bt,                     0,                        # (FAIL SEQ #6) slot_idx
# 1418:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # int_const [1419]
    #--------------------------------------------------------------------------------
    \&rule_start,                  109, 1,                   # <<int_const>> slot_count
    \&set_rule_vars,               { node_type => undef, value => undef, value_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #72) slot_idx
    \&regex7,                      7,                        # <<m/\G([-+]?\d+)/gc>>
    \&test_match,                  1431, 1444,               # ok fail
# 1431:
    \&var_set_op,                  42, 0,                    # <<value>> op:=
    \&var_set_const,               51, 0, 'Int',             # <<value_type>> op:=
    \&var_set_const,               4, 0, 'const_value',      # <<node_type>> op:=
    \&pkg_return,                  52,                       # <<WW::ParserGen::PDA::AST::ConstValue>>
# 1444:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # key_match [1445]
    #--------------------------------------------------------------------------------
    \&rule_start,                  110, 7,                   # <<key_match>> slot_count
    \&set_rule_vars,               { key_match_list => undef, node_type => undef, quantifier => undef }, 
    \&set_bt,                      0,                        # (START SEQ #122) slot_idx
    \&literal_test,                110,                      # <<key_match>>
    \&test_match,                  1457, 1597,               # ok fail
# 1457:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #123) slot_idx
    \&literal_test,                8,                        # <<{>>
    \&test_match,                  1466, 1595,               # ok fail
# 1466:
    \&token_ws,                    0,                        # set_match
    \&var_set_const,               4, 0, 'key_match',        # <<node_type>> op:=
    \&set_bt,                      2,                        # (START SEQ #124) slot_idx
    \&token_name,                  1,                        # set_match
    \&test_match,                  1479, 1585,               # ok fail
# 1479:
    \&var_set_op,                  111, 3,                   # <<key_match_list>> op:<<
    \&token_ws,                    0,                        # set_match
    \&literal_test,                112,                      # <<=>>>
    \&test_match,                  1489, 1581,               # ok fail
# 1489:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      6,                        # (START SEQ #127) slot_idx
    \&rule_match,                  2942, 1499, 1497,         # sequence_match ok fail
# 1497:
    \&fatal,                       [ 'expected => <match>' ], 
# 1499:
    \&var_set_op,                  111, 3,                   # <<key_match_list>> op:<<
    \&token_ws,                    0,                        # set_match
# 1504:
    \&set_bt,                      3,                        # slot_idx
    \&literal_test,                113,                      # <<|>>
    \&test_match,                  1511, 1562,               # ok fail
# 1511:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      4,                        # (START SEQ #125) slot_idx
    \&token_name,                  1,                        # set_match
    \&test_match,                  1520, 1552,               # ok fail
# 1520:
    \&var_set_op,                  111, 3,                   # <<key_match_list>> op:<<
    \&token_ws,                    0,                        # set_match
    \&literal_test,                112,                      # <<=>>>
    \&test_match,                  1530, 1548,               # ok fail
# 1530:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      5,                        # (START SEQ #126) slot_idx
    \&rule_match,                  2942, 1540, 1538,         # sequence_match ok fail
# 1538:
    \&fatal,                       [ 'expected => <match>' ], 
# 1540:
    \&var_set_op,                  111, 3,                   # <<key_match_list>> op:<<
    \&token_ws,                    0,                        # set_match
    \&test_match,                  1504, 1504,               # ok fail
# 1548:
    \&goto_bt,                     4,                        # (FAIL SEQ #125) slot_idx
# 1550:
    \&fatal,                       [ 'expected | <name>|string-const> => <match>' ], 
# 1552:
    \&rule_match,                  122, 1520, 1556,          # _string_value ok fail
# 1556:
    \&var_set_const,               2, 0, undef,              # <<*match_value*>> op:=
    \&jump,                        1550,                     # next
# 1562:
    \&goto_bt,                     3,                        # slot_idx
# 1564:
    \&literal_test,                10,                       # <<}>>
    \&test_match,                  1569, 1579,               # ok fail
# 1569:
    \&token_std_quantifier,        1,                        # set_match
    \&test_match,                  1574, 1577,               # ok fail
# 1574:
    \&var_set_op,                  46, 0,                    # <<quantifier>> op:=
# 1577:
    \&pkg_return,                  114,                      # <<WW::ParserGen::PDA::AST::KeyMatch>>
# 1579:
    \&fatal,                       [ 'missing closing } in &&key_match' ], 
# 1581:
    \&goto_bt,                     2,                        # (FAIL SEQ #124) slot_idx
    \&jump,                        1564,                     # next
# 1585:
    \&rule_match,                  122, 1479, 1589,          # _string_value ok fail
# 1589:
    \&var_set_const,               2, 0, undef,              # <<*match_value*>> op:=
    \&jump,                        1564,                     # next
# 1595:
    \&fatal,                       [ 'expected &&key_match { <name>|<string-const> => <match> | <name>|<string-const> => <match> }<quantifier>?' ], 
# 1597:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # literal_match [1598]
    #--------------------------------------------------------------------------------
    \&rule_start,                  115, 7,                   # <<literal_match>> slot_count
    \&set_rule_vars,               { code_point => undef, match_text => undef, node_type => undef, quantifier => undef }, 
    \&set_bt,                      0,                        # (START SEQ #39) slot_idx
    \&set_bt,                      3,                        # (START SEQ #42) slot_idx
    \&literal_test,                18,                       # <<'>>
    \&test_match,                  1612, 1672,               # ok fail
# 1612:
    \&set_bt,                      4,                        # (START SEQ #43) slot_idx
# 1614:
    \&set_bt,                      5,                        # slot_idx
    \&set_bt,                      6,                        # (START SEQ #44) slot_idx
    \&literal_test,                19,                       # <<\>>
    \&test_match,                  1623, 1635,               # ok fail
# 1623:
    \&regex8,                      8,                        # <<m/\G(.)/gc>>
    \&test_match,                  1628, 1633,               # ok fail
# 1628:
    \&var_set_op,                  116, 2,                   # <<match_text>> op:+=
    \&jump,                        1614,                     # next
# 1633:
    \&goto_bt,                     6,                        # (FAIL SEQ #44) slot_idx
# 1635:
    \&regex9,                      9,                        # <<m/\G([^\x0A\x0D'\\]+)/gc>>
    \&test_match,                  1640, 1645,               # ok fail
# 1640:
    \&var_set_op,                  116, 2,                   # <<match_text>> op:+=
    \&jump,                        1614,                     # next
# 1645:
    \&goto_bt,                     5,                        # slot_idx
    \&literal_test,                18,                       # <<'>>
    \&test_match,                  1652, 1668,               # ok fail
# 1652:
    \&var_set_const,               4, 0, 'literal_match',    # <<node_type>> op:=
    \&token_ext_quantifier,        1,                        # set_match
    \&test_match,                  1661, 1664,               # ok fail
# 1661:
    \&var_set_op,                  46, 0,                    # <<quantifier>> op:=
# 1664:
    \&token_ws,                    0,                        # set_match
    \&pkg_return,                  117,                      # <<WW::ParserGen::PDA::AST::LiteralMatch>>
# 1668:
    \&goto_bt,                     4,                        # (FAIL SEQ #43) slot_idx
    \&fatal,                       [ 'missing closing quote (\') in literal match' ], 
# 1672:
    \&set_bt,                      1,                        # (START SEQ #40) slot_idx
    \&literal_test,                41,                       # <<0x>>
    \&test_match,                  1679, 1704,               # ok fail
# 1679:
    \&set_bt,                      2,                        # (START SEQ #41) slot_idx
    \&var_set_const,               116, 0, '',               # <<match_text>> op:=
    \&token_hex_code_point,        1,                        # set_match
    \&test_match,                  1690, 1700,               # ok fail
# 1690:
    \&var_set_op,                  118, 0,                   # <<code_point>> op:=
    \&regex10,                     10,                       # <<m/\G[a-zA-Z]/gc>>
    \&not_match,                   1652, 1698,               # ok fail
# 1698:
    \&fatal,                       [ 'invalid chars after 0x<hex-digits>' ], 
# 1700:
    \&goto_bt,                     2,                        # (FAIL SEQ #41) slot_idx
    \&fatal,                       [ 'expected 0x<hex-digits>' ], 
# 1704:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # literal_var_ref [1705]
    #--------------------------------------------------------------------------------
    \&rule_start,                  119, 2,                   # <<literal_var_ref>> slot_count
    \&set_bt,                      0,                        # (START SEQ #66) slot_idx
    \&literal_match,               32,                       # <<$>>
    \&test_match,                  1715, 1785,               # ok fail
# 1715:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
    \&literal_match,               36,                       # <<$rule_vars>>
    \&test_match,                  1723, 1731,               # ok fail
# 1723:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
# 1726:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 1731:
    \&set_bt,                      1,                        # (START SEQ #67) slot_idx
    \&literal_match,               37,                       # <<$r>>
    \&test_match,                  1738, 1753,               # ok fail
# 1738:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
    \&regex2,                      2,                        # <<m/\G(\d)/gc>>
    \&test_match,                  1746, 1751,               # ok fail
# 1746:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
    \&jump,                        1726,                     # next
# 1751:
    \&fatal,                       [ "expected \$\$r<0-9>" ], 
# 1753:
    \&literal_match,               38,                       # <<$offset>>
    \&test_match,                  1758, 1763,               # ok fail
# 1758:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
    \&jump,                        1726,                     # next
# 1763:
    \&literal_match,               32,                       # <<$>>
    \&test_match,                  1768, 1773,               # ok fail
# 1768:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
    \&jump,                        1726,                     # next
# 1773:
    \&regex3,                      3,                        # <<m/\G([_a-zA-Z][_a-zA-Z0-9]*)/gc>>
    \&test_match,                  1778, 1783,               # ok fail
# 1778:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
    \&jump,                        1726,                     # next
# 1783:
    \&fatal,                       [ "expected \$\$r<0-9> or \$\$offset or \$\$ or \$<name>" ], 
# 1785:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # make_match_list [1786]
    #--------------------------------------------------------------------------------
    \&rule_start,                  120, 1,                   # <<make_match_list>> slot_count
    \&set_rule_vars,               { match_list => undef, node_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #17) slot_idx
    \&var_move,                    4, 0, 121,                # <<node_type>> op:= <<*2>>
    \&var_move,                    13, 3, 1,                 # <<match_list>> op:<< <<*0>>
    \&var_move,                    13, 4, 7,                 # <<match_list>> op:<<< <<*1>>
    \&pkg_return,                  122,                      # <<WW::ParserGen::PDA::AST::MatchList>>

    #--------------------------------------------------------------------------------
    # match [1807]
    #--------------------------------------------------------------------------------
    \&rule_start,                  45, 4,                    # <<match>> slot_count
    \&set_bt,                      0,                        # (START SEQ #23) slot_idx
    \&rule_match,                  2942, 1816, 1875,         # sequence_match ok fail
# 1816:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #24) slot_idx
    \&set_iter_slot,               3, 0,                     # slot_idx value
# 1826:
    \&set_bt,                      2,                        # slot_idx
    \&literal_test,                113,                      # <<|>>
    \&test_match,                  1833, 1851,               # ok fail
# 1833:
    \&token_ws,                    0,                        # set_match
    \&rule_match,                  2942, 1841, 1839,         # sequence_match ok fail
# 1839:
    \&fatal,                       [ 'missing <match> after |' ], 
# 1841:
    \&var_set_op,                  7, 3,                     # <<*1>> op:<<
    \&token_ws,                    0,                        # set_match
    \&add_iter_slot,               3, 1,                     # slot_idx value
    \&jump,                        1826,                     # next
# 1851:
    \&goto_bt,                     2,                        # slot_idx
    \&gt_iter_slot,                3, 0, 1858, 1866,         # slot_idx value ok fail
# 1858:
    \&rule_call,                   80, 1863, 1871, [ 0, 1 ], 
                                                             # _make_first_match ok fail
# 1863:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
# 1866:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 1871:
    \&goto_bt,                     1,                        # (FAIL SEQ #24) slot_idx
    \&jump,                        1866,                     # next
# 1875:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # match_atom [1876]
    #--------------------------------------------------------------------------------
    \&rule_start,                  123, 3,                   # <<match_atom>> slot_count
    \&rule_match,                  1598, 2003, 1883,         # literal_match ok fail
# 1883:
    \&rule_match,                  2220, 2003, 1887,         # regex_match ok fail
# 1887:
    \&rule_match,                  2851, 2003, 1891,         # rule_match ok fail
# 1891:
    \&set_bt,                      1,                        # (START SEQ #13) slot_idx
    \&literal_match,               101,                      # <<&>>
    \&test_match,                  1898, 1965,               # ok fail
# 1898:
    \&set_bt,                      2,                        # (START SEQ #14) slot_idx
    \&literal_match,               101,                      # <<&>>
    \&test_match,                  1905, 1955,               # ok fail
# 1905:
    \&rule_match,                  2529, 2003, 1909,         # rule_call ok fail
# 1909:
    \&rule_match,                  3366, 2003, 1913,         # trace_flags ok fail
# 1913:
    \&rule_match,                  896, 2003, 1917,          # debug_break ok fail
# 1917:
    \&rule_match,                  1064, 2003, 1921,         # fail ok fail
# 1921:
    \&rule_match,                  1092, 2003, 1925,         # fatal ok fail
# 1925:
    \&rule_match,                  1205, 2003, 1929,         # if_true ok fail
# 1929:
    \&rule_match,                  1164, 2003, 1933,         # if_false ok fail
# 1933:
    \&rule_match,                  970, 2003, 1937,          # expr_op ok fail
# 1937:
    \&rule_match,                  1012, 2003, 1941,         # expr_op_right_arg ok fail
# 1941:
    \&rule_match,                  1038, 2003, 1945,         # expr_tree ok fail
# 1945:
    \&rule_match,                  1445, 2003, 1949,         # key_match ok fail
# 1949:
    \&var_set_const,               2, 0, undef,              # <<*match_value*>> op:=
    \&goto_bt,                     2,                        # (FAIL SEQ #14) slot_idx
# 1955:
    \&rule_match,                  805, 2003, 1959,          # custom_match ok fail
# 1959:
    \&var_set_const,               2, 0, undef,              # <<*match_value*>> op:=
    \&goto_bt,                     1,                        # (FAIL SEQ #13) slot_idx
# 1965:
    \&set_bt,                      0,                        # (START SEQ #12) slot_idx
    \&literal_match,               32,                       # <<$>>
    \&test_match,                  1972, 1994,               # ok fail
# 1972:
    \&rule_match,                  250, 2003, 1976,          # _var_assign ok fail
# 1976:
    \&rule_match,                  375, 2003, 1980,          # _var_set_const ok fail
# 1980:
    \&rule_match,                  455, 2003, 1984,          # _var_set_match ok fail
# 1984:
    \&rule_match,                  3537, 2003, 1988,         # var_ref_error ok fail
# 1988:
    \&var_set_const,               2, 0, undef,              # <<*match_value*>> op:=
    \&goto_bt,                     0,                        # (FAIL SEQ #12) slot_idx
# 1994:
    \&rule_match,                  2004, 2003, 1998,         # match_group ok fail
# 1998:
    \&var_set_const,               2, 0, undef,              # <<*match_value*>> op:=
    \&fail_return,                                          
# 2003:
    \&ok_return,                                            

    #--------------------------------------------------------------------------------
    # match_group [2004]
    #--------------------------------------------------------------------------------
    \&rule_start,                  124, 2,                   # <<match_group>> slot_count
    \&set_bt,                      0,                        # (START SEQ #20) slot_idx
    \&literal_test,                125,                      # <<(>>
    \&test_match,                  2014, 2056,               # ok fail
# 2014:
    \&token_ws,                    0,                        # set_match
    \&rule_match,                  1807, 2020, 2054,         # match ok fail
# 2020:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #21) slot_idx
    \&literal_test,                126,                      # <<)>>
    \&test_match,                  2032, 2052,               # ok fail
# 2032:
    \&token_ws,                    0,                        # set_match
    \&token_std_quantifier,        1,                        # set_match
    \&test_match,                  2039, 2042,               # ok fail
# 2039:
    \&var_set_op,                  7, 0,                     # <<*1>> op:=
# 2042:
    \&token_ws,                    0,                        # set_match
    \&make_group_match,            undef,                   
    \&test_match,                  2049, 2050,               # ok fail
# 2049:
    \&ok_return,                                            
# 2050:
    \&fatal,                       [ 'multiple quantifiers on group not supported' ], 
# 2052:
    \&fatal,                       [ 'missing closing ) in match group' ], 
# 2054:
    \&goto_bt,                     0,                        # (FAIL SEQ #20) slot_idx
# 2056:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # node_package_prefix [2057]
    #--------------------------------------------------------------------------------
    \&rule_start,                  127, 2,                   # <<node_package_prefix>> slot_count
    \&set_bt,                      0,                        # (START SEQ #4) slot_idx
    \&literal_test,                128,                      # <<@node_package_prefix>>
    \&test_match,                  2067, 2100,               # ok fail
# 2067:
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2072, 2098,               # ok fail
# 2072:
    \&set_bt,                      1,                        # (START SEQ #5) slot_idx
    \&token_fq_package,            1,                        # set_match
    \&test_match,                  2079, 2096,               # ok fail
# 2079:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                27,                       # <<.>>
    \&test_match,                  2089, 2094,               # ok fail
# 2089:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 2094:
    \&goto_bt,                     1,                        # (FAIL SEQ #5) slot_idx
# 2096:
    \&fatal,                       [ "expected \@node_package_prefix <fq_package>." ], 
# 2098:
    \&goto_bt,                     0,                        # (FAIL SEQ #4) slot_idx
# 2100:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # operator_string [2101]
    #--------------------------------------------------------------------------------
    \&rule_start,                  129, 5,                   # <<operator_string>> slot_count
    \&set_bt,                      0,                        # (START SEQ #31) slot_idx
    \&literal_test,                130,                      # <<">>
    \&test_match,                  2111, 2175,               # ok fail
# 2111:
    \&var_set_const,               1, 0, '',                 # <<*0>> op:=
    \&set_bt,                      1,                        # (START SEQ #32) slot_idx
    \&set_iter_slot,               3, 0,                     # slot_idx value
# 2120:
    \&set_bt,                      2,                        # slot_idx
    \&set_bt,                      4,                        # (START SEQ #33) slot_idx
    \&regex11,                     11,                       # <<m/\G[\\]/gc>>
    \&test_match,                  2129, 2144,               # ok fail
# 2129:
    \&regex8,                      8,                        # <<m/\G(.)/gc>>
    \&test_match,                  2134, 2142,               # ok fail
# 2134:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
# 2137:
    \&add_iter_slot,               3, 1,                     # slot_idx value
    \&jump,                        2120,                     # next
# 2142:
    \&goto_bt,                     4,                        # (FAIL SEQ #33) slot_idx
# 2144:
    \&regex12,                     12,                       # <<m/\G([^"\\]+)/gc>>
    \&test_match,                  2149, 2154,               # ok fail
# 2149:
    \&var_set_op,                  1, 2,                     # <<*0>> op:+=
    \&jump,                        2137,                     # next
# 2154:
    \&goto_bt,                     2,                        # slot_idx
    \&gt_iter_slot,                3, 0, 2161, 2173,         # slot_idx value ok fail
# 2161:
    \&literal_test,                130,                      # <<">>
    \&test_match,                  2166, 2171,               # ok fail
# 2166:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 2171:
    \&goto_bt,                     1,                        # (FAIL SEQ #32) slot_idx
# 2173:
    \&fatal,                       [ "missing closing quote (\") in operator string" ], 
# 2175:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # parser_package [2176]
    #--------------------------------------------------------------------------------
    \&rule_start,                  131, 2,                   # <<parser_package>> slot_count
    \&set_bt,                      0,                        # (START SEQ #0) slot_idx
    \&literal_test,                132,                      # <<@package>>
    \&test_match,                  2186, 2219,               # ok fail
# 2186:
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2191, 2217,               # ok fail
# 2191:
    \&set_bt,                      1,                        # (START SEQ #1) slot_idx
    \&token_fq_package,            1,                        # set_match
    \&test_match,                  2198, 2215,               # ok fail
# 2198:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                27,                       # <<.>>
    \&test_match,                  2208, 2213,               # ok fail
# 2208:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 2213:
    \&goto_bt,                     1,                        # (FAIL SEQ #1) slot_idx
# 2215:
    \&fatal,                       [ "expected \@package <fq_package>." ], 
# 2217:
    \&goto_bt,                     0,                        # (FAIL SEQ #0) slot_idx
# 2219:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # regex_match [2220]
    #--------------------------------------------------------------------------------
    \&rule_start,                  133, 18,                  # <<regex_match>> slot_count
    \&set_rule_vars,               { delimiter => undef, node_type => undef, quantifier => undef, regex => undef }, 
    \&set_bt,                      14,                       # (START SEQ #84) slot_idx
    \&literal_test,                134,                      # <<m/>>
    \&test_match,                  2232, 2297,               # ok fail
# 2232:
    \&set_bt,                      15,                       # (START SEQ #85) slot_idx
    \&set_iter_slot,               17, 0,                    # slot_idx value
# 2237:
    \&set_bt,                      16,                       # slot_idx
    \&regex13,                     13,                       # <<m!\G([^/\\]+)!gc>>
    \&test_match,                  2244, 2252,               # ok fail
# 2244:
    \&var_set_op,                  135, 2,                   # <<regex>> op:+=
# 2247:
    \&add_iter_slot,               17, 1,                    # slot_idx value
    \&jump,                        2237,                     # next
# 2252:
    \&regex14,                     14,                       # <<m!\G([\\].)!gc>>
    \&test_match,                  2257, 2262,               # ok fail
# 2257:
    \&var_set_op,                  135, 2,                   # <<regex>> op:+=
    \&jump,                        2247,                     # next
# 2262:
    \&goto_bt,                     16,                       # slot_idx
    \&gt_iter_slot,                17, 0, 2269, 2295,        # slot_idx value ok fail
# 2269:
    \&literal_match,               136,                      # <</>>
    \&test_match,                  2274, 2293,               # ok fail
# 2274:
    \&var_set_op,                  137, 0,                   # <<delimiter>> op:=
    \&var_set_const,               4, 0, 'regex_match',      # <<node_type>> op:=
    \&token_ext_quantifier,        1,                        # set_match
    \&test_match,                  2286, 2289,               # ok fail
# 2286:
    \&var_set_op,                  46, 0,                    # <<quantifier>> op:=
# 2289:
    \&token_ws,                    0,                        # set_match
# 2291:
    \&pkg_return,                  138,                      # <<WW::ParserGen::PDA::AST::RegexMatch>>
# 2293:
    \&goto_bt,                     15,                       # (FAIL SEQ #85) slot_idx
# 2295:
    \&fatal,                       [ 'missing closing / in regex' ], 
# 2297:
    \&set_bt,                      10,                       # (START SEQ #82) slot_idx
    \&literal_test,                139,                      # <<m!>>
    \&test_match,                  2304, 2370,               # ok fail
# 2304:
    \&set_bt,                      11,                       # (START SEQ #83) slot_idx
    \&set_iter_slot,               13, 0,                    # slot_idx value
# 2309:
    \&set_bt,                      12,                       # slot_idx
    \&regex15,                     15,                       # <<m/\G([^!\\]+)/gc>>
    \&test_match,                  2316, 2324,               # ok fail
# 2316:
    \&var_set_op,                  135, 2,                   # <<regex>> op:+=
# 2319:
    \&add_iter_slot,               13, 1,                    # slot_idx value
    \&jump,                        2309,                     # next
# 2324:
    \&regex14,                     14,                       # <<m!\G([\\].)!gc>>
    \&test_match,                  2329, 2334,               # ok fail
# 2329:
    \&var_set_op,                  135, 2,                   # <<regex>> op:+=
    \&jump,                        2319,                     # next
# 2334:
    \&goto_bt,                     12,                       # slot_idx
    \&gt_iter_slot,                13, 0, 2341, 2368,        # slot_idx value ok fail
# 2341:
    \&literal_match,               60,                       # <<!>>
    \&test_match,                  2346, 2366,               # ok fail
# 2346:
    \&var_set_op,                  137, 0,                   # <<delimiter>> op:=
    \&var_set_const,               4, 0, 'regex_match',      # <<node_type>> op:=
    \&token_ext_quantifier,        1,                        # set_match
    \&test_match,                  2358, 2361,               # ok fail
# 2358:
    \&var_set_op,                  46, 0,                    # <<quantifier>> op:=
# 2361:
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2291, 2291,               # ok fail
# 2366:
    \&goto_bt,                     11,                       # (FAIL SEQ #83) slot_idx
# 2368:
    \&fatal,                       [ 'missing closing ! in regex' ], 
# 2370:
    \&set_bt,                      0,                        # (START SEQ #74) slot_idx
    \&set_bt,                      9,                        # (START SEQ #81) slot_idx
    \&token__not_char_class,       0,                        # set_match
    \&test_match,                  2379, 2515,               # ok fail
# 2379:
    \&var_set_const,               4, 0, 'not_char_class',   # <<node_type>> op:=
# 2383:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #75) slot_idx
    \&var_set_const,               140, 0, 1,                # <<is_char_class>> op:=
    \&var_set_const,               137, 0, '/',              # <<delimiter>> op:=
    \&var_set_const,               135, 0, '',               # <<regex>> op:=
    \&set_iter_slot,               3, 0,                     # slot_idx value
# 2402:
    \&set_bt,                      2,                        # slot_idx
    \&set_bt,                      7,                        # (START SEQ #79) slot_idx
    \&literal_test,                41,                       # <<0x>>
    \&test_match,                  2411, 2428,               # ok fail
# 2411:
    \&token_hex_code_point,        1,                        # set_match
    \&test_match,                  2416, 2426,               # ok fail
# 2416:
    \&var_set_op,                  141, 3,                   # <<code_points>> op:<<
    \&token_ws,                    0,                        # set_match
# 2421:
    \&add_iter_slot,               3, 1,                     # slot_idx value
    \&jump,                        2402,                     # next
# 2426:
    \&goto_bt,                     7,                        # (FAIL SEQ #79) slot_idx
# 2428:
    \&set_bt,                      6,                        # (START SEQ #78) slot_idx
    \&token_class_chars,           1,                        # set_match
    \&test_match,                  2435, 2443,               # ok fail
# 2435:
    \&var_set_op,                  142, 2,                   # <<class_chars>> op:+=
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2421, 2421,               # ok fail
# 2443:
    \&set_bt,                      5,                        # (START SEQ #77) slot_idx
    \&literal_test,                18,                       # <<'>>
    \&test_match,                  2450, 2470,               # ok fail
# 2450:
    \&regex16,                     16,                       # <<m/\G([^'\x0D\x0A]+)/gc>>
    \&test_match,                  2455, 2468,               # ok fail
# 2455:
    \&var_set_op,                  142, 2,                   # <<class_chars>> op:+=
    \&literal_test,                18,                       # <<'>>
    \&test_match,                  2463, 2468,               # ok fail
# 2463:
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2421, 2421,               # ok fail
# 2468:
    \&goto_bt,                     5,                        # (FAIL SEQ #77) slot_idx
# 2470:
    \&set_bt,                      4,                        # (START SEQ #76) slot_idx
    \&rule_match,                  593, 2507, 2476,          # char_range ok fail
# 2476:
    \&goto_bt,                     2,                        # slot_idx
    \&gt_iter_slot,                3, 0, 2483, 2503,         # slot_idx value ok fail
# 2483:
    \&token_ws,                    0,                        # set_match
    \&literal_test,                50,                       # <<]>>
    \&test_match,                  2490, 2503,               # ok fail
# 2490:
    \&token_ext_quantifier,        1,                        # set_match
    \&test_match,                  2495, 2498,               # ok fail
# 2495:
    \&var_set_op,                  46, 0,                    # <<quantifier>> op:=
# 2498:
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2291, 2291,               # ok fail
# 2503:
    \&goto_bt,                     1,                        # (FAIL SEQ #75) slot_idx
    \&fatal,                       [ 'expected m[ ( <char> | <code-point> | <char-range> | <string> )+ ]<quantifier>?' ], 
# 2507:
    \&var_set_op,                  143, 3,                   # <<char_ranges>> op:<<
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2421, 2421,               # ok fail
# 2515:
    \&set_bt,                      8,                        # (START SEQ #80) slot_idx
    \&literal_test,                144,                      # <<m[>>
    \&test_match,                  2522, 2528,               # ok fail
# 2522:
    \&var_set_const,               4, 0, 'char_class',       # <<node_type>> op:=
    \&jump,                        2383,                     # next
# 2528:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # rule_call [2529]
    #--------------------------------------------------------------------------------
    \&rule_start,                  145, 4,                   # <<rule_call>> slot_count
    \&set_rule_vars,               { node_type => undef, quantifier => undef, reg_numbers => undef, rule_name => undef }, 
    \&set_bt,                      0,                        # (START SEQ #54) slot_idx
    \&literal_test,                146,                      # <<call[>>
    \&test_match,                  2541, 2609,               # ok fail
# 2541:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #55) slot_idx
    \&var_set_const,               4, 0, 'rule_call',        # <<node_type>> op:=
    \&token_name,                  1,                        # set_match
    \&test_match,                  2554, 2595,               # ok fail
# 2554:
    \&var_set_op,                  147, 0,                   # <<rule_name>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_iter_slot,               3, 0,                     # slot_idx value
# 2562:
    \&set_bt,                      2,                        # slot_idx
    \&literal_test,                148,                      # <<$$r>>
    \&test_match,                  2569, 2573,               # ok fail
# 2569:
    \&rule_match,                  944, 2599, 2573,          # digit_const ok fail
# 2573:
    \&goto_bt,                     2,                        # slot_idx
    \&gt_iter_slot,                3, 0, 2580, 2595,         # slot_idx value ok fail
# 2580:
    \&literal_test,                50,                       # <<]>>
    \&test_match,                  2585, 2595,               # ok fail
# 2585:
    \&token_std_quantifier,        1,                        # set_match
    \&test_match,                  2590, 2593,               # ok fail
# 2590:
    \&var_set_op,                  46, 0,                    # <<quantifier>> op:=
# 2593:
    \&pkg_return,                  149,                      # <<WW::ParserGen::PDA::AST::RuleCall>>
# 2595:
    \&goto_bt,                     1,                        # (FAIL SEQ #55) slot_idx
    \&fatal,                       [ "expected &&call[<rule name> ( \$\$r<digit> )+]" ], 
# 2599:
    \&var_set_op,                  150, 3,                   # <<reg_numbers>> op:<<
    \&token_ws,                    0,                        # set_match
    \&add_iter_slot,               3, 1,                     # slot_idx value
    \&jump,                        2562,                     # next
# 2609:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # rule_def [2610]
    #--------------------------------------------------------------------------------
    \&rule_start,                  151, 6,                   # <<rule_def>> slot_count
    \&set_rule_vars,               { match => undef, node_pkg => undef, node_type => undef, rule_name => undef, rule_vars => undef }, 
    \&set_bt,                      0,                        # (START SEQ #92) slot_idx
    \&token_name,                  1,                        # set_match
    \&test_match,                  2622, 2713,               # ok fail
# 2622:
    \&var_set_op,                  147, 0,                   # <<rule_name>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #93) slot_idx
    \&var_set_const,               4, 0, 'rule_def',         # <<node_type>> op:=
    \&set_bt,                      2,                        # (START SEQ #94) slot_idx
    \&literal_test,                112,                      # <<=>>>
    \&test_match,                  2640, 2660,               # ok fail
# 2640:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      4,                        # (START SEQ #96) slot_idx
    \&token_fq_package,            1,                        # set_match
    \&test_match,                  2649, 2697,               # ok fail
# 2649:
    \&var_set_op,                  152, 0,                   # <<node_pkg>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      5,                        # (START SEQ #97) slot_idx
    \&rule_match,                  2881, 2689, 2660,         # rule_vars ok fail
# 2660:
    \&literal_test,                25,                       # <<::=>>
    \&test_match,                  2665, 2671,               # ok fail
# 2665:
    \&token_ws,                    0,                        # set_match
    \&rule_match,                  1807, 2675, 2671,         # match ok fail
# 2671:
    \&goto_bt,                     1,                        # (FAIL SEQ #93) slot_idx
    \&fatal,                       [ 'rule def error in ', "\$rule_name" ], 
# 2675:
    \&var_set_op,                  45, 0,                    # <<match>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                27,                       # <<.>>
    \&test_match,                  2685, 2687,               # ok fail
# 2685:
    \&pkg_return,                  153,                      # <<WW::ParserGen::PDA::AST::RuleDef>>
# 2687:
    \&fatal,                       [ 'missing terminating . in rule def for ', "\$rule_name" ], 
# 2689:
    \&var_set_op,                  154, 0,                   # <<rule_vars>> op:=
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2660, 2660,               # ok fail
# 2697:
    \&set_bt,                      3,                        # (START SEQ #95) slot_idx
    \&rule_match,                  2881, 2705, 2703,         # rule_vars ok fail
# 2703:
    \&fatal,                       [ 'error pkg/rule var defs for ', "\$rule_name" ], 
# 2705:
    \&var_set_op,                  154, 0,                   # <<rule_vars>> op:=
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2660, 2660,               # ok fail
# 2713:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # rule_defs [2714]
    #--------------------------------------------------------------------------------
    \&rule_start,                  155, 9,                   # <<rule_defs>> slot_count
    \&set_rule_vars,               { custom_match_list => undef, infix_op_tables => undef, node_pkg_prefix => undef, node_type => undef, parser_pkg => undef, pkg_use_list => undef, rule_defs => undef, token_defs => undef }, 
    \&set_bt,                      0,                        # (START SEQ #50) slot_idx
    \&trace_flags,                 0,                        # flags
    \&var_set_const,               4, 0, 'rule_defs',        # <<node_type>> op:=
    \&token_ws,                    0,                        # set_match
    \&rule_match,                  2176, 2733, 2830,         # parser_package ok fail
# 2733:
    \&var_set_op,                  156, 0,                   # <<parser_pkg>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      8,                        # (START SEQ #53) slot_idx
    \&rule_match,                  2057, 2744, 2749,         # node_package_prefix ok fail
# 2744:
    \&var_set_op,                  157, 0,                   # <<node_pkg_prefix>> op:=
    \&token_ws,                    0,                        # set_match
# 2749:
    \&set_bt,                      7,                        # slot_idx
    \&rule_match,                  3437, 2755, 2763,         # use_package ok fail
# 2755:
    \&var_set_op,                  158, 3,                   # <<pkg_use_list>> op:<<
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2749, 2749,               # ok fail
# 2763:
    \&goto_bt,                     7,                        # slot_idx
# 2765:
    \&set_bt,                      6,                        # slot_idx
    \&rule_match,                  847, 2771, 2779,          # custom_match_def ok fail
# 2771:
    \&var_set_op,                  159, 3,                   # <<custom_match_list>> op:<<
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2765, 2765,               # ok fail
# 2779:
    \&goto_bt,                     6,                        # slot_idx
# 2781:
    \&set_bt,                      5,                        # slot_idx
    \&rule_match,                  1337, 2787, 2795,         # infix_op_table ok fail
# 2787:
    \&var_set_op,                  160, 3,                   # <<infix_op_tables>> op:<<
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2781, 2781,               # ok fail
# 2795:
    \&goto_bt,                     5,                        # slot_idx
    \&set_iter_slot,               2, 0,                     # slot_idx value
# 2800:
    \&set_bt,                      1,                        # slot_idx
    \&set_bt,                      4,                        # (START SEQ #52) slot_idx
    \&rule_match,                  2610, 2843, 2808,         # rule_def ok fail
# 2808:
    \&set_bt,                      3,                        # (START SEQ #51) slot_idx
    \&rule_match,                  3074, 2833, 2814,         # token_def ok fail
# 2814:
    \&goto_bt,                     1,                        # slot_idx
    \&gt_iter_slot,                2, 0, 2821, 2830,         # slot_idx value ok fail
# 2821:
    \&at_eof,                      undef,                   
    \&test_match,                  2826, 2828,               # ok fail
# 2826:
    \&pkg_return,                  161,                      # <<WW::ParserGen::PDA::AST::RuleDefs>>
# 2828:
    \&fatal,                       [ 'extra text after rule/token defs' ], 
# 2830:
    \&goto_bt,                     0,                        # (FAIL SEQ #50) slot_idx
    \&fail_return,                                          
# 2833:
    \&var_set_op,                  162, 3,                   # <<token_defs>> op:<<
    \&token_ws,                    0,                        # set_match
# 2838:
    \&add_iter_slot,               2, 1,                     # slot_idx value
    \&jump,                        2800,                     # next
# 2843:
    \&var_set_op,                  155, 3,                   # <<rule_defs>> op:<<
    \&token_ws,                    0,                        # set_match
    \&test_match,                  2838, 2838,               # ok fail

    #--------------------------------------------------------------------------------
    # rule_match [2851]
    #--------------------------------------------------------------------------------
    \&rule_start,                  163, 1,                   # <<rule_match>> slot_count
    \&set_rule_vars,               { node_type => undef, quantifier => undef, rule_name => undef }, 
    \&set_bt,                      0,                        # (START SEQ #65) slot_idx
    \&token_name,                  1,                        # set_match
    \&test_match,                  2863, 2880,               # ok fail
# 2863:
    \&var_set_op,                  147, 0,                   # <<rule_name>> op:=
    \&token_ext_quantifier,        1,                        # set_match
    \&test_match,                  2871, 2874,               # ok fail
# 2871:
    \&var_set_op,                  46, 0,                    # <<quantifier>> op:=
# 2874:
    \&var_set_const,               4, 0, 'rule_match',       # <<node_type>> op:=
    \&pkg_return,                  164,                      # <<WW::ParserGen::PDA::AST::RuleMatch>>
# 2880:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # rule_vars [2881]
    #--------------------------------------------------------------------------------
    \&rule_start,                  154, 4,                   # <<rule_vars>> slot_count
    \&set_bt,                      0,                        # (START SEQ #37) slot_idx
    \&literal_test,                8,                        # <<{>>
    \&test_match,                  2891, 2941,               # ok fail
# 2891:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #38) slot_idx
    \&set_iter_slot,               3, 0,                     # slot_idx value
# 2898:
    \&set_bt,                      2,                        # slot_idx
    \&literal_test,                32,                       # <<$>>
    \&test_match,                  2905, 2920,               # ok fail
# 2905:
    \&token_name,                  1,                        # set_match
    \&test_match,                  2910, 2920,               # ok fail
# 2910:
    \&var_set_op,                  1, 3,                     # <<*0>> op:<<
    \&token_ws,                    0,                        # set_match
    \&add_iter_slot,               3, 1,                     # slot_idx value
    \&jump,                        2898,                     # next
# 2920:
    \&goto_bt,                     2,                        # slot_idx
    \&gt_iter_slot,                3, 0, 2927, 2939,         # slot_idx value ok fail
# 2927:
    \&literal_test,                10,                       # <<}>>
    \&test_match,                  2932, 2937,               # ok fail
# 2932:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 2937:
    \&fatal,                       [ 'missing closing } rule vars list' ], 
# 2939:
    \&fatal,                       [ "expected { \$<name>+ }" ], 
# 2941:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # sequence_match [2942]
    #--------------------------------------------------------------------------------
    \&rule_start,                  165, 4,                   # <<sequence_match>> slot_count
    \&set_bt,                      0,                        # (START SEQ #56) slot_idx
    \&rule_match,                  1876, 2951, 3006,         # match_atom ok fail
# 2951:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #57) slot_idx
    \&set_iter_slot,               3, 0,                     # slot_idx value
# 2961:
    \&set_bt,                      2,                        # slot_idx
    \&literal_test,                113,                      # <<|>>
    \&not_match,                   2968, 2982,               # ok fail
# 2968:
    \&rule_match,                  1876, 2972, 2982,         # match_atom ok fail
# 2972:
    \&var_set_op,                  7, 3,                     # <<*1>> op:<<
    \&token_ws,                    0,                        # set_match
    \&add_iter_slot,               3, 1,                     # slot_idx value
    \&jump,                        2961,                     # next
# 2982:
    \&goto_bt,                     2,                        # slot_idx
    \&gt_iter_slot,                3, 0, 2989, 2997,         # slot_idx value ok fail
# 2989:
    \&rule_call,                   101, 2994, 3002, [ 0, 1 ], 
                                                             # _make_sequence_match ok fail
# 2994:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
# 2997:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 3002:
    \&goto_bt,                     1,                        # (FAIL SEQ #57) slot_idx
    \&jump,                        2997,                     # next
# 3006:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # string_const [3007]
    #--------------------------------------------------------------------------------
    \&rule_start,                  166, 4,                   # <<string_const>> slot_count
    \&set_rule_vars,               { node_type => undef, value => undef, value_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #130) slot_idx
    \&literal_test,                130,                      # <<">>
    \&test_match,                  3019, 3073,               # ok fail
# 3019:
    \&set_bt,                      1,                        # (START SEQ #131) slot_idx
# 3021:
    \&set_bt,                      2,                        # slot_idx
    \&set_bt,                      3,                        # (START SEQ #132) slot_idx
    \&regex11,                     11,                       # <<m/\G[\\]/gc>>
    \&test_match,                  3030, 3042,               # ok fail
# 3030:
    \&regex8,                      8,                        # <<m/\G(.)/gc>>
    \&test_match,                  3035, 3040,               # ok fail
# 3035:
    \&var_set_op,                  42, 2,                    # <<value>> op:+=
    \&jump,                        3021,                     # next
# 3040:
    \&goto_bt,                     3,                        # (FAIL SEQ #132) slot_idx
# 3042:
    \&regex12,                     12,                       # <<m/\G([^"\\]+)/gc>>
    \&test_match,                  3047, 3052,               # ok fail
# 3047:
    \&var_set_op,                  42, 2,                    # <<value>> op:+=
    \&jump,                        3021,                     # next
# 3052:
    \&goto_bt,                     2,                        # slot_idx
    \&literal_test,                130,                      # <<">>
    \&test_match,                  3059, 3069,               # ok fail
# 3059:
    \&var_set_const,               4, 0, 'const_value',      # <<node_type>> op:=
    \&var_set_const,               51, 0, 'Str',             # <<value_type>> op:=
    \&pkg_return,                  52,                       # <<WW::ParserGen::PDA::AST::ConstValue>>
# 3069:
    \&goto_bt,                     1,                        # (FAIL SEQ #131) slot_idx
    \&fatal,                       [ 'missing closing quote in string const' ], 
# 3073:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # token_def [3074]
    #--------------------------------------------------------------------------------
    \&rule_start,                  167, 3,                   # <<token_def>> slot_count
    \&set_bt,                      0,                        # (START SEQ #26) slot_idx
    \&literal_test,                101,                      # <<&>>
    \&test_match,                  3084, 3116,               # ok fail
# 3084:
    \&token_name,                  1,                        # set_match
    \&test_match,                  3089, 3114,               # ok fail
# 3089:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #27) slot_idx
    \&literal_test,                125,                      # <<(>>
    \&test_match,                  3101, 3109,               # ok fail
# 3101:
    \&token_ws,                    0,                        # set_match
    \&rule_match,                  0, 3125, 3107,            # _arg_defs ok fail
# 3107:
    \&goto_bt,                     1,                        # (FAIL SEQ #27) slot_idx
# 3109:
    \&rule_call,                   182, 3117, 3114, [ 0 ],   # _token_def_part ok fail
# 3114:
    \&goto_bt,                     0,                        # (FAIL SEQ #26) slot_idx
# 3116:
    \&fail_return,                                          
# 3117:
    \&var_set_op,                  121, 0,                   # <<*2>> op:=
# 3120:
    \&var_move,                    2, 0, 121,                # <<*match_value*>> op:= <<*2>>
    \&ok_return,                                            
# 3125:
    \&var_set_op,                  7, 0,                     # <<*1>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      2,                        # (START SEQ #28) slot_idx
    \&literal_test,                126,                      # <<)>>
    \&test_match,                  3137, 3149,               # ok fail
# 3137:
    \&token_ws,                    0,                        # set_match
    \&rule_call,                   31, 3144, 3107, [ 0, 1 ], 
                                                             # _custom_match_part ok fail
# 3144:
    \&var_set_op,                  121, 0,                   # <<*2>> op:=
    \&jump,                        3120,                     # next
# 3149:
    \&fatal,                       [ 'missing closing ) in arg defs list for custom match ', "\$\$r0" ], 

    #--------------------------------------------------------------------------------
    # token_match [3151]
    #--------------------------------------------------------------------------------
    \&rule_start,                  26, 4,                    # <<token_match>> slot_count
    \&set_bt,                      0,                        # (START SEQ #70) slot_idx
    \&rule_match,                  3304, 3160, 3223,         # token_match_seq ok fail
# 3160:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #71) slot_idx
    \&set_iter_slot,               3, 0,                     # slot_idx value
# 3170:
    \&set_bt,                      2,                        # slot_idx
    \&literal_test,                113,                      # <<|>>
    \&test_match,                  3177, 3195,               # ok fail
# 3177:
    \&token_ws,                    0,                        # set_match
    \&rule_match,                  3304, 3185, 3183,         # token_match_seq ok fail
# 3183:
    \&fatal,                       [ 'missing token match after |' ], 
# 3185:
    \&var_set_op,                  7, 3,                     # <<*1>> op:<<
    \&token_ws,                    0,                        # set_match
    \&add_iter_slot,               3, 1,                     # slot_idx value
    \&jump,                        3170,                     # next
# 3195:
    \&goto_bt,                     2,                        # slot_idx
    \&gt_iter_slot,                3, 0, 3202, 3214,         # slot_idx value ok fail
# 3202:
    \&var_set_const,               121, 0, 'token_match_or', 
                                                             # <<*2>> op:=
    \&rule_call,                   1786, 3211, 3219, [ 0, 1, 2 ], 
                                                             # make_match_list ok fail
# 3211:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
# 3214:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 3219:
    \&goto_bt,                     1,                        # (FAIL SEQ #71) slot_idx
    \&jump,                        3214,                     # next
# 3223:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # token_match_atom [3224]
    #--------------------------------------------------------------------------------
    \&rule_start,                  168, 0,                   # <<token_match_atom>> slot_count
    \&rule_match,                  1598, 3244, 3231,         # literal_match ok fail
# 3231:
    \&rule_match,                  2220, 3244, 3235,         # regex_match ok fail
# 3235:
    \&rule_match,                  3245, 3244, 3239,         # token_match_group ok fail
# 3239:
    \&var_set_const,               2, 0, undef,              # <<*match_value*>> op:=
    \&fail_return,                                          
# 3244:
    \&ok_return,                                            

    #--------------------------------------------------------------------------------
    # token_match_group [3245]
    #--------------------------------------------------------------------------------
    \&rule_start,                  169, 2,                   # <<token_match_group>> slot_count
    \&set_bt,                      0,                        # (START SEQ #98) slot_idx
    \&literal_test,                125,                      # <<(>>
    \&test_match,                  3255, 3303,               # ok fail
# 3255:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #99) slot_idx
    \&rule_match,                  3151, 3265, 3263,         # token_match ok fail
# 3263:
    \&fatal,                       [ 'missing closing parend in token match list' ], 
# 3265:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                126,                      # <<)>>
    \&test_match,                  3275, 3299,               # ok fail
# 3275:
    \&token_ws,                    0,                        # set_match
    \&token_std_quantifier,        1,                        # set_match
    \&test_match,                  3282, 3285,               # ok fail
# 3282:
    \&var_set_op,                  7, 0,                     # <<*1>> op:=
# 3285:
    \&token_ws,                    0,                        # set_match
    \&make_group_match,            undef,                   
    \&test_match,                  3292, 3297,               # ok fail
# 3292:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 3297:
    \&fatal,                       [ 'multiple quantifiers on group not supported' ], 
# 3299:
    \&goto_bt,                     1,                        # (FAIL SEQ #99) slot_idx
    \&jump,                        3263,                     # next
# 3303:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # token_match_seq [3304]
    #--------------------------------------------------------------------------------
    \&rule_start,                  170, 4,                   # <<token_match_seq>> slot_count
    \&set_bt,                      0,                        # (START SEQ #88) slot_idx
    \&rule_match,                  3224, 3313, 3365,         # token_match_atom ok fail
# 3313:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
    \&set_bt,                      1,                        # (START SEQ #89) slot_idx
    \&set_iter_slot,               3, 0,                     # slot_idx value
# 3321:
    \&set_bt,                      2,                        # slot_idx
    \&rule_match,                  3224, 3327, 3337,         # token_match_atom ok fail
# 3327:
    \&var_set_op,                  7, 3,                     # <<*1>> op:<<
    \&token_ws,                    0,                        # set_match
    \&add_iter_slot,               3, 1,                     # slot_idx value
    \&jump,                        3321,                     # next
# 3337:
    \&goto_bt,                     2,                        # slot_idx
    \&gt_iter_slot,                3, 0, 3344, 3356,         # slot_idx value ok fail
# 3344:
    \&var_set_const,               121, 0, 'token_match_seq', 
                                                             # <<*2>> op:=
    \&rule_call,                   1786, 3353, 3361, [ 0, 1, 2 ], 
                                                             # make_match_list ok fail
# 3353:
    \&var_set_op,                  1, 0,                     # <<*0>> op:=
# 3356:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 3361:
    \&goto_bt,                     1,                        # (FAIL SEQ #89) slot_idx
    \&jump,                        3356,                     # next
# 3365:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # trace_flags [3366]
    #--------------------------------------------------------------------------------
    \&rule_start,                  171, 2,                   # <<trace_flags>> slot_count
    \&set_rule_vars,               { node_type => undef, trace_flags => undef }, 
    \&set_bt,                      0,                        # (START SEQ #18) slot_idx
    \&literal_test,                172,                      # <<trace_flags[>>
    \&test_match,                  3378, 3409,               # ok fail
# 3378:
    \&token_ws,                    0,                        # set_match
    \&set_bt,                      1,                        # (START SEQ #19) slot_idx
    \&regex17,                     17,                       # <<m/\G(\d+)/gc>>
    \&test_match,                  3387, 3407,               # ok fail
# 3387:
    \&var_set_op,                  171, 0,                   # <<trace_flags>> op:=
    \&token_ws,                    0,                        # set_match
    \&literal_test,                50,                       # <<]>>
    \&test_match,                  3397, 3405,               # ok fail
# 3397:
    \&token_ws,                    0,                        # set_match
    \&var_set_const,               4, 0, 'trace_flags',      # <<node_type>> op:=
    \&pkg_return,                  173,                      # <<WW::ParserGen::PDA::AST::TraceFlags>>
# 3405:
    \&goto_bt,                     1,                        # (FAIL SEQ #19) slot_idx
# 3407:
    \&fatal,                       [ 'expected &&trace_flags[<digits>]' ], 
# 3409:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # undef_const [3410]
    #--------------------------------------------------------------------------------
    \&rule_start,                  174, 1,                   # <<undef_const>> slot_count
    \&set_rule_vars,               { node_type => undef, value => undef, value_type => undef }, 
    \&set_bt,                      0,                        # (START SEQ #69) slot_idx
    \&literal_test,                175,                      # <<<undef>>>
    \&test_match,                  3422, 3436,               # ok fail
# 3422:
    \&var_set_const,               42, 0, undef,             # <<value>> op:=
    \&var_set_const,               51, 0, 'Undef',           # <<value_type>> op:=
    \&var_set_const,               4, 0, 'const_value',      # <<node_type>> op:=
    \&pkg_return,                  52,                       # <<WW::ParserGen::PDA::AST::ConstValue>>
# 3436:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # use_package [3437]
    #--------------------------------------------------------------------------------
    \&rule_start,                  176, 5,                   # <<use_package>> slot_count
    \&set_rule_vars,               { fq_package => undef, node_type => undef, use_args => undef }, 
    \&set_bt,                      0,                        # (START SEQ #45) slot_idx
    \&literal_test,                177,                      # <<@use>>
    \&test_match,                  3449, 3536,               # ok fail
# 3449:
    \&token_ws,                    0,                        # set_match
    \&test_match,                  3454, 3534,               # ok fail
# 3454:
    \&set_bt,                      1,                        # (START SEQ #46) slot_idx
    \&token_fq_package,            1,                        # set_match
    \&test_match,                  3461, 3524,               # ok fail
# 3461:
    \&var_set_op,                  178, 0,                   # <<fq_package>> op:=
    \&literal_match,               179,                      # <<::>>
    \&test_match,                  3469, 3472,               # ok fail
# 3469:
    \&var_set_op,                  178, 2,                   # <<fq_package>> op:+=
# 3472:
    \&set_bt,                      2,                        # (START SEQ #47) slot_idx
    \&token_ws,                    0,                        # set_match
    \&test_match,                  3479, 3509,               # ok fail
# 3479:
    \&literal_test,                180,                      # <<qw(>>
    \&test_match,                  3484, 3530,               # ok fail
# 3484:
    \&set_bt,                      3,                        # (START SEQ #48) slot_idx
# 3486:
    \&set_bt,                      4,                        # slot_idx
    \&token_ws,                    0,                        # set_match
    \&regex18,                     18,                       # <<m/\G([^\s)]+)/gc>>
    \&test_match,                  3495, 3500,               # ok fail
# 3495:
    \&var_set_op,                  181, 3,                   # <<use_args>> op:<<
    \&jump,                        3486,                     # next
# 3500:
    \&goto_bt,                     4,                        # slot_idx
    \&token_ws,                    0,                        # set_match
    \&literal_test,                126,                      # <<)>>
    \&test_match,                  3509, 3526,               # ok fail
# 3509:
    \&token_ws,                    0,                        # set_match
    \&literal_test,                27,                       # <<.>>
    \&test_match,                  3516, 3522,               # ok fail
# 3516:
    \&var_set_const,               4, 0, 'use_package',      # <<node_type>> op:=
    \&pkg_return,                  182,                      # <<WW::ParserGen::PDA::AST::UsePackage>>
# 3522:
    \&goto_bt,                     1,                        # (FAIL SEQ #46) slot_idx
# 3524:
    \&fatal,                       [ "expected \@use <fq_package> <qw_args>?." ], 
# 3526:
    \&goto_bt,                     3,                        # (FAIL SEQ #48) slot_idx
    \&fatal,                       [ "expected \@use ", "\$fq_package", ' qw( <text>* ).' ], 
# 3530:
    \&goto_bt,                     2,                        # (FAIL SEQ #47) slot_idx
    \&jump,                        3509,                     # next
# 3534:
    \&goto_bt,                     0,                        # (FAIL SEQ #45) slot_idx
# 3536:
    \&fail_return,                                          

    #--------------------------------------------------------------------------------
    # var_ref_error [3537]
    #--------------------------------------------------------------------------------
    \&rule_start,                  183, 0,                   # <<var_ref_error>> slot_count
    \&fatal,                       [ 'expected <var_ref> <op> (int_const | string_const | <match>)' ], 

    #--------------------------------------------------------------------------------
    # var_refs [3542]
    #--------------------------------------------------------------------------------
    \&rule_start,                  92, 3,                    # <<var_refs>> slot_count
    \&set_bt,                      0,                        # (START SEQ #25) slot_idx
    \&set_iter_slot,               2, 0,                     # slot_idx value
# 3550:
    \&set_bt,                      1,                        # slot_idx
    \&literal_test,                32,                       # <<$>>
    \&test_match,                  3557, 3571,               # ok fail
# 3557:
    \&rule_match,                  301, 3561, 3571,          # _var_ref ok fail
# 3561:
    \&var_set_op,                  1, 3,                     # <<*0>> op:<<
    \&token_ws,                    0,                        # set_match
    \&add_iter_slot,               2, 1,                     # slot_idx value
    \&jump,                        3550,                     # next
# 3571:
    \&goto_bt,                     1,                        # slot_idx
    \&gt_iter_slot,                2, 0, 3578, 3583,         # slot_idx value ok fail
# 3578:
    \&var_move,                    2, 0, 1,                  # <<*match_value*>> op:= <<*0>>
    \&ok_return,                                            
# 3583:
    \&fail_return,                                          
);

sub get_op_tables {
    return {
        OP_ADDRESS_NAMES        => \%OP_ADDRESS_NAMES,
        OP_ADDRESS_TRACE_FLAGS  => \%OP_ADDRESS_TRACE_FLAGS,
        LITERAL_LIST            => \@LITERAL_LIST,
        REGEX_LIST              => \@REGEX_LIST,
        RULE_DEF_INDEXES        => \%RULE_DEF_INDEXES,
        RULE_DEF_NAMES          => \%RULE_DEF_NAMES,
        OP_LIST                 => \@OP_LIST,
        OP_DEFS                 => WW::Parse::PDA::OpDefs::get_op_defs,
    };
}

1;


