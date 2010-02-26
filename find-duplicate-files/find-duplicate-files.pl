#!/usr/bin/perl -w


# Loop through a directory and find duplicate
# files, based on the MD5 sum (therefore finding
# files with identical content even if their timestamp
# and attributes are different)
# 
# David Precious, 26/07/2006

# TODO : some code to offer to resolve dupes (i.e. pick
# the filename you want to keep, I'll delete the others)

use Cwd;
use Digest::MD5::File qw(file_md5_hex);
use strict;
use Data::Dumper;

my $start_dir = '';

if ($ARGV[0]) {
    print "dir:$ARGV[0]\n";
    $start_dir = $ARGV[0];
    chdir($start_dir) || die "Can't chdir() to $start_dir\n";
} else {
    $start_dir = getcwd;
}

my %hashes;

opendir(DIR, $start_dir);
my @files = readdir(DIR);
closedir(DIR);

FILE:
foreach my $file (@files) {

	next FILE if ($file =~ /^\.\.?$/);	
	next FILE unless (-f $file);
	
	unless (-r $file) {
	    print STDERR "Can't read $file\n";
	    next FILE;
	}
	my $hash = file_md5_hex($file);
	
	push @{$hashes{$hash}}, $file;
			
}
		


foreach my $hash (keys %hashes) {

    if (scalar @{$hashes{$hash}} > 1) {
	print "Dupes: " . join(' ', @{$hashes{$hash}}) . "\n";
    }
}

