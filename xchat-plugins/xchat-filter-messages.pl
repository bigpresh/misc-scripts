#!/usr/bin/perl -w

# Simple XChat script to filter out unwanted
# messages matching one of the expressions
# given.
#
# David Precious, davidp@preshweb.co.uk
# bigpresh on Freenode and EFNet
# Originally written 20th March 2006

# $Id: xchat-filter-messages.pl 833 2010-02-18 18:30:01Z davidp $

use strict;

my $script = 'xchat-filter-messages.pl';
my $ver    = '0.0.2';

# Cache channel user lists so we don't keep asking XChat for them all the time;
# I believe there's a memory leak when you call user_list_short too many times.
my %user_list_cache;

# Filter rules are read from a file named filterrules in your XChat config
# directory.  Rules are just regexes, one per line.
my $confdir      = IRC::get_info(4);
my $rules_file   = $confdir . '/filterrules';
my @rules        = ();  # will be populated by read_rules

&read_rules;    # read in the rules file

IRC::register( $script, $ver, "", "" );
IRC::add_message_handler( 'PRIVMSG', 'parse_line' );
IRC::add_message_handler( 'NOTICE',  'parse_line' );
IRC::add_command_handler( 'filterrules', 'read_rules' );
my $svnid = '$Id: xchat-filter-messages.pl 833 2010-02-18 18:30:01Z davidp $';
IRC::print("*** \0038,2$script v$ver ($svnid) loaded \003");

sub read_rules {
    # read (or re-read) the rules file.
    @rules = ();
    open(my $rulesfh, '<', $rules_file)
        or IRC::print("** Failed to read rules file $rules_file - $!") and return;
    while (my $rule = <$rulesfh>) {
        chomp $rule;
        next unless $rule =~ /^[^#]/;
        push @rules, $rule;
    }
    close $rulesfh;
    IRC::print( "$script loaded " . scalar @rules . " rules from $rules_file" );
    return 1;
}


# test each filter rule against this line.
# returns 1 if line should be dropped or 0 if it didn't match.
sub check_filter {
    my $line = shift;

    for my $rule (@rules) {
        return 1 if ( $line =~ /$rule/ );
    }
    return 0;

}


# Called when a PRIVMSG/NOTICE is received; check whether to filter it out or
# not. Returning true indicates the message should be swallowed.
sub parse_line {
    my $line = shift;

    # replace the funky colour stuff:
    $line =~ s/\cc[0-9]{2}//g;


    if (check_filter($line)) {
        # Matches a filter rule, drop it immediately:
        return 1;
    }

    
    # OK, now see if it's a mass nick-alert muppet:    
    if (my($nick, $user, $host, $msgtype, $to, $msgtxt)
        = $line =~ /:(\S+)!(\S+)@(\S+) \s ([A-Z]+) \s (\S+) \s:(.+)/x ) 
    {
        # If it wasn't to a channel, nothing to do here:
        return unless $to =~ /^#/;

        # OK, get a list of people in this channel:
        my $chan_users = chan_users_list($to);

        # Now, for each word of the message, see if it's a nick.  If we see many
        # nicks, we'll filter it.
        my $nicks_mentioned;
        for my $word (split /\s+/, $msgtxt) {
            $nicks_mentioned++ if $chan_users->{$word};
        }
        if ($nicks_mentioned > 5) {
            IRC::print("*** Blocking nick-spamming from $nick in $to"
                . " ($nicks_mentioned nicks in message)");
            
            return 1;
        }

        return;
    }

}    # end of sub parse_line


# Return a list of users for a channel, caching the info, and returning it from
# the cache if it's not too stale.  For our purposes, it doesn't really matter
# if the list of users isn't completely up to date.
# Returns a hashref of nick => 1, for easy checking.
sub chan_users_list {
    my $chan = shift;

    if (my $cached = $user_list_cache{$chan}) {
        if (time - $cached->{timestamp} < 300) {
            return $cached->{userlist};
        }
    }

    # OK, fetch the list, cache it, and return it:
    my @chan_users_list = IRC::user_list_short($chan);
    my %chan_users;
    while (my($nick,$host) = splice @chan_users_list, 0, 2) {
        $chan_users{$nick}++;
    }
    $user_list_cache{$chan} = {
        timestamp => time,
        userlist  => \%chan_users,
    };
    return \%chan_users;
}

