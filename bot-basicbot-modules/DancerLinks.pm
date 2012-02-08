# A quick Bot::BasicBot::Pluggable module to provide easy links when someone
# mentions Dancer::* modules or keywords on our channel
# David Precious <davidp@preshweb.co.uk>

package Bot::BasicBot::Pluggable::Module::DancerLinks;
use strict;
use base 'Bot::BasicBot::Pluggable::Module';
use URI::Title;

sub help {
    return <<HELPMSG;
A quick module for use on Dancer IRC channels to provide links to module /
keyword documentation.
HELPMSG
}

my %link_said;
sub said {
    my ($self, $mess, $pri) = @_;
    
    return unless $pri == 2;
    my $link;
    if (my ($module) = $mess->{body} =~ /(Dancer::\S+)/) {
        my $url = "http://p3rl.org/$module";
        my $title = URI::Title::title($url);
        if ($title) {
            $title =~ s/^$module - //;
            $title -~ s/- metacpan.+//;
            $link = "$module is at http://p3rl.org/$module ($title)";
        }

    } elsif (my ($keyword) = $mess->{body} =~ /\b([a-z_-]+)(?:\(\))? keyword/) {
        # TODO: this might fire a little often; if it does, we could load Dancer
        # and see if Dancer->can($keyword) or something
        $link = "The $keyword keyword is documented at "
              . "http://p3rl.org/Dancer#$keyword";
    }

    # Announce the link we found, unless we already did that recently
    if ($link && time - $link_said{$link} > 30) {
        $link_said{$link} = time;
        return $link;
    }

    return 0; # This message didn't interest us
}


1;

