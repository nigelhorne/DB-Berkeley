use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'DB::Berkeley',
    VERSION_FROM => 'lib/DB/Berkeley.pm',
    LIBS         => ['-ldb'],      # Link against libdb
    INC          => '',            # No special include paths
    XS           => { 'lib/DB/Berkeley.xs' => 'lib/DB/Berkeley.c' },
    LICENSE      => 'perl',
);
