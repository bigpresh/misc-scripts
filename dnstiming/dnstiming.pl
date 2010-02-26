#!/usr/bin/perl

# $Id: dnstiming.pl 789 2009-12-03 19:06:51Z davidp $

use common::sense;
use HTML::Table;
use Time::HiRes;
use Net::DNS::Resolver;
use List::Util;

my @hostnames = qw(
    www.google.com
    www.facebook.com
    www.bbc.co.uk
    www.myspace.com
    www.yahoo.com
    www.wikipedia.org
    www.debian.org
    www.youtube.com
    www.twitter.com
    www.imdb.com
    www.apple.com
);

my %providers = (
    Google =>  [ '8.8.8.8',        '8.8.4.4'        ],
    OpenDNS => [ '208.67.220.220', '208.67.222.222' ],
    Virgin  => [ '194.168.4.100',  '194.168.8.100'  ],
    Local   => [ '127.0.0.1'                        ],
);

# Build up a hash of arrayrefs of durations, to average at the end
my %times;


# Now, for each provider, we'll try each hostname against each of their
# resolvers several times, to get more accurate figures.
for (1..50) {
    for my $provider (keys %providers) {
        for my $server (@{ $providers{$provider} }) {
            my $dns = Net::DNS::Resolver->new( nameservers => [ $server ] );
            for my $hostname (@hostnames) {
                my $start = [ Time::HiRes::gettimeofday ];
                my $result = $dns->query($hostname);
                push @{ $times{$provider} }, Time::HiRes::tv_interval($start);
            }
        }
    }
}


# Go through each provider and calculate best/worst/avg times:
my @rows;
for my $provider (keys %providers) {
    my @times = @{ $times{$provider} };
    my $best  = sprintf '%.4f', List::Util::min(@times);
    my $worst = sprintf '%.4f', List::Util::max(@times);
    my $avg   = sprintf '%.4f', List::Util::sum(@times) / @times;
    push @rows, [ $provider, $avg, $best, $worst ];
}

my $table = HTML::Table->new;
$table->addRow(qw( Provider Average Best Worst ));
$table->setRowHead(1);

for my $row (sort { $a->[1] <=> $b->[1] } @rows) {
    $table->addRow(@$row);
}
$table->print;


