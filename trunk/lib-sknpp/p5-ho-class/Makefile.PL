use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'HO::class',
    AUTHOR              => 'Sebastian Knapp <sk@computer-leipzig.com>',
    VERSION_FROM        => 'lib/HO/class.pm',
    ABSTRACT_FROM       => 'lib/HO/class.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'HO-class-*' },
);
