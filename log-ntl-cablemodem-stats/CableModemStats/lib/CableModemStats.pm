package CableModemStats;
use Dancer ':syntax';
use Dancer::Plugin::Database;

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
    redirect '/graph/' . params->{statname} . '/hour/1';
};

get '/graph/:statname/:unit/:unitcount' => sub {
    my $periodunit = params->{unit};
    my $periodunitcount = params->{unitcount};
    $periodunit =~ s/s$//;
    if ($periodunit !~ /^ (hour|day|week|month|year) $/x) {
        return send_error "Invalid unit $periodunit";
    }
    if ($periodunitcount !~ /^ \d+ $/x) {
        return send_error "Invalid unitcount $periodunitcount";
    };

    my $query = <<QUERY;
SELECT 
    UNIX_TIMESTAMP(`timestamp`) AS time_t, 
    `value` 
FROM `stats` 
WHERE 
    `key` = ?
AND timestamp >= DATE_SUB(now(), interval $periodunitcount $periodunit)
QUERY
    my $sth = database->prepare($query);
    $sth->execute(
        params->{statname}, 
    );
    my @dataset;
    my $unit;
    while (my $row = $sth->fetchrow_hashref) {
        ($unit) = $row->{value} =~ /\d+\s+(.+)$/ unless $unit;
        my $value = $row->{value};
        $value =~ s/\s+.+$//g;
        push @dataset, { time => $row->{time_t}, value => $value };
    }
    
    my $title = params->{statname};
    $title .= " ($unit)" if $unit;
    my $period = "$periodunitcount $periodunit";
    $period .= 's' if $periodunitcount > 1;
    $title .= "($period)";
    my $chart = Chart::Strip->new(
        title  => $title, 
        width  => 800, 
        height => 300,
    );
    $chart->add_data(\@dataset, { style => 'line' });


    content_type 'image/png';
    return $chart->png;
    
};

dance;
