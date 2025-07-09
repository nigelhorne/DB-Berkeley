package DB::Berkeley;

use strict;
use warnings;
require XSLoader;

=head1 NAME

DB::Berkeley - XS-based OO Berkeley DB HASH interface

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';

=head1 SYNOPSIS

    use DB::Berkeley;

    my $db = DB::Berkeley->new(Filename => 'my.db');

    $db->put('foo', 'bar');
    my $val = $db->get('foo');
    $db->delete('foo');

=head1 DESCRIPTION

A lightweight XS wrapper around Berkeley DB using HASH format, without using tie().
DB_File works, I just prefer this API.

=cut

XSLoader::load('DB::Berkeley', $VERSION);

sub new {
	my ($class, %opts) = @_;
	my $filename = $opts{Filename} or die 'Filename required';
	my $flags    = $opts{Flags}    || 0x200000;	# DB_CREATE
	my $mode     = $opts{Mode}     || 0644;

	my $self = _open($filename, $flags, $mode);
	bless $self, $class;
}

=head1 AUTHOR

Nigel Horne, C<< <njh at nigelhorne.com> >>

=head1 SEE ALSO

=over 4

=item * L<DB_File>

=back

=head1 REPOSITORY

L<https://github.com/nigelhorne/DB-Berkeley>

=head1 SUPPORT

This module is provided as-is without any warranty.

Please report any bugs or feature requests to C<bug-db-berkeley at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=DB-Berkeley>.
I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

You can find documentation for this module with the perldoc command.

    perldoc DB::Berkeley

You can also look for information at:

=over 4

=item * MetaCPAN

L<https://metacpan.org/dist/DB-Berkeley>

=item * RT: CPAN's request tracker

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=DB-Berkeley>

=item * CPAN Testers' Matrix

L<http://matrix.cpantesters.org/?dist=DB-Berkeley>

=item * CPAN Testers Dependencies

L<http://deps.cpantesters.org/?module=DB::Berkeley>

=back

=head1 LICENCE AND COPYRIGHT

Copyright 2010-2025 Nigel Horne.

Usage is subject to licence terms.

The licence terms of this software are as follows:

=over 4

=item * Personal single user, single computer use: GPL2

=item * All other users (including Commercial, Charity, Educational, Government)
  must apply in writing for a licence for use from Nigel Horne at the
  above e-mail.

=back

=cut

1;

