#!/usr/bin/env perl
#
# A simple script to stop me accidentally saying e.g. "win 22" in channels, when
# I meant to use the command /win 22.
# Stops it being sent, and just switches window for you.

use strict;
use vars qw($VERSION %IRSSI);

use Irssi;
$VERSION = '1.00';
%IRSSI = (
    authors     => 'David Precious',
    contact     => 'davidp@preshweb.co.uk',
    name        => '/win commands typo fixer',
    description => 'Catch typoed /win commands (e.g. "win 6") ',
    license     => 'Public Domain',
);


sub sig_send_text {
    my ($line, $server, $witem) = @_;

    return if $witem->{type} !~ /^(CHANNEL|QUERY)$/;

    if (my($win_num) = $line =~ /^win (\d+)/) {
        $server->window_item_find($witem->{name})->command("win $win_num");
        Irssi::signal_stop();
    }
}

Irssi::signal_add('send text', 'sig_send_text');
