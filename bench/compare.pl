#!/usr/bin/env perl

use strict;
use warnings;
use Benchmark qw(:all);
use DB::Berkeley;
# use BerkeleyDB;	# I can't get BerkeleyDB to install
use DB_File;
use Fcntl;

# Setup test keys/values
my $count = 10_000;
my @keys = map { "key$_" } 1..$count;
my @values = map { "value$_" } 1..$count;

my $db_bfile = 'compare_db_bfile.db';
my $db_bdb	= 'compare_db_bdb.db';
my $db_dbb	= 'compare_db_dbb.db';

END {
	unlink $db_bfile if -e $db_bfile;
	unlink $db_bdb   if -e $db_bdb;
	unlink $db_dbb   if -e $db_dbb;
}

# Prepare DB::Berkeley
my $berk = DB::Berkeley->new($db_dbb, 0, 0600);

# Prepare BerkeleyDB (tied)
# tie my %bdb, 'BerkeleyDB::Hash',
	# -Filename => $db_bdb,
	# -Flags	=> DB_CREATE
	# or die "Cannot open BDB: $BerkeleyDB::Error";

# Prepare DB_File
tie my %bfile, 'DB_File', $db_bfile, O_RDWR|O_CREAT, 0666
	or die "Cannot open DB_File: $!";

# Benchmark insert
print "Benchmarking put/store for $count records\n";
cmpthese(-1, {
	'DB::Berkeley' => sub {
		$berk->put($keys[$_], $values[$_]) for 0..$#keys;
	},
	# 'BerkeleyDB' => sub {
		# $bdb{$keys[$_]} = $values[$_]} for 0..$#keys;
	# },
	'DB_File' => sub {
		$bfile{$keys[$_]} = $values[$_] for 0..$#keys;
	},
});

# Benchmark fetch
print "\nBenchmarking get/fetch\n";
cmpthese(-1, {
	'DB::Berkeley' => sub {
		$berk->get($keys[$_]) for 0..$#keys;
	},
	# 'BerkeleyDB' => sub {
		# my $foo = $bdb{$keys[$_]} for 0..$#keys;
	# },
	'DB_File' => sub {
		my $foo = $bfile{$keys[$_]} for 0..$#keys;
	},
});

# Benchmark exists
print "\nBenchmarking exists\n";
cmpthese(-1, {
	'DB::Berkeley' => sub {
		$berk->exists($keys[$_]) for 0..$#keys;
	},
	# 'BerkeleyDB' => sub {
		# exists $bdb{$keys[$_]} for 0..$#keys;
	# },
	'DB_File' => sub {
		exists $bfile{$keys[$_]} for 0..$#keys;
	},
});
