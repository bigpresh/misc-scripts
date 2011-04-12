package Bot::BasicBot::Pluggable::Module::WelcomeMibbit;
use strict;
use base 'Bot::BasicBot::Pluggable::Module';


sub help {
    return <<HELPMSG
Customised welcome to Mibbit users.

Invites them to change their nick and ask for any help they need.
HELPMSG
}

sub chanjoin {
    my ($self, $mess, $pri) = @_;
    
    if ($mess->{who} =~ /^mib_/) {
        $self->say(
            channel => $mess->{channel},
            body => "Welcome $mess->{who}!  Feel free to use /nick yournickhere"
                . " to select a nicer nick.  If you need any help, ask away"
                . " - there's usually someone around to help.");
    }
}

1;
