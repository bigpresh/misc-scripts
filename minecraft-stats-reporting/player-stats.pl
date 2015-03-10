#!/usr/bin/env perl

use strict;
use 5.010;
use CGI;  # yeah, I know!
use JSON;

use lib '.';
use MinecraftStatsParser;

use Data::Dump;
print "Content-Type: application/json\n\n";

my $cgi = CGI->new;
if (my $player_name = $cgi->param('player')) {
    say JSON::to_json(
        MinecraftStatsParser::get_stats($player_name)
    );
} else {
    say JSON::to_json(
        { error => "Player name not supplied" }
    );
}


