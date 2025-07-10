use strict;
use warnings;

use DB::Berkeley qw(DB_RDONLY);
use File::Temp qw(tempfile);
use Test::Most;

# Create a valid DB file first in read-write mode
my ($fh, $file) = tempfile(SUFFIX => '.db');
close $fh;
unlink $file if -e $file;

# Step 1: Create and write to the database
{
	my $db = DB::Berkeley->new($file, 0, 0600);

	ok($db->put('foo', 'bar'), 'Initial put() succeeded');
	is($db->get('foo'), 'bar', 'Initial get() returned correct value');
	$db->sync();

	undef $db; # Close and flush
}

# Step 2: Reopen in read-only mode using exported DB_RDONLY
my $db_ro = DB::Berkeley->new($file, DB_RDONLY, 0600);
ok($db_ro, 'Opened DB in read-only mode');
is($db_ro->get('foo'), 'bar', 'get() works in read-only mode');

# Step 3: Verify that put fails
throws_ok {
	$db_ro->put('baz', 'qux');
} qr/permission|read-only|Read-only|Invalid|EINVAL/i, 'put() in read-only mode croaks with permission error';

done_testing();

END {
    unlink $file if -e $file;
}
