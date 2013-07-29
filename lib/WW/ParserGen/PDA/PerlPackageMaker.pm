package WW::ParserGen::PDA::PerlPackageMaker;
use feature qw(:5.10);
use strict;

use Module::Find;
use WW::Parse::PDA::VarSetOps qw( :op_funcs );

use Moose;

has rule_defs_ast => (
    is          => 'ro',
    isa         => 'WW::ParserGen::PDA::ASTBase',
    required    => 1,
);

has [qw( op_defs literal_map regex_map token_map )] => (
    is          => 'ro',
    isa         => 'HashRef',
    required    => 1,
);

has [qw( pda_info_list )] => (
    is          => 'ro',
    isa         => 'ArrayRef',
    required    => 1,
);

has _ofh => (
    is          => 'rw',
    init_arg    => undef,
);

has [qw( literal_list regex_list token_list rule_def_map )] => (
    is          => 'ro',
);

sub BUILD {
    my ($self, $args) = @_;

    for (qw( literal regex )) {
        my @list;
        my $map = $self->{"${_}_map"};
        while (my ($str, $index) = each (%$map)) {
            $list[$index] = $str;
        }
        $self->{"${_}_list"} = \@list;
    }

    $self->{rule_def_map} = {};
    $self->{token_list} = [
        sort { $a->token_name cmp $b->token_name } values %{$self->token_map}
    ];
}

no Moose;
__PACKAGE__->meta->make_immutable;

use WW::Parse::PDA::OpDefs qw( PDA_ENGINE_VERSION ); 

sub write_op_package {
    my ($self, $ofh) = @_;
    $self->_ofh ($ofh);

    my $rule_defs_ast = $self->rule_defs_ast;
    $self->_comment_block ('#',
       $rule_defs_ast->parser_pkg, ' PDA ENGINE VERSION: ', PDA_ENGINE_VERSION,
    );
    $self->_pkg_prolog;
    $self->_regex_ops;
    $self->_op_addresses;
    $self->_op_trace_flags;
    $self->_strings;
    $self->_rule_def_starts;
    $self->_infix_op_tables;
    $self->_ops_list;
    $self->_pkg_epilog;
}

sub _pkg_prolog {
    my ($self) = @_;
    my $ofh = $self->_ofh;
    my $rule_defs_ast = $self->rule_defs_ast;
    say $ofh 'package ', $rule_defs_ast->parser_pkg, ";\n",
             "use feature qw(:5.12);\n",
             "use strict;\n\n",
             "use Scalar::Util qw( refaddr );\n",
             "use WW::Parse::PDA::OpDefs qw( :op_funcs :op_helpers );";

    my %modules; my @module_find_list;
    for my $use_pkg (@{$rule_defs_ast->pkg_use_list}) {
        my $fq_pkg = $use_pkg->fq_package;
        if ($fq_pkg =~ m/::$/) {
            push @module_find_list, $use_pkg;
            next;
        }

        next if $modules{$fq_pkg}++;
        my $args = $use_pkg->use_args;
        say $ofh "use $fq_pkg",
            ($args && @$args ? ' qw( ' . join (' ', @$args) . ' )' : ''),
            ';';
    }

    for my $use_pkg (@module_find_list) {
        my $args = $use_pkg->use_args;
        $args = $args && @$args ? ' qw( ' . join (' ', @$args) . ' )' : '';
        my $fq_pkg = '' . $use_pkg->fq_package;
        $fq_pkg =~ s/::$//;
        my @found = Module::Find::findallmod ($fq_pkg); # force list context
        for (sort @found) {
            next if $modules{$_}++;
            say $ofh "use ${_}$args;";
        }
    }

    say $ofh "\nBEGIN {\n",
             "    die (__PACKAGE__ . ' needs at least version " . PDA_ENGINE_VERSION . " of WW::Parse::PDA::OpDefs')\n",
             "        unless \$WW::Parse::PDA::OpDefs::MIN_COMPAT_VERSION le '" . PDA_ENGINE_VERSION . "';\n",
             "}";
    say $ofh ''
}

