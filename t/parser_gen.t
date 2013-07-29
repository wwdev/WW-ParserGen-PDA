#!/usr/bin/perl -w
use feature qw(:5.12);
use strict;

## Basic functional testing for WW::ParserGen::PDA::* ##

use FindBin;
use lib "$FindBin::Bin/tlib", "$FindBin::Bin/../lib";

use Scalar::Util qw( reftype );
use Test::More tests => 1178;
use Test::Exception;

sub parse_args;
sub build_parser;
sub run_cases;

BEGIN {
    use_ok 'WW::ParserGen::PDA::OpGraph';
    use_ok 'WW::ParserGen::PDA::EBNFParser';
    use_ok 'WW::ParserGen::PDA::OpGraph::SlotAllocs', qw( _SlotAllocs );
    use_ok 'WW::ParserGen::PDA::Info';
    use_ok 'WW::ParserGen::PDA::Generator';
    use_ok 'WW::ParserGen::PDA::PerlPackageMaker';
    use_ok 'WW::Parse::PDA::Engine';
    use_ok 'WW::Parse::PDA::Trace';
}

my $opts = parse_args;

#-------------------------------------------------------------------------------
# simple cases
#-------------------------------------------------------------------------------
my %char_codes = map { ( $_, chr($_) ) } 0..255;
delete $char_codes{10}; delete $char_codes{13};

my $all_8bit_chars  = join ('', map { $char_codes{$_} } sort { $a <=> $b } keys %char_codes);

$char_codes{ord("'")}  = '\\\'';
$char_codes{ord('\\')} = '\\\\';
my $all_perl_qchars = join ('', map { $char_codes{$_} } sort { $a <=> $b } keys %char_codes);

my $bs = '\\';


