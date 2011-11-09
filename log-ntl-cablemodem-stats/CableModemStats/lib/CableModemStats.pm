package CableModemStats;
use Dancer ':syntax';
use Dancer::Plugin::Database;
use Dancer::Plugin::SimpleCRUD;

use Chart::Strip;

our $VERSION = '0.1';

get '/' => sub {
    my $stats = database->selectcol_arrayref(
        'select distinct(`key`) from `stats`'
    ) or die "Failed to fetch available stat types";
    template 'index', {
        stat_types => $stats,
    };
};

get '/view/:statname' => sub {
    template 'stat', { stat => params->{statname} };
};


get '/graph/:statname' => sub {
    # TODO: support customisable periods
    my $query = <<QUERY;
SELECT 
    UNIX_TIMESTAMP(`timestamp`) AS time_t, 
    `value` 
FROM `stats` 
WHERE 
    `key` = ?
AND timestamp >= DATE_SUB(now(), interval 6 hour)
QUERY
    my $sth = database->prepare($query);
    $sth->execute(params->{statname});
    my @dataset;
    my $unit;
    while (my $row = $sth->fetchrow_hashref) {
        ($unit) = $row->{value} =~ /\d+\s+(.+)$/ unless $unit;
        my $value = $row->{value};
        $value =~ s/\s+.+$//g;
        debug "Adding value '$value' and determined unit '$unit'";
        push @dataset, { time => $row->{time_t}, value => $value };
    }
    
    my $title = params->{statname};
    $title .= " ($unit)" if $unit;
    my $chart = Chart::Strip->new( title => $title );
    $chart->add_data(\@dataset, { style => 'line' });


    content_type 'image/png';
    return $chart->png;
    
};

dance;
