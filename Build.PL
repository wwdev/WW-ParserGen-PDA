use 5.012;
use strict;
use warnings FATAL => 'all';
use Module::Build;

my $builder = Module::Build->new (
    dist_name           => 'WW-ParserGen-PDA',
    module_name         => 'WW::ParserGen::PDA',
    dist_author         => q{Lee Woodworth <wwdev16@gmail.com>},
    dist_version        => '0.12.2',
    dist_abstract       => 'Parser generator for WW::Parse::PDA::Engine',
    license             => 'Artistic_2_0',
    create_license      => 'Artistic_2_0',
    meta_merge          => {
        keywords        => [qw( parser pda )],
    },
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More'    => 0,
        'Test::Exception' => 0,
    },
    requires => {
        'Scalar::Util'  => 0,
        'Moose'         => 0,
        'Exporter'      => 0,
        'Getopt::Long::Descriptive' => 0,
        'FindBin'       => 0,
        'Module::Find'  => 0,
        'Cwd'           => 0,
        'File::Copy'    => 0,
        'File::Path'    => 0,
        'File::Spec',   => 0,
        'File::Temp',   => 0,
        'WW::Parse::PDA::Engine' => '0.012000',
    },
    add_to_cleanup      => [ 'WW-ParserGen-PDA-*' ],
    create_makefile_pl  => 'traditional',
);

$builder->add_build_element ('ebnf');
$builder->create_build_script ();