my @cases = (
    # rule def                                                [ test text status value ]
    'char1 ::= $$ = &&char[ 0x27 ].', [
        '',                                 1,     "'",
    ],
    'charclass2 ::= $$r0 = "" ( $$r0 += M[ \ 0x27 ]+ | m[ \ ] $$r0 += m/./ )* $$ = $$r0.', [
        '',                                 1,     '',
        ' abc ',                            1,     ' abc ',
        "\n $bs$bs $bs'\n\'x'",             1,     "\n $bs '\n",
    ],
    'charclass2 ::= $$r0 = "" ( $$r0 += !m[ \ 0x27 ]+ | m[ \ ] $$r0 += m/./ )* $$ = $$r0.', [
        '',                                 1,     '',
        ' abc ',                            1,     ' abc ',
        "\n $bs$bs $bs'\n\'x'",             1,     "\n $bs '\n",
    ],
    'cp1 ::= $$ = 0x0A.', [
        '',                                 undef, undef,
        "\x0A",                             1,     "\x0A",
    ],
    'undefconst ::= $$ = <undef>.', [
        '',                                 1,     undef,
    ],
    'sconst1_abc ::= $$ = "\\@abcd09123\'()[]{},.\\"/\\|\\\\".', [
        '',                                 1,    '@abcd09123\'()[]{},."/|\\',
    ],
    'aconst1 ::= $$ = [].', [
        '',                                 1,     [],
    ],
    'hconst1 ::= $$ = {}.', [
        '',                                 1,     {},
    ],
    'var1 ::= $$r0 = "AA" $$ = $$r0.', [
        '',                                 1,     'AA',
    ],
    'var2 ::= $$r9 << "AA" $$ = $$r9.', [
        '',                                 1,     [ 'AA' ],
    ],
    'var3 => { $q } ::= $$r7 << "AA" $q = $$r7.',  [
        '',                                 1,     { q => [ 'AA' ] },
    ],
    'not1 ::= $$ = m/abc/ \'d\'!.', [
        'abc',                              1,     'abc',
        'abcx',                             1,     'abc',
        'abcd',                             undef, undef,
    ],
    'not2 ::= $$ = m/abc/ m/[a-z]/!.', [
        'abc',                              1,     'abc',
        'abc1',                             1,     'abc',
        'abcx',                             undef, undef,
        'abcd',                             undef, undef,
    ],
    'peek1 ::= $$r0 = $$offset \'abc\' $$offset = $$r0 $$ = \'abcd\'.', [
        '',                                 undef, undef,
        'xbc',                              undef, undef,
        'abc',                              undef, undef,
        'abcd',                             1,     'abcd',
    ],
    'r1 ::= m/abc[^!\\]]/.', [
        '',                                 undef, undef,
        'abc',                              undef, undef,
        'abcd',                             1,     undef,
        'abc!',                             undef, undef,
    ],
    'r2 => { $d } ::= $d = m![-+]?[0-9]+!.', [
        '',                                 undef, undef,
        '0',                                1,     { d => '0' },
        '-1',                               1,     { d => '-1' },
        '1234',                             1,     { d => '1234' },
    ],
    "l1 => { \$a \$b } ::= \$a = 'A' | \$b = 'B'.", [
        '',                                 undef, undef,
        'a',                                undef, undef,
        'A',                                1,     { a => 'A', },
        'B',                                1,     { b => 'B' },
    ],
    "l2 => { \$a \$b } ::= '_' \$a = ('A' | 'B').", [
        '',                                 undef, undef,
        'A',                                undef, undef,
        '_A',                               1,     { a => 'A', },
        '_B',                               1,     { a => 'B', },
    ],
    'c1 ::= &custom1.',  [
        '',                                 1,      '*custom1*',
        'xxxx',                             1,      '*custom1*',
    ],
    'c2 ::= &custom1[ "abc" "123" 1 ].', [
        'xxxx',                              1,      [ 'abc', '123', 1 ],
    ],
    'vc1 ::= $$ = "ABC".', [
        '',                                 1,      'ABC',
        'xxx',                              1,      'ABC',
    ],
    'call1 ::= r2.', [
        '0',                                1,      undef,,
    ],
    'call2 ::= $$ = r2.', [
        '0',                                1,      { d => '0' },
    ],
    'trace1 ::= &&trace_flags[3].', [
        '',                                 1,      sub {
                                                        my ($value, $parser) = @_;
                                                        return $parser->trace_flags == 3;
                                                    }
    ],
    'iftrue ::= $$r0 = m/[0-9]+/ &&if_true[ $$r0 ] $$ = $$r0.', [
        '',                                 undef,  undef,
        '0',                                undef,  undef,
        '1',                                1,      '1',
    ],
    'iffalse ::= $$r0 = m/[0-9]+/ &&if_false[ $$r0 ] $$ = $$r0.', [
        '',                                 undef,  undef,
        '0',                                1,      '0',
        '1',                                undef,  undef,
    ],
    'f0 ::= $$ = "MM" &&fatal["abc \'\' " $$ " efg"].', [ # multiple single quote handling included in this test
        '',                                 undef, "abc '' MM efg at line 1, char 1 while parsing f0\n",
        'aaaa',                             undef, "abc '' MM efg at line 1, char 1 while parsing f0\naaaa",
        "aaaa\n",                           undef, "abc '' MM efg at line 1, char 1 while parsing f0\naaaa",
    ],
    'f1 ::= m/\s+/? \'aaaa\' $$ = "MM" &&fatal["abc " $$ " efg"].', [
        'aaaa',                             undef, "abc MM efg at line 1, char 5 while parsing f1\naaaa",
        'aaaabb',                           undef, "abc MM efg at line 1, char 5 while parsing f1\naaaabb",
        "\naaaa \n",                        undef, "abc MM efg at line 2, char 5 while parsing f1\naaaa ",
    ],
    'f2 ::= $$r0 = "MM" &&fatal["abc " $$r0 " efg"].', [
        "\nbbb",                            undef, "abc MM efg at line 1, char 1 while parsing f2\n",
    ],
    'f3 => { $a } ::= $a = "MM" &&fatal["abc " $a " efg"].', [
        "\nbbb",                            undef, "abc MM efg at line 1, char 1 while parsing f3\n",
    ],
    'new1 => WWTest::ParserGen::ASTPkg { $a $b } ::= $a = \'AA\' $b = 2 | $a = "X" $b = \'123\'.', [
        '',                                 undef, undef,
        'AA',                               1, { a => 'AA', b => 2 },
        '123',                              1, { a => 'X',  b => 123 },
        'AA',                               1, sub { ref ($_[0]) eq 'WWTest::ParserGen::ASTPkg' },
    ],
    'qmark1 ::= ( \'aa\' \'Z\'? | m/cdef*/ \'g\' )?.', [
        '',                                 1,      undef,
        'aaaa',                             1,      undef,
        'cdegaaa',                          1,      undef,
        'cdef',                             1,      undef,
        'a',                                1,      undef,
        'aaZ',                              1,      undef,
        'cdefffgg',                         1,      undef,
    ],
    'qmark2 ::= ( $$r1 = \'aa\' $$r2 = \'Z\'? | $$r1 = m/cdef*/ $$r2 = \'g\' )?' .
            ' $$ = $$r2 $$ += $$r1.', [
        '',                                 1,      undef,
        'aaaa',                             1,      'aa',
        'cdegaaa',                          1,      'gcde',
        'cdef',                             1,      'cdef', # partial match not rolled back
        'a',                                1,      undef,
        'aaZ',                              1,      'Zaa',
        'cdefffgg',                         1,      'gcdefff',
    ],
    'iter1 ::= ( $$r1 = \'ab\' $$r2 = m/[xyz]/ $$r2 += $$r1 $$r3 << $$r2 )* $$ = $$r3.', [
        '',                                 1,      undef,
        'ab',                               1,      undef,
        'feufb',                            1,      undef,
        'abx',                              1,      [ 'xab' ],
        'abxab',                            1,      [ 'xab' ],
        'abxabz',                           1,      [ 'xab', 'zab' ],
        'abxabzab',                         1,      [ 'xab', 'zab' ],
        'abxabqq',                          1,      [ 'xab' ],
    ],
    'iter2 ::= ( $$r1 = \'ab\' $$r2 = m/[xyz]/ $$r2 += $$r1 $$r3 << $$r2 )+ $$ = $$r3.', [
        '',                                 undef,  undef,
        'ab',                               undef,  undef,
        'feufb',                            undef,  undef,
        'abx',                              1,      [ 'xab' ],
        'abxab',                            1,      [ 'xab' ],
        'abxabz',                           1,      [ 'xab', 'zab' ],
        'abxabzab',                         1,      [ 'xab', 'zab' ],
        'abxabqq',                          1,      [ 'xab' ],
    ],
    # test merge of multiple defs
    'multidef ::= \'abc\'.', [
        '',                                 undef,  undef,
        'abc',                              1,      undef,
        '123',                              1,      '123',
    ],
    'multidef ::= $$ =  \'123\'.', [
        '',                                 undef,  undef,
        'abc',                              1,      undef,
        '123',                              1,      '123',
    ],
    # passing values to a rule
    'call3 ::= $$r3 = 123 $$r5 = "abc" $$ = &&call[swap $$r5 $$r3].' .
        'swap => { $a $b } ::= $a = $$r1 $b = $$r0.', [

        '',                                 1,      { a => 123, b => 'abc' },
    ],
    'rvs1 => { $a $b } ::= $a = m/[a-z]+/ $$rule_vars ?= _rvs1. _rvs1 => { $b } ::= $b = m/[0-9]+/.', [
        '',                                 undef, undef,
        'abc123',                           1,      { a => 'abc', b => '123' },
    ],
    'cctok ::= $$ = cctok1. &cctok1 ::= m[ a b ].', [
        '',                                 undef, undef,
        'a',                                1,     'a',
        'b',                                1,     'b',
        'c',                                undef, undef,
    ],
    'cc1 ::= $$ = m[ a b c (\) {|} / ].', [
        '',                                 undef, undef,
        'a',                                1,     'a',
        'd',                                undef, undef,
        '(',                                1,     '(',
        '\\',                               1,     '\\',
        ')',                                1,     ')',
        '{',                                1,     '{',
        '|',                                1,     '|',
        '}',                                1,     '}',
        '/',                                1,     '/',
    ],
    'cc2 ::= $$ = m[ \'[]<>\' abc -\\ " 0x0A < A-F ! B > < 0x30 - 0x3B ! : > ].', [
        '',                                 undef, undef,
        'B',                                undef, undef,
        ':',                                undef, undef,
        "\x0A",                             1,     "\x0A",
        map { ( $_, 1, $_ ) } qw( [ ] < > a b c - \ " A C D E F 0 1 2 3 4 5 6 7 8 9 ; ),
    ],
    'tok1 ::= $$ = tok1def. &tok1def ::= 0x0A 0x0D \'' . $all_perl_qchars . "'.", [
        '',                                 undef, undef,
        "\x0A\x0D" . $all_8bit_chars,       1,     "\x0A\x0D" . $all_8bit_chars,
    ],
    'tok2 ::= $$ = tok2def. &tok2def ::= \'a\' ( \'c\' | \'d\' ) \'e\'.', [
        '',                                 undef, undef,
        'acex',                             1,     'ace',
        'adex',                             1,     'ade',
    ],
    'tok3 ::= $$ = tok3test. &tok3test ::= m[ _ <a-z> <A-Z> ] m[ _ <a-z> <A-Z> <0-9> ]*.', [
        '',                                 undef, undef,
        '_',                                1,     '_',
        'az+',                              1,     'az',
        '0a',                               undef, undef,
        'ABC1234567890wxyz_',               1,     'ABC1234567890wxyz_',
    ],
    'tok4 ::= $$ = tok4case. &tok4case :case_insensitive ::= \'ab\' m[ cdef ].', [
        '',                                 undef, undef,
        'abd',                              1,     'abd',
        'Abc',                              1,     'Abc',
        'aBf',                              1,     'aBf',
        'abE',                              1,     'abE',
    ],
    'tok5 ::= $$ = tok5or. &tok5or ::= m/a|b/ m/\w/!.', [
        '',                                 undef, undef,
        'a',                                1,     'a',
        'b',                                1,     'b',
        'c',                                undef, undef,
        'ab',                               undef, undef,
        'a!',                               1,     'a',
    ],
    'cmatch1 ::= $$r0 = "B" $$ = &_cmatch1["A"]. &_cmatch1 ($$ $$text_ref $$offset $$rule_vars $$r0 $$r1 $$r2 $$r9 $str) { ' . 
        '$ctx->{match_value} = $str . $r0;' . "\n}", [
        '',                                 1,     'AB',
    ],
    'texpr ::= $$ = expr.', [
        '',                                 undef, undef,
        '9 ',                               1,     9,
        '1 + 2',                            1,     { operator => '+', left_arg => '1', right_arg => '2' },
        '1 + 2 * 3 + 4',                    1,     { operator => '+',
                                                     left_arg  => {
                                                         operator => '+',
                                                         left_arg => 1,
                                                         right_arg => { operator => '*', left_arg => 2, right_arg => 3 },
                                                     },
                                                     right_arg => 4,
                                                   },
        'a := 3 / 4 ',                      1,     { operator => ':=',
                                                     left    => { operator => '/', left_arg => 3, right_arg => '4' },
                                                     right   => 'a',
                                                   },
        '1 ANDx 2',                         1,     1,
        '1 AND 2',                          1,     { operator => 'AND', left_arg => 1, right_arg => 2 },
    ],
    'km1 ::= $$ = key_match_test.', [
        '',                                 undef, undef,
        'abc',                              1,     'abc',
        'abcdef',                           1,     'abcdef',
        'abcde',                            undef, undef,
        '  ',                               1,     ' ',
    ],
);

#===================================================================================================
# utils
#===================================================================================================
sub replace_parse_pkg($$$) {
    my ($ebnf, $old_pkg, $new_pkg) = @_;
    my $answer = $ebnf . ' ';
    my $i = index ($answer, $old_pkg);
    unless ($i >= 0) {
        require Carp;
        Carp::confess ("old package $old_pkg not found in " . substr ($answer, 0, 400));
    }
    substr ($answer, $i, length ($old_pkg)) = $new_pkg;
    return $answer;
}

sub print_to_file($$) {
    my ($file_path, $text) = @_;
    $file_path = '/tmp/' . $file_path unless $file_path =~ m!^/!;
    open (my $ofh, '>', $file_path) or die "Error creating $file_path";
    print $ofh $text;
    close $ofh;
}

#===================================================================================================
# test the parser engine
#===================================================================================================
#\@use WWTest::ParserGen::CMatch qw( :all ).

my $test_pkg = 'WW::ParserGen::WWTestParser';
my $test_grammar = <<"TEXT";
\@package $test_pkg.
\@use WWTest::ParserGen:: qw( :all ).
\@match custom1.
\@infix_operators expr1 {
    "+"     left    90
    "-"     left    90
    "*"     left    100
    "/"     left    100
    ":="    right   10      &bin_op
    "AND"   left    50
    "OR"    left    40
}

&bin_op () {
    \$ctx->{match_status} = 1;
    \$ctx->{match_value} = {
        left        => \$ctx->register (0),
        operator    => \$ctx->register (1),
        right       => \$ctx->register (2),
    };
}

&ws ::= m[ ' ' 0x09 0x0D 0x0A ]+.

expr ::= 
    \$\$r0 = expr_atom (
        (
            ws? &&infix_operator[expr1] 
            ( ws? \$\$r1 = expr_atom &&infix_operator_arg
                | &&fatal["expected <expr> after operator"] )
        )+
        \$\$r0 = &&infix_expr_tree
    )? \$\$ = \$\$r0.

expr_atom ::= 
    (
        \$\$r0 = m/[0-9]+/ |
        \$\$r0 = m/[_a-zA-Z]+/
    ) \$\$ = \$\$r0.

key_match_test ::= \$\$ = &&key_match {
    'ab'        => 'abc'        |
    abcde       => 'abcdef'     |
    ' '         => 0x20
}.

TEXT

for (my $i=0; $i<@cases; $i+=2) {
    $test_grammar .= $cases[$i] . "\n\n";
}

my $trace_flags = $opts->trace1 || 0;
print_to_file ('01-test-grammar-bootstrap.ebnf', $test_grammar) if $trace_flags;
my ($test_parser, $base_trule_defs_ast, $parse_pkg0) = build_parser ('Test/grammar:Bootstrap/Parser', $test_grammar, $test_pkg, undef, $trace_flags);
print_to_file ('01-test-ppkg-bootstrap.pm', $parse_pkg0) if $trace_flags;
$test_parser->use_trace_package if $trace_flags;
run_cases ($test_parser, $trace_flags);

#===================================================================================================
# use bootstrap parser to build PDA version of ebnf parser
#===================================================================================================
use Cwd;
my $ebnf_file;
for (@INC) {
    next if ref ($_) || !defined ($_);
    my $path = Cwd::abs_path ($_ . '/WW/ParserGen/PDA/grammar.ebnf');
    next unless defined $path;
    if (-f $path) {
        $ebnf_file = $path;
        last;
    }
}
die ("could not find WW/ParserGen/PDA/grammar.ebnf in INC")
    unless $ebnf_file;

my $ebnf_pkg = 'WW::ParserGen::PDA::GrammarOps';
my $ebnf_grammar = '';
open (my $ifh, '<', $ebnf_file) or die "error opening $ebnf_file";
while (sysread ($ifh, $ebnf_grammar, 16000, length ($ebnf_grammar))) {}
my $ebnf0_pkg = $ebnf_pkg . '0';
my $ebnf0_grammar = replace_parse_pkg ($ebnf_grammar, 'WW::ParserGen::PDA::GrammarOps', $ebnf0_pkg);

# use the bootstrap parser to build a PDA-based ebnf parser
$trace_flags = $opts->trace2 || 0;
print_to_file ('02-ebnf-grammar-ebnf-bs.ebnf', $ebnf_grammar) if $trace_flags;
my ($ebnf_parser, $ebnf_rule_defs_ast0, $parse_pkg0b) = build_parser ('PDA/grammar:Bootstrap/parser', $ebnf0_grammar, $ebnf0_pkg);
print_to_file ('02-ebnf-ppkg-ebnf-bs.pm', $parse_pkg0b) if $trace_flags;

$ebnf_parser->use_trace_package if $trace_flags;
my ($pstatus, $ebnf_rule_defs_ast0b) = $ebnf_parser->parse_text ('rule_defs', \$test_grammar, $trace_flags);
ok ($pstatus, 'PDA ebnf parse on test_grammar');

my $test1_pkg = $test_pkg .'1';
my $test1_grammar = replace_parse_pkg ($test_grammar, $test_pkg, $test1_pkg);
print_to_file ('02-test-grammar-pda-01.ebnf', $test1_grammar) if $trace_flags;
my ($test1_parser, $test1_rule_defs_ast, $parse_pkg1) = build_parser ('Test/ebnf:PDA/parser1', $test1_grammar, $test1_pkg, $ebnf_parser, $trace_flags);
print_to_file ('02-test-ppkg-pda-01.pm', $parse_pkg1) if $trace_flags;

$test1_parser->use_trace_package if $trace_flags;
run_cases ($test1_parser, $trace_flags);

#===================================================================================================
# use 1st generation parser to build 2nd generation parser
#===================================================================================================
$trace_flags = $opts->trace3 || 0;
my $ebnf2_pkg = $ebnf_pkg . '2';
my $ebnf2_grammar = replace_parse_pkg ($ebnf_grammar, $ebnf_pkg, $ebnf2_pkg);
print_to_file ('03-ebnf-grammar-pda-01.ebnf', $ebnf2_grammar) if $trace_flags;
my ($ebnf2_parser, $ebnf2_rule_defs_ast, $parse2_pkg) = build_parser ('PDA/ebnf:PDA/parser', $ebnf2_grammar, $ebnf2_pkg, $ebnf_parser, $trace_flags);
print_to_file ('03-ebnf-ppkg-pda-01.pm', $parse2_pkg) if $trace_flags;

my $test2_pkg = $test_pkg .'2';
my $test2_grammar = replace_parse_pkg ($test_grammar, $test_pkg, $test2_pkg);
my ($test2_parser, $test2_rule_defs_ast) = build_parser ('Test/ebnf:PDA/parser2', $test2_grammar, $test2_pkg, $ebnf2_parser, $trace_flags);

run_cases ($test2_parser);

#===================================================================================================
# build 3rd generation parser as check
#===================================================================================================
$trace_flags = $opts->trace4 || 0;
my $ebnf3_pkg = $ebnf_pkg . '3';
my $ebnf3_grammar = replace_parse_pkg ($ebnf_grammar, $ebnf_pkg, $ebnf3_pkg);
print_to_file ('04-ebnf-grammar-pda-02.ebnf', $ebnf3_grammar) if $trace_flags;

my ($ebnf3_parser, $ebnf3_rule_defs_ast, $parse3_pkg) = build_parser ('PDA/ebnf:PDA/parser3', $ebnf3_grammar, $ebnf3_pkg, $ebnf2_parser, $trace_flags);
print_to_file ('04-ebnf-ppkg-pda-02.pm', $parse3_pkg) if $trace_flags;

# hack to make the comparison work
$ebnf3_rule_defs_ast->{parser_pkg} = $ebnf2_rule_defs_ast->{parser_pkg};
is_deeply ($ebnf3_rule_defs_ast, $ebnf2_rule_defs_ast, '3rd gen parser check');

#===================================================================================================
sub build_parser {
    my ($ident, $parser_ebnf, $parser_pkg_name, $parser, $trace_flags, $show_parser_pkg) = @_;
    if ($parser) {
        isa_ok ($parser, 'WW::Parse::PDA::Engine', 'ebnf_parser');
    }
    else {
        require WW::ParserGen::PDA::EBNFParser;
        $parser = WW::ParserGen::PDA::EBNFParser->new;
    }
    my $generator = new_ok ('WW::ParserGen::PDA::Generator');

    my ($rule_defs_ast, $error_msg);
    my $start_time = time;
    if (my $m = $parser->can ('parse_ebnf')) {
        ($rule_defs_ast, $error_msg) = $parser->parse_ebnf ($ident, $parser_ebnf, $trace_flags);
        diag ("$ident ebnf error:\n  ", ($error_msg || '<empyt>')) unless $rule_defs_ast;
    }
    else {
        # plain PDA::Engine
        my $status;
        $parser->use_trace_package if $trace_flags;
        ($status, $rule_defs_ast) = $parser->parse_text ('rule_defs', \$parser_ebnf, $trace_flags);
        unless ($status) {
            $error_msg = $rule_defs_ast;
            $rule_defs_ast = undef;
        }
    }
    my $end_time = time;

    note ("parse time for $ident: " . ($end_time - $start_time) . ' seconds');

    isa_ok ($rule_defs_ast, 'WW::ParserGen::PDA::AST::RuleDefs');
    ok (!defined ($error_msg), " $ident ebnf parse");
    if ($error_msg) {
        say STDERR "=========================================================\n",
                   $ident, "\n",
                   "---------------------------------------------------------\n",
                   $parser_ebnf,
                   "\n=========================================================";
        say STDERR "$ident ebnf parse failed: ", $error_msg;
        BAIL_OUT ("$ident: $error_msg");
    }

    lives_ok {
        $generator->generate_for_rule_defs ($rule_defs_ast);
    } 'generate_for_rule_defs';

    my $parser_pkg = '';
    open (my $ofh, '>', \$parser_pkg) or die "error on parser_pkg string open";
    
    my $writer = new_ok (
        'WW::ParserGen::PDA::PerlPackageMaker',
        [
            rule_defs_ast       => $rule_defs_ast,
            pda_info_list       => [ $generator->rule_def_pdas_list ],
            op_defs             => $generator->op_defs,
            literal_map         => $generator->literal_map,
            regex_map           => $generator->regex_map,
            token_map           => $generator->token_map,
        ]
    );
    
    $writer->write_op_package ($ofh);
    close $ofh;
    ok (1, 'write_op_package');

    if ($show_parser_pkg) {
        say STDERR "==========================================================\n",
               $parser_pkg,
               "\n==========================================================";
    }

    eval ($parser_pkg);
    if ($@) {
        my $msg = $@;
        say STDERR "parse ops package compile failed: ",
            substr ($msg, 0, 400), (length ($msg) > 500 ? substr ($msg, -200) : '');
        open (my $tmp_pkg_ofh, '>', '/tmp/parser_gen.t-parser_pkg.pm');
        print $tmp_pkg_ofh $parser_pkg;
        close $tmp_pkg_ofh;
        die ('parse ops package compile error');
    }
    pass ('parse ops package compile');

    return (
        new_ok (
            'WW::Parse::PDA::Engine', [ %{ $parser_pkg_name->get_op_tables } ]
        ),
        $rule_defs_ast,
        $parser_pkg
    );
}

#===================================================================================================
sub run_cases {
    my ($test_parser, $trace_flags) = @_;
    for (my $i=0; $i<@cases; $i+=2) {
        my $rule_def    = $cases[$i];
        my $rule_tests  = $cases[$i+1];
    
        $rule_def =~ m/^\s*(\S+)/;
        my $rule_name = $1;
    
        for (my $i=0; $i<@$rule_tests; $i+=3) {
            my $text      = $rule_tests->[$i];
            my $e_status  = $rule_tests->[$i+1];
            my $e_value   = $rule_tests->[$i+2];
    
            my ($status, $value) = $test_parser->parse_text ($rule_name, \$text, $trace_flags);

            # handle string overloading
            my $orig_value = $value;
            if (ref ($value) && reftype ($value) eq 'HASH') {
                 $value = { %$value };
            }
            ok ($status && $e_status || !$status && !$e_status, "status: $rule_name <<$text>>");
            if (ref ($e_value) eq 'CODE') {
                ok ($e_value->($orig_value, $test_parser), "value:  $rule_name <<$text>>");
            }
            else {
                is_deeply ($value, $e_value, "value:  $rule_name <<$text>>");
            }
        }
    }
}

#===================================================================================================
use Getopt::Long::Descriptive;
sub parse_args {
    my ($opts, $usage) = describe_options (
        '%c %o',
        [ 'trace1+'     => 'trace test phase 1' ],
        [ 'trace2+'     => 'trace test phase 2' ],
        [ 'trace3+'     => 'trace test phase 3' ],
        [ 'trace4+'     => 'trace test phase 4' ],
        [],
        [ 'help|h'      => 'display this help message' ],
    );
    if ($opts->help) {
        say STDERR $usage;
        exit 0;
    }
    return $opts;
}

