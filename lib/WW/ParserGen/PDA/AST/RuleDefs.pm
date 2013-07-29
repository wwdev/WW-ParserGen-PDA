package WW::ParserGen::PDA::AST::RuleDefs;
use feature qw(:5.12);
use strict;

use Moose;
extends 'WW::ParserGen::PDA::ASTBase';

has parser_pkg => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
);

has node_pkg_prefix => (
    is          => 'ro',
#    isa         => 'Str',
);

has [qw( pkg_use_list custom_match_list )]  => (
    is          => 'ro',
#    isa         => 'ArrayRef',
    default     => sub { [] },
);

has [qw( rule_defs token_defs infix_op_tables )] => (
    is          => 'ro',
#    isa         => 'HashRef',
    default     => sub { {} },
);

sub BUILD {
    my ($self, $args) = @_;
    if (my $custom_matches = $self->custom_match_list) {
        $self->{custom_match_list} = undef
            unless @$custom_matches;
    }

    if (ref ($self->rule_defs) eq 'ARRAY') {
        $self->_make_rule_defs_map;
    }
    elsif (ref ($self->rule_defs) ne 'HASH') {
        die "rule_defs must be a hash ref";
    }
    die ("no rule defs") unless scalar (keys %{$self->rule_defs});

    if (ref (my $def_list = $self->{token_defs}) eq 'ARRAY') {
        my %token_defs;
        for (@$def_list) {
            if ($_->node_type eq 'custom_match_def') {
                push @{$self->{custom_match_list} ||= []}, $_;
                next;
            }
            die "$_->token_name already defined" if $token_defs{$_->token_name};
            $token_defs{$_->token_name} = $_;
        }
        $self->{token_defs} = \%token_defs;
    }
    elsif (ref ($self->token_defs) ne 'HASH') {
        die "token_defs must be a hash ref";
    }

    $self->_make_operators_map;

    my $pkg_prefix = $self->node_pkg_prefix;
    return unless $pkg_prefix;

    $pkg_prefix .= '::' unless $pkg_prefix =~ m/::$/;
    for (values %{$self->rule_defs}) {
        (my $node_pkg = $_->node_pkg) or next;
        $_->set_node_pkg ($pkg_prefix . $node_pkg);
    }
}

sub _make_rule_defs_map {
    my ($self) = @_;
    my %rules_map;
    for (@{$self->rule_defs}) {
        if (my $rule_def = $rules_map{$_->rule_name}) {
            my $match = $rule_def->match;
            # combine multiple rules into an or list
            if ($match->node_type eq 'first_match') {
                push @{$match->match_list}, $_->match;
            }
            else {
                $rule_def->set_match (
                    WW::ParserGen::PDA::AST::FirstMatch-> new (
                        node_type => 'first_match', match_list => [ $match, $_->match ]
                    )
                );
            }
            next;
        }
        $rules_map{$_->rule_name} = $_;
    }
    $self->{rule_defs} = \%rules_map;
}

sub _make_operators_map {
    my ($self) = @_;
    my $infix_tables_list = $self->infix_op_tables;
    return if !$infix_tables_list || ref ($infix_tables_list) eq 'HASH';

    die "infix_operator_tables is not an array ref: " . ref ($infix_tables_list)
        unless ref ($infix_tables_list) eq 'ARRAY';

    my %op_tables;
    for (@$infix_tables_list) {
        die "operatator table " . $_->name . " already defined"
            if $op_tables{$_->name};
        $op_tables{$_->name} = $_;
    }

    $self->{infix_op_tables} = scalar (keys %op_tables) ?
        \%op_tables : undef;
}

no Moose;
__PACKAGE__->meta->make_immutable;

#use WW::ParserGen::PDA::AST::FirstMatch qw( :all );

#sub rule_defs_ast {
#    my %args = @_;
#    my ($parser_pkg, $node_pkg_prefix, $use_list, $custom_match_list, $rule_defs) = 
#        @args{qw( parser_pkg node_pkg_prefix pkg_use_list custom_match_list rule_defs )};

#    return __PACKAGE__->new (
#        node_type => 'rule_defs',
#        parser_pkg => $parser_pkg,
#        ($node_pkg_prefix ? ( node_pkg_prefix => $node_pkg_prefix ) : ( )),
#        ($use_list && @$use_list ? ( pkg_use_list => $use_list ) : ( )),
#        ($custom_match_list && @$custom_match_list ? ( custom_match_list => $custom_match_list ) : ( )),
#        rule_defs => $rule_defs,
#    );
#}

#use Exporter qw( import );

#our @EXPORT_OK = qw( rule_defs_ast );
#our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

