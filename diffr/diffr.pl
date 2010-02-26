#!/usr/bin/perl


# recursive diff tool, with ability to filter files it looks at.

# $Id: diffr.pl 353 2008-05-16 22:05:00Z davidp $

use Getopt::Std;
use File::Find;
use strict;
use warnings;

# mainly for Getopt::Std to produce --help / --version output:
our $VERSION = '0.0.1';

my $usage = qq[
usage: diffr -s source -d dest [-p pattern]

if -p is given, we will only do the diff for filenames which match
this pattern - this matches the full path, so a pattern of 'foo' will
match 'foo.txt', '/home/foo/bar' etc. 
];


my %opts;
getopt('sdph', \%opts);

if (!$opts{'s'} || !$opts{'d'} || $opts{'h'}) {
    print $usage; exit;
}

my ($source, $dest) = @opts{qw(s d)};

 
unless (-d $opts{'s'} && -d $opts{'d'}) {
    print "source and dest directories must be given!\n"; exit;
}
 
# if we're given a pattern, we'll pre-compile the regexp for speed (we might
# be using it many,many times)
# TODO: we should probably catch any errors in case the pattern supplied isn't
# valid
my $regexp;
if ($opts{p}) {
    $regexp = qr/$opts{p}/xms;
}

# Loop one: we need to loop through the source dir, and diff any files which
# match the pattern, or report if they don't exist in the target dir.
process_dir($opts{'s'});


# Loop two: no diffs this time, but loop through the target dir and report any
# files which don't exist in the source dir.
 
# FIXME:
# actually, a better approach to looping through the source dir, then looping
# through the dest dir, might be to read both first and, for each file found,
# add the path to a hash (eg $paths{$thisfile}++), then do the work by walking
# through the keys of that hash, and:
#  - if it exists in both source + dest, do the diff
#  - if it exists in one but not the other, print the appropriate message


# search a directory, and call do_diff for all files (or, all files which
# match pattern if we've been given one), and for all dirs, calls itself
# recursively.
sub process_dir {

    my $dir = shift;
    
    $dir .= '/' unless $dir =~ /\/$/;
    
    opendir(DIR, $dir) || die "Failed to open dir $dir:$!\n";
    
    my @entries = readdir(DIR);
    close DIR;
    
    for my $entry (@entries) {
    
        next if ($entry =~ /^ \. \.? $/xms);
    
        my $fullentry = $dir . $entry;
        
        if (-d $fullentry) {
            # got a dir... process it
            process_dir($fullentry);
        } elsif (-f $fullentry) {
            # got a file:
            if (!$regexp || $fullentry =~ /$regexp/) {
                
                # now we need to know if this exists in the target dir:
                my ($rel) = ($fullentry =~ /$opts{'s'}(.+)$/);
                # $rel should now be something we can stick on the end of
                # the dest dir to get a full path:
                if (!-e $opts{'d'} . $rel) {
                    print "$rel exists in source but not destination\n";
                } else {
                    # it exists in both, diff it
                    do_diff($rel);
                }
                
            }
        }
    
    } # end of for my $entry loop (nobody's looping through my entry!)
            

} # end of sub process_dir




# perform the diff
sub do_diff {

    my $file = shift;
    
    my $diff = `diff -u '$opts{'s'}$file' '$opts{'d'}$file'`;
    
    if ($diff) {
        if ($opts{l}) {
            # -l option means only print list of files which differ
            print "$file\n";
        } else {
            print "$diff\n";
        }
    }
     
}


