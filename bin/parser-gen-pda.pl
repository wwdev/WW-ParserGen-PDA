#!/usr/bin/perl -w
################################################################################
# parser-gen.pl --generate-op-pkg <ebnf-file>*
################################################################################
use feature qw(:5.12);
use strict;

use FindBin;
use lib "$FindBin::RealBin/../lib";

use Getopt::Long::Descriptive;
use WW::ParserGen::PDA::EBNFParser qw( parse_ebnf_rule_defs );
use WW::ParserGen::PDA::Generator qw( pda_op_generator );
use WW::ParserGen::PDA::PerlPackageMaker qw( pda_op_pkg_writer );

sub generate_op_pkg($$@);
sub generate_ast_classes($$$$$@);

my ($opts, $usage) = describe_options (
    '%c %o <ebnf-file-path> ...',
    [ 'verbose|v+'          => 'display progress/information messages on STDERR' ],
    [ 'trace|t+'            => 'trace file parsing' ],
    [ 'generate-op-pkg'     => 'generate parse ops package for use with WW::Parse::PDA::Engine' ],
    [ 'generate-ast-classes' => 'generate classes for the node packges defined in the rule defs' ],
    [ 'dest-dir=s'          => 'output destination directory', { default => '.' } ],
    [ 'base-ast-class=s'    => 'base class to use when generating ast classes' ],
    [],
    [ 'help|h'              => 'display option summary' ],
    [ 'version|V'           => 'display program version' ],
    [ 'pretend'             => 'do not actually write ast class files', ],
    [],
    [ 'One of --generate-op-pkg or --generate-ast-classes is required in command mode' ],
);

if ($opts->help) {
    say STDOUT $usage;
    exit 0;
}
if ($opts->version) {
    say STDOUT 'parser-gen.pl version 0.12.1';
    exit 0;
}

my $verbose     = $opts->verbose || $opts->pretend || 0;
my $trace_flags = $opts->trace   || 0;

generate_op_pkg ($verbose, $trace_flags, @ARGV)
    if $opts->generate_op_pkg;
generate_ast_classes (
    $verbose, $trace_flags, $opts->pretend, $opts->base_ast_class,
    $opts->dest_dir, @ARGV
) if $opts->generate_ast_classes;

say STDERR "$0: must specify one of --generate-op-pkg or --generate-ast-classes";
exit 1;

#===============================================================================
sub _load_rule_defs($$@) {
    my ($verbose, $trace_flags, @files) = @_;
    my $rules = '';
    if (@files) {
        for my $file_path (@files) {
            next unless defined ($file_path) && length ($file_path);
            open (my $ifh, '<', $file_path) or
                die ("$0: error opening $file_path: $!\n");
            if ($verbose) { say STDERR "reading ebnf rules file $file_path"; }
            while (sysread ($ifh, $rules, 32000, length ($rules))) {}
            if ($!) {
                say STDERR "$0: error reading $file_path: $!";
                exit (1);
            }
            close $ifh;
        }
    }
    else {
        push @files, '-';
        if ($verbose) { say STDERR "reading ebnf rules from STDIN"; }
        while (defined (my $line = readline (STDIN))) {
            $rules .= $line;
        }
    }

    my $ident = $files[0] . (1 < @files ? ', ...' : '');
    my ($rule_defs_ast, $error) = parse_ebnf_rule_defs ($ident, $rules, $trace_flags);
    unless ($rule_defs_ast) {
        say STDERR "Error parsing $ident:\n$error";
        exit 2;
    }
    return $rule_defs_ast;
}

#===============================================================================
sub generate_op_pkg($$@) {
    my ($verbose, $trace_flags, @files) = @_;
    my $rule_defs_ast = _load_rule_defs ($verbose, $trace_flags, @files);

    if ($verbose) { say STDERR "generating PDA parsing ops"; }
    my $generator = pda_op_generator;
    $generator->generate_for_rule_defs ($rule_defs_ast);

    if ($verbose) { say STDERR "writing PDA parse ops package"; }
    pda_op_pkg_writer (
        rule_defs_ast       => $rule_defs_ast,
        pda_info_list       => [ $generator->rule_def_pdas_list ],
        op_defs             => $generator->op_defs,
        literal_map         => $generator->literal_map,
        regex_map           => $generator->regex_map,
        token_map           => $generator->token_map,
    )->write_op_package (\*STDOUT);

    if ($verbose) { say STDERR "done" }
    exit 0;
}

#===============================================================================
sub _PerlClassMaker() { 'WW::ParserGen::PDA::PerlClassMaker' }

sub generate_ast_classes($$$$$@) {
    my ($verbose, $trace_flags, $pretend, $base_ast_class, $dest_dir, @files) = @_;
    my $rule_defs_ast = _load_rule_defs ($verbose, $trace_flags, @files);

    eval ('require ' . _PerlClassMaker);
    if (my $msg = $@) { say STDERR $msg; exit 3; }

    my $class_maker = _PerlClassMaker->new (rule_defs_ast => $rule_defs_ast);
    $class_maker->write_new_ast_classes ($verbose, $pretend, $base_ast_class, $dest_dir);
    exit 0;
}

=pod

=head1 NAME

parser-gen-pda.pl - Generate parser op package for WW::Parse::PDA::Engine

=head1 SYNOPSIS

    parser-gen-pda.pl --verbose --generate-op-pkg a-grammar.ebnf > AParser/Pkgops.pm

=head1 DESCRIPTION

This program generates Perl packages that define a parser. The generated package is
used with the L<WW::Parse::PDA::Engine>. See L<WW::ParserGen::PDA::Manual::Intro>
for information about the grammar specification.

This program can also generate stub Perl packages for AST nodes returned by match
rules. Any rule that defines a node package is a candidate for generation. Existing
Perl source files are never overwritten in this mode.

=head1 COMMAND ARGUMENTS / OPTIONS

    parser-gen-pda.pl [-htVv] [long options...] <ebnf-file-path> ...

	-v --verbose              display progress/information messages on STDERR
	-t --trace                trace file parsing
	--generate-op-pkg         generate parse ops package for use with WW::Parse::PDA::Engine
	--generate-ast-classes    generate classes for the node packges defined in the rule defs
	--dest-dir                output destination directory for ast classes
	--base-ast-class          base class to use when generating ast classes

	-h --help                 display option summary
	-V --version              display program version
	--pretend                 do not actually write ast class files
	                        
	One of --generate-op-pkg or --generate-ast-classes is required in command mode

=head1 SEE ALSO

L<WW::ParserGen::PDA::Manual::Intro>, L<WW::Parse::PDA::ParserBase>.

=head1 BUGS

When processing more than one source file, line numbers in error messages
are for the concatenated source version, not the line in the file where
the error occurred.

=head1 COPYRIGHT

Copyright (c) 2013 by Lee Woodworth. All rights reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

