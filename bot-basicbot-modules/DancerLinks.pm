# A quick Bot::BasicBot::Pluggable module to provide easy links when someone
# mentions Dancer::* modules or keywords on our channel
# David Precious <davidp@preshweb.co.uk>

package Bot::BasicBot::Pluggable::Module::DancerLinks;
use strict;
use base 'Bot::BasicBot::Pluggable::Module';
use JSON;

sub help {
    return <<HELPMSG;
A quick module for use on Dancer IRC channels to provide links to module /
keyword documentation.
HELPMSG
}


sub said {
    my ($self, $mess, $pri) = @_;
    
    return unless $pri == 2;

    if (my ($module) = $mess->{body} =~ /(Dancer::\S+)/) {
        return "http://p3rl.org/$module";
    }

    if (my ($keyword) = $mess->{body} =~ /\b(\S+)(?:\(\))? keyword/) {
        # TODO: this might fire a little often; if it does, we could load Dancer
        # and see if Dancer->can($keyword) or something
        return "http://p3rl.org/Dancer#$keyword";
    }

    return 0; # This message didn't interest us
}


1;

