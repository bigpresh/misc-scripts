package Bot::BasicBot::Pluggable::Module::SayFromQueue;
use strict;
use Bot::BasicBot::Pluggable::Module;
use base 'Bot::BasicBot::Pluggable::Module';
use File::Find::Rule;
use File::Slurp;

sub help {
    return <<HELPMSG
Simple module to allow local processes to ask the bot to say something on IRC.

Dirt-simple; could be improved to allow configurable directory to watch.
HELPMSG
}


sub tick {
    my $self = shift;

    # Look in the queue dir for any files, and deal with them.
    my $qdir = $ENV{HOME} . '/.botmsgqueues/' . $self->bot->username;
    my @files = File::Find::Rule->file()->in($qdir);
    for my $file (@files) {
        warn "Found file $file";
        my @messages = File::Slurp::read_file($file);
        for my $message (@messages) {
            my ($chan,$body) = split /:/, $message, 2;
            for ($body) { s/^\s+//; s/\s+$//; }
            $self->say({ channel => $chan, body => $body });
        }
        unlink $file;
    }
    return 5;
}





1;
       
