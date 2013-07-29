package WWTest::ParserGen::CMatch;
use feature qw(:5.12);
use strict;

sub custom1 {
    my ($ctx, $op_index, $op_list) = @_;
    my $args = $op_list->[$op_index+1];
    $ctx->{match_value} = $args ? $args : '*custom1*';
    $ctx->{match_status} = 1;
    return $op_index + 2;
}

use Exporter qw( import );
our @EXPORT_OK = qw( custom1 );
our %EXPORT_TAGS = ( all => \@EXPORT_OK );

1;

