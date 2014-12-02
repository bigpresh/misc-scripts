package Bot::BasicBot::Pluggable::Module::RateLimitUsers;
use strict;
use base 'Bot::BasicBot::Pluggable::Module';


sub help {
    return <<HELPMSG
Stops a user from spamming the bot (e.g. repeated karma scoring, etc).

Keeps track of how many times each nick has addressed the bot, and
begins to ignore them if they've done it too often in a configurable
period.

Configure with max_messages (how many times a user can address the bot)
and rate_limit_window - (the number of seconds to look back).  For example,
max_messages = 5 and rate_limit_window = 60 would start ignoring a user after
they address the bot 5 times in a minute.
HELPMSG
}

my %messages_from_nick;
sub said {
    my ($self, $mess, $pri) = @_;

    # If the user wasn't talking to us, no further checks:
    return unless $mess->{address};

    my $max_messages = $self->get('max_messages') || 5;
    my $rate_limit_window = $self->get('rate_limit_window') || 60;

    # Want to get first interception of everything
    return unless $pri == 0;

    # First, remove any expired timestamps:
    $messages_from_nick{$mess->{who}} = [
        grep {
            $_ > time - $rate_limit_window
        } @{ $messages_from_nick{$mess->{who}} || [] }
    ];
    
    # Record this one... 
    push @{ $messages_from_nick{$mess->{who}} }, scalar time;

    # and now, if they're being too chatty - if they've just hit the limit, tell
    # them and ignore them, if they've over the limit already just ignore.
    my $messages_in_window = scalar @{ $messages_from_nick{$mess->{who}} };
    if ($messages_in_window == $max_messages) {
        warn sprintf "Beginning to ignore %s - %d messages in %d seconds",
            $mess->{who},
            $messages_in_window,
            $rate_limit_window;
        return "Slow down please $mess->{who} - ignoring you for a while";
    } elsif ($messages_in_window > $max_messages) {
        warn sprintf "Still ignoring %s (%d messages in %d second window"
            . " exceeds limit of %d)",
            $mess->{who},
            $messages_in_window,
            $rate_limit_window,
            $max_messages;
        return 1;
    }
}


1;
