package WW::ParserGen::PDA::PerlClassMaker;
use feature qw(:5.10);
use strict;

use Cwd qw( realpath );
use File::Temp;
use File::Spec;
use File::Path qw( make_path );
use File::Copy qw( move );

use Moose;

has rule_defs_ast => (
    is          => 'ro',
    isa         => 'WW::ParserGen::ASTBase',
    required    => 1,
);

sub node_pkgs {
    my ($self) = @_;
    my %node_pkgs;
    for (values %{ $self->rule_defs_ast->rule_defs }) {
        my $node_pkg = $_->node_pkg;
        next unless $node_pkg;
        my $pkg_vars = $node_pkgs{$node_pkg} ||= {};

        my $rule_vars = $_->rule_vars;
        next unless $rule_vars;
        for my $var_name (@$rule_vars) {
            $pkg_vars->{$var_name} = scalar (keys %$pkg_vars)
                unless defined $pkg_vars->{$var_name};
        }
    }

    while (my ($k, $v) = each %node_pkgs) {
        # two-steps to avoid aliasing issues
        my @names = sort { $v->{$a} <=> $v->{$b} } keys %$v;
        $node_pkgs{$k} = \@names;
    }
    return \%node_pkgs;
}

no Moose;
__PACKAGE__->meta->make_immutable;

sub write_new_ast_classes {
    my ($self, $verbose, $pretend, $base_ast_class, $dest_root_dir) = @_;
    $verbose ||= 0;
    my $dest_root = realpath ($dest_root_dir);
    die "$dest_root_dir does not exist or is not a directory"
        unless $dest_root && -d $dest_root;

    my $temp_dir = File::Temp->newdir ('/tmp/parsergenXXXXXX');
    my $node_pkgs = $self->node_pkgs;
    for (sort keys %$node_pkgs) {
        say STDERR $_, ' { ', join (' ', @{ $node_pkgs->{$_} }), ' }' if $verbose > 2;
        my $pkg_path = "$dest_root/$_.pm";
        $pkg_path =~ s/::/\//g;
        if (-f $pkg_path) {
            say STDERR "exists   $pkg_path" if $verbose > 1;
            next;
        }
        say STDERR "creating $pkg_path" if $verbose;
        my $base_pkg = "$_";
        $base_pkg =~ s/^.*:://;
        my $tmp_file = File::Temp->new (
            TEMPLATE    => $base_pkg . 'XXXX',
            DIR         => $temp_dir,
            SUFFIX      => '.pm',
        );
        $self->_create_class ($tmp_file, $_, $base_ast_class, $node_pkgs->{$_});
        my $temp_path = "$tmp_file";
        close $tmp_file;
        $self->_move_file ($temp_path, $pkg_path, $verbose, $pretend);
    }
}

sub _create_class {
    my ($self, $ofh, $node_pkg, $base_ast_class, $var_names) = @_;
    $base_ast_class = $base_ast_class ? "\nextends '$base_ast_class';" : '';
    say $ofh <<TEXT;
package $node_pkg;
use feature qw(:5.12);
use strict;

use Moose;$base_ast_class
TEXT

    for (@$var_names) {
        say $ofh <<TEXT;
has $_ => (
    is              => 'ro',
);
TEXT
    }

say $ofh <<TEXT;
no Moose;
__PACKAGE__->meta->make_immutable;

1;
TEXT
}

sub _FileSpec() { 'File::Spec' }

sub _move_file {
    my ($self, $src_path, $dest_path, $verbose, $pretend) = @_;

    my ($dev, $dir, undef) = _FileSpec->splitpath ($dest_path);
    if ($pretend) {
        say STDERR 'would create directory ', $dir, "\n",
                   'would create ', $dest_path;
        return;
    }

    my @dirs = make_path (_FileSpec->catfile ($dev, $dir, ''));
    say STDERR "created directory ", $dirs[0]
        if @dirs && $verbose;

    unless (move ($src_path, $dest_path)) {
        my $sys_error = "$!";
        die "error creating $dest_path" .
            ($sys_error ? ":\n  $sys_error\n" : "\n");
    }
}

1;

