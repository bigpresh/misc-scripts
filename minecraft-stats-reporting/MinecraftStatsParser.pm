package MinecraftStatsParser;

use strict;
use 5.010;
use LWP::UserAgent;
use HTML::TableExtract;

# Mapping of interesting block IDs to names
my %block_name_by_id = (
    56 => 'diamond',
    14 => 'gold',
    15 => 'iron',
    4  => 'cobble',
    1  => 'stone',
    27 => 'powered_rail',
);


my $ua = LWP::UserAgent->new;

sub get_stats {
    my $player = shift;
    my %player_stats;

    my $response = $ua->get(
        sprintf "http://the-wild.tk/stats/single_player.php?p=%s",
        $player
    );
    
    my $te = HTML::TableExtract->new(
        headers => [ qw(Block BlockID Placed Broken) ],
    );
    $te->parse($response->content);
    my ($table) = $te->tables
        or die "Failed to find blocks table in stats HTML";

    for my $row ($table->rows) {
        my ($block, $block_id, $placed, $broken) = @$row;

        if (my $block_name = $block_name_by_id{$block_id}) {
            $player_stats{broken}{$block_name} += $broken;
            $player_stats{placed}{$block_name} += $placed if $placed;
        }
    }

    for (qw(diamond gold)) {
        if ($player_stats{broken}{$_}) {
        $player_stats{ratio}{$_} = sprintf '%.4f', 
            $player_stats{broken}{$_} / $player_stats{broken}{stone};
        }
    }
    return \%player_stats;
}

sub get_players {
    my ($player_count) = shift || 50;
    my $response = $ua->get(
        "http://the-wild.tk/stats/ajax_player_table.php?"
        . "iDisplayStart=0&iDisplayLength=$player_count"
        . "&iColumns=7"
        . "&iSortCol_0=1&iSortingCols=1&sSortDir_0=desc"
    );
    my @players;
    @players = ($response->content =~ /p=(.+?)\\?"/xmg);
    return \@players;
}


