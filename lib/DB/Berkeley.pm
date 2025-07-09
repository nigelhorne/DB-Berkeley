package DB::Berkeley;

use strict;
use warnings;
require XSLoader;

our $VERSION = '0.01';
XSLoader::load('DB::Berkeley', $VERSION);

sub new {
    my ($class, %opts) = @_;
    my $filename = $opts{Filename} or die "Filename required";
    my $flags    = $opts{Flags}    || 0x200000; # DB_CREATE
    my $mode     = $opts{Mode}     || 0644;

    my $self = _open($filename, $flags, $mode);
    bless $self, $class;
}

1;

__END__

=head1 NAME

DB::Berkeley - XS-based OO Berkeley DB HASH interface

=head1 SYNOPSIS

    use DB::Berkeley;

    my $db = DB::Berkeley->new(Filename => 'my.db');

    $db->put("foo", "bar");
    my $val = $db->get("foo");
    $db->delete("foo");

=head1 DESCRIPTION

A lightweight XS wrapper around Berkeley DB using HASH format, without using tie().

=cut
