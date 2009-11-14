use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'HO::class',
    license             => 'perl',
    dist_author         => 'Sebastian Knapp <sk@computer-leipzig.com>',
    dist_version        => '0.05',
    requires => {
        'perl'          => '5.6.0',
        'Package::Subroutine' => '0.06'
    },
    build_requires => {
        'Test::More' => 0,
    },
    add_to_cleanup      => [ 'HO-class-*' ],
    create_makefile_pl  => 'traditional',
    meta_add => { 
        resources => { 
            repository => 'git://github.com/giftnuss/p5-ho-class.git',
            homepage => 'http://github.com/giftnuss/p5-ho-class/tree/master'
        }
    }
);

$builder->create_build_script();
