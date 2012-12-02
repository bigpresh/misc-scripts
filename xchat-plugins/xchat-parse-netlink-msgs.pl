#!/usr/bin/perl -w


# Simple XChat script to filter out unwanted
# messages matching one of the expressions
# given.
#
# David Precious, davidp@preshweb.co.uk
# bigpresh on EFNet, DALnet and undernet
# 20th March 2006
#
# updated 23/03/2006 to handle messages containing
# colons which were breaking the regexp parsing.

my $script = 'xchat-parse-netlink-msgs.pl';
my $ver = '0.0.2';

# rules file - each line is a regexp to match
# against incoming messages - if it matches, it'll
# be dropped.

IRC::register ($script, $ver, "", "");
IRC::add_message_handler('PRIVMSG', 'parse_line');
IRC::add_message_handler('NOTICE', 'parse_line');
IRC::print("*** \0038,2$script v$ver loaded \003");



sub parse_line {
# received a PRIVMSG or a NOTICE, so 
# try matching it:
#Line::bigpresh!~bigpresh@supernova.preshweb.co.uk PRIVMSG #irish-buzzerz :test

my ( $sender, $type, $channel, $message ) = split( ' ', $_[0], 4 );
my ( $nick, $user ) = parse_sender( $sender );

# clean up the message
$message =~ s/^://;
$message =~ s/\cc[0-9]{2}//g;
#if ($line =~ /^:(.+)!(.+)@(.+)\s([A-Z]+)\s(.+)\s?:(.+)$/g)
	
if ($message =~ /\((.+)@([A-Z]{2})\)\s(.+)/)
	{
	my ($relaynick, $relaynet, $relaymsg) = ($1,$2,$3);
	# a message being relayed from the "other side"
	Xchat::emit_print('Channel Message', ("$relaynick\[$relaynet\]", $relaymsg, undef));

	return 1;
	}

} # end of sub parse_line

#>> :badgerbot!bigpresh@drink.b.udweiser.com PRIVMSG #irish-buzzerz :(bigpresh@DA) msg txt

sub parse_sender {
# split sender into nick / user@host
my $sender = shift;
$sender =~ m/^:(.*?)!(.*)$/;
}