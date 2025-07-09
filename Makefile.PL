use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'DB::Berkeley',
    VERSION_FROM => 'lib/DB/Berkeley.pm',
    # LIBS         => ['-ldb'],      # Link against libdb
    # INC          => '',            # No special include paths
    # MACOS
        # LIBS         => ['-L/usr/local/opt/berkeley-db/lib -ldb'], # or /opt/homebrew/opt
    # INC          => '-I/usr/local/opt/berkeley-db/include',
    # MACOS ARM:
    LIBS         => ['-L/opt/homebrew/opt/berkeley-db/lib -ldb'],
    INC          => '-I/opt/homebrew/opt/berkeley-db/include',
    
    LICENSE      => 'GPL',
    TYPEMAPS => ['typemap']
);