sub _regex_ops {
    my ($self) = @_;
    my $ofh = $self->_ofh;

    $self->_comment_block ('=', 'Regex/Token/Perl Match Ops');
    my $i = -1;
    for my $regex (@{$self->regex_list}) {
        $i++; my $set_match = $regex =~ /m.\\G\(/;
        print $ofh <<CODE;
sub regex$i(\$\$\$) {
    my (\$ctx, \$idx, \$op_list) = \@_;
    my \$text_ref = \$ctx->{text_ref};
    \$ctx->{match_status} = \$\$text_ref =~ $regex;
CODE
        if ($set_match) { say $ofh '    $ctx->{match_value} = $1;'; }
        say $ofh "    return \$idx + 2;\n}\n";
    }

    for (@{$self->token_list}) {
        my ($name, $regex) = @$_{qw( token_name token_regex )};
        my $q = $_->is_case_insensitive ? 'i' : '';
        print $ofh <<CODE;
sub token_$name(\$\$\$) {
    my (\$ctx, \$op_index, \$op_list) = \@_;
    my \$set_match = \$op_list->[\$op_index + 1];
    my \$text_ref = \$ctx->{text_ref};

    my \$start_pos = pos (\$\$text_ref);
    if (\$\$text_ref =~ m/$regex/gc$q) {
        \$ctx->{match_status} = 1;
        \$ctx->{match_value} = substr (
            \$\$text_ref, \$start_pos, pos (\$\$text_ref) - \$start_pos
        ) if \$set_match;
    }
    else {
        \$ctx->{match_status} = undef;
        \$ctx->{match_value}   = undef if \$set_match;
    }
    return \$op_index + 2;
}

CODE

    }

    if (my $custom_matches = $self->rule_defs_ast->custom_match_list) {
        for (sort { $a->match_name cmp $b->match_name } @$custom_matches) {
            next unless $_->code;
            my $name        = $_->match_name;
            my $arg_names   = $_->arg_names;
            my $code        = '' . $_->code;
            $code =~ s/^\s+|\s+$//g;
            my ($arg_init1, $arg_init2) = ( '', '' );
            my $op_arg_count = 0;
            if ($arg_names) {
                for (@$arg_names) {
                    when ('$$')                 { $arg_init1 .= "\n    my \$match_value = \$ctx->{match_value};"; }
                    when ('$$text_ref')         { $arg_init1 .= "\n    my \$text_ref    = \$ctx->{text_ref};"; }
                    when ('$$offset')           { $arg_init1 .= "\n    my \$offset      = \$ctx->{offset};"; }
                    when ('$$rule_vars')        { $arg_init1 .= "\n    my \$rule_vars   = \$ctx->{rule_vars};"; }
                    when (/^[\$][\$]r([\d]$)/)  { $arg_init1 .= "\n    my \$r$1          = \$ctx->register ($1);"; }
                    when (/^[\$][\$]/)          { die "unimplemented global var type $_" }
                    default {
                        $arg_init2 = $op_arg_count++ ? $arg_init2 . ", " . $_ : "\n    my ($_";
                    }
                }
            }
            $arg_init1 .= "\n    my \$op_args  = \$op_list->[\$op_index+1];" if $op_arg_count;
            if ($op_arg_count == 1) {
                $arg_init2 .= ') = ( $op_args->[0] );';
            }
            elsif ($op_arg_count) {
                $arg_init2 .= ') = @$op_args[0..' . ($op_arg_count - 1) . '];';
            }
            $code .= "\n    \$ctx->{match_status} = 1;" unless $code =~ /{match_status}|->match_status/;
            $code .= "\n    return \$op_index + 2;" unless $code =~ /return\s+[\$]op_index\s+[+]/;
            say $ofh <<CODE;
sub $name(\$\$\$) {
    my (\$ctx, \$op_index, \$op_list) = \@_;$arg_init1$arg_init2
    $code
}
CODE
        }
    }
}

sub _comment_str;
sub _perl_str_const;

sub _op_addresses {
    my ($self) = @_;
    my $ofh = $self->_ofh;
    $self->_comment_block ('=', 'Op Addresses to Names');
    say $ofh 'our %OP_ADDRESS_NAMES;', "\n",
             "BEGIN {\n",
             "    return if scalar (keys (\%OP_ADDRESS_NAMES));\n",
             "    \%OP_ADDRESS_NAMES = (";
    for (sort { $a->op_type cmp $b->op_type } values %{$self->op_defs}) {
        say $ofh '        refaddr (\\&', sprintf ('%-35s', $_->op_type . ')'),
                    " => '", $_->op_type, "',";
    }
    my $i = 0;
    for my $regex (@{$self->regex_list}) {
        my $name = "$regex";
        $name =~ s/^m.\\G[\(]?|[\)]?.gc$//g;
        say $ofh '        refaddr (\\&', sprintf ('%-35s', 'regex' . $i . ')'),
                    ' => ', _perl_str_const ("<< $name >>"), ',';
        $i++;
    }
    if (my $custom_matches = $self->rule_defs_ast->custom_match_list) {
        for (sort { $a->match_name cmp $b->match_name } @$custom_matches) {
            my $name = $_->match_name;
            say $ofh '        refaddr (\\&', sprintf ('%-35s', $name . ')'), " => '$name',";
        }
    }
    for (@{$self->token_list}) {
        my $name = $_->token_name;
        say $ofh '        refaddr (\\&', sprintf ('%-35s', "token_$name)"), " => '$name',";
    }
    say $ofh "    );\n",
             "}\n";
}

sub _op_trace_flags {
    my ($self) = @_;
    my $ofh = $self->_ofh;
    $self->_comment_block ('=', 'Op Addresses to Trace Flags');
    say $ofh 'our %OP_ADDRESS_TRACE_FLAGS;', "\n",
             "BEGIN {\n",
             "    return if scalar (keys (\%OP_ADDRESS_TRACE_FLAGS));\n",
             "    \%OP_ADDRESS_TRACE_FLAGS = (";
    for (sort { $a->op_type cmp $b->op_type } values %{$self->op_defs}) {
        say $ofh '        refaddr (\\&', sprintf ('%-35s', $_->op_type . ')'),
                    " => ", $_->trace_flags, ",";
    }
    my $i = 0;
    my $op_def = $self->op_defs->{regex_match};
    for my $regex (@{$self->regex_list}) {
        my $name = "$regex";
        $name =~ s/^m.\\G[\(]?|[\)]?.gc$//g;
        say $ofh '        refaddr (\\&', sprintf ('%-35s', 'regex' . $i . ')'),
                    ' => ', $op_def->trace_flags, ',';
        $i++;
    }
    
    $op_def = $self->op_defs->{token_match};
    for (@{$self->token_list}) {
        my $name = $_->token_name;
        say $ofh '        refaddr (\\&', sprintf ('%-35s', "token_$name)"),
                    ' => ', $op_def->trace_flags, ',';
    }
    say $ofh "    );\n",
             "}\n";
}

sub _strings {
    my ($self) = @_;
    my $ofh = $self->_ofh;
    for (qw( literal regex )) {
        my $list = $self->{"${_}_list"};
        $self->_comment_block ('=', ucfirst ("$_"), " List");
        say $ofh 'our @', uc ("$_"), '_LIST = (';
        my $i = 0;
        for my $str (@$list) {
            if ($i && ($i % 10) == 0) { say '    # ', $i; }
            say $ofh '    ', _perl_str_const ($str), ',';
        }
        say $ofh ");\n";
    }
}

sub _rule_def_starts {
    my ($self) = @_;
    my $ofh = $self->_ofh;
    $self->_comment_block ('=', 'Rule Def Start Indexes');
    say $ofh 'our %RULE_DEF_INDEXES = (';
    for (@{$self->pda_info_list}) {
        say $ofh '    ', sprintf ('%-30s', $_->rule_name ), ' => ', 
            $_->start_index, ',';
        $self->rule_def_map->{$_->start_index} = $_->rule_name;
    }
    say $ofh ");\n";

    $self->_comment_block ('=', 'Rule Def Names');
    say $ofh 'our %RULE_DEF_NAMES = (';
    for (@{$self->pda_info_list}) {
        say $ofh '    ', sprintf ('%5d', $_->start_index),
                    " => '", $_->rule_name, "',";
    }
    say $ofh ");\n";
}

sub _infix_op_tables {
    my ($self) = @_;
    my $infix_op_tables = $self->rule_defs_ast->infix_op_tables;
    return unless $infix_op_tables;

    my $ofh = $self->_ofh;
    $self->_comment_block ('=', 'Infix Op Tables');
    say $ofh 'our %INFIX_OP_TABLES = (';
    for (sort keys %$infix_op_tables) {
        my $op_table = $infix_op_tables->{$_};
        say $ofh '    ', $_, ' => {';
        say $ofh "        ' op_len ' => [ ", join (', ', @{$op_table->{operator_lengths}}), ' ],';
        for (sort { $a->{operator} cmp $b->{operator} } values %{$op_table->{operators}}) {
            my ($op_str, $precedence) = (
                _perl_str_const ($_->{operator}),
                $_->{precedence},
            );
            say $ofh '        ', sprintf (
                '%-10s => [ %-10s %5d, %2d, %-27s%s ],', $op_str, $op_str . ',',
                    $_->{precedence}, $_->{assoc}, 
                    ($_->{constructor_op} ? '\\&' . $_->{constructor_op} : 'undef'),
                    ($_->{word_mode} ? ', 1' : '')
            );
        }
        say $ofh '    },';
    }
    say $ofh ");\n";
}

sub _ops_list {
    my ($self) = @_;
    my $ofh = $self->_ofh;
    $self->_comment_block ('=', 'Op List');
    say $ofh 'our @OP_LIST = (';
    my $index = 0;
    for (@{$self->pda_info_list}) {
        $index = $self->_rule_def_ops ($_, $index);
    }    
    say $ofh ');';
}

sub _rule_def_ops {
    my ($self, $rule_def_pda, $op_index) = @_;
    my $ofh = $self->_ofh;
    die (
        $rule_def_pda->rule_name . ' start index error: at ' .
        $op_index . ' want ' . $rule_def_pda->start_index
    ) unless $op_index == $rule_def_pda->start_index;

    if ($op_index) { say $ofh ''; }
    say $ofh '    #', ('-' x 80), "\n    # ", $rule_def_pda->rule_name,
                 ' [', $op_index, "]\n",
             '    #', ('-' x 80);

    for (@{$rule_def_pda->op_list}) {
        if ($_->ref_count) {
            say $ofh '# ', $op_index, ':';
        }
        $op_index = $self->_rule_def_op ($_, $op_index);
    }
    return $op_index;
}

sub _perl_value;

sub _rule_def_op {
    my ($self, $op, $op_index) = @_;
    my $ofh         = $self->_ofh;
    my $op_def      = $op->op_def;
    my $arg_names   = $op_def->arg_names;
    my $arg_types   = $op_def->arg_types;
    my $op_type     = $op_def->op_type;
    my $args        = $op->args;

    my $op_values = sprintf ('%-35s', 
        '    \\&' . (
            $op_type eq 'regex_match' ? 'regex' . $args->[0] : 
            $op_type eq 'token_match' ? 'token_' . $op->graph_node->token_name :
            $op_type eq 'custom_match' ? $op->graph_node->match_name : $op_type
        ) . ', '
    );
    my $op_comment = $op->op_comment ? "(" . $op->op_comment. ") " : '';
    my $i = -1;
    for (@$arg_types) {
        $i++;
        if (index ('Int/Str/Regex/RuleIndex/OpIndex/SetOp', $_) >= 0) {
            $op_values .= $args->[$i] . ', '; 
            if ($_ eq 'RuleIndex') {
                $op_comment .= $self->rule_def_map->{$args->[$i]} . ' ';
            }
            elsif ($_ eq 'Str') {
                $op_comment .= '<<' . _comment_str ($self->literal_list->[$args->[$i]]) . '>> ';
            }
            elsif ($_ eq 'Regex') {
                $op_comment .= '<<' . $self->regex_list->[$args->[$i]] . '>> ';
            }
            elsif ($_ eq 'SetOp') {
                $op_comment .= 'op:' . var_set_op_to_str (int ($args->[$i])) . ' ';
            }
            else {
                $op_comment .= $arg_names->[$i] . ' ';
            }
            next;
        }
        elsif ($_ eq 'OpTableName') {
            $op_values .= '$INFIX_OP_TABLES{' . $args->[$i] . '}, ';
            $op_comment .= '* ';
            next;
        }
        elsif ($_ eq 'OpIndexMap') {
            my $match_map = $args->[$i];
            $op_values .= '{ ' .  join (', ', 
                map { _perl_str_const ($_) . ' => ' . $match_map->{$_} } sort keys %$match_map
            ) . '}, ';
            $op_comment .= $arg_names->[$i] . ' ';
            next;
        }
        elsif ($_ eq 'IntArray') {
            $op_values .= '[ ' . join (', ', @{$args->[$i]}) . ' ], ';
            $op_comment .= $arg_names->[$i] . ' ';
            next;
        }

        $op_values .= _perl_value ($args->[$i]) . ', ';
    }

    $op_values = sprintf ('%-60s', $op_values);
    $op_comment =~ s/([*]\s*)+$//;
    $op_comment =~ s/\s+$//;
    if (length $op_comment) {
        $op_comment = ' # ' . $op_comment;
        $op_comment = "\n" . (' ' x 60) . $op_comment
            if length ($op_values) > 60;
            
    }
    say $ofh $op_values, $op_comment;
    return $op_index + 1 + $op_def->num_args;
}

sub _pkg_epilog {
    my ($self) = @_;
    my $ofh = $self->_ofh;
    say $ofh <<'CODE';

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

CODE
}

sub _comment_str($) {
    my $arg = $_[0];
    return '' unless defined $arg;

    my $text = '';
    for (my $i=0; $i<length($arg); $i++) {
        my $cp = ord (substr ($arg, $i, 1));
        if ($cp == 10)                  { $text .= '\\' . 'n'; }
        elsif ($cp < 32 || $cp == 128)  { $text .= '.' }
        else                            { $text .= chr ($cp) }
    }
    return $text;
}

sub _comment_block {
    my ($self, $hchar, @text) = @_;
    my @lines = split (/\n/, join ('', @text));
    say { $self->_ofh }
        '#', ($hchar x 80),
        join ('', map { "\n# " . $_ } @lines),
        "\n#", ($hchar x 80);
}

our %_QUOTED_CHARS;
BEGIN {
    return if scalar (keys %_QUOTED_CHARS);
    my $bs = chr (92);
    our %_QUOTED_CHARS = (
        9           => $bs . 't',
        10          => $bs . 'n',
        13          => $bs . 'r',
        34          => $bs . '"',
        36          => $bs . '$',
        37          => $bs . '%',
        64          => $bs . '@',
        92          => $bs . $bs,
    );
}

sub _perl_str_const {
    my $pconst = '';
    my $delimiter = "'";
    for (@_) {
        for (my $i=0; $i<length ($_); $i++) {
            my $chr = substr ($_, $i, 1);
            my $ccode = ord ($chr);
            if (my $quoted_form = $_QUOTED_CHARS{$ccode}) {
                $delimiter = '"';
                $pconst .= $quoted_form;
                next;
            }
            if ($ccode < 32 || ($ccode > 127 && $ccode < 65536)) {
                $delimiter = '"';
                $pconst .= '\\x' . sprintf ('%02x', $ccode);
                next;
            }
            if ($ccode >= 65535) {
                $delimiter = '"';
                $pconst .= '\x{' . sprintf ('%04x', $ccode) . '}';
                next;
            }
            $pconst .= $chr;
        }
    }
    $pconst =~ s/'/\\'/g if $delimiter eq "'";
    return $delimiter . $pconst . $delimiter;
}

use Scalar::Util qw( blessed );

sub _perl_value {
    my ($value) = @_;
    return 'undef' unless defined $value;
    return $value =~ m/^[-+]\d+$/ ? $value : _perl_str_const ($value)
        unless ref $value;

    if (blessed ($value) && (my $m = $value->can ('value'))) {
        my $v = $m->($value);
        my $m2 = $value->can ('value_type');

        for ($m2 && $m2->($value) || '') {
            when ('Int') { return int ($v); }
            when ('Str') { return _perl_str_const ($v); }
            default      { return _perl_value ($v); }
        }
    }

    for (ref ($value)) {
        when ('ARRAY') {
            return '[ ' . join (', ', map { _perl_value ($_) } @ $value) . ' ]';
        }
        when ('HASH') {
            return '{ ' . join (', ',
                map { "$_ => " . _perl_value ($value->{$_}) }
                    sort keys (%$value) 
            ) . ' }';
        }
    }
    require Carp;
    Carp::confess ("can't make perl literal for $value");
}

sub pda_op_pkg_writer {
    return __PACKAGE__->new (@_);
}

use Exporter qw( import );

our @EXPORT_OK = qw( pda_op_pkg_writer );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

