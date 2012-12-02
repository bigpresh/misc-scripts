#!/usr/bin/perl -w


# Simple XChat script to parse trivia hints and
# display the number of letters in each word.
#
# Looks for lines in the format:
# Hint: @@@ @@@@ @@
# and writes back lines in the format:
# (Hint letters: 3, 4, 2)
#
# David Precious, davidp@preshweb.co.uk
# 20th December 2005  (Happy Christmas!!!)
#
# updated some time after then to add ability to remember
# previously seen answers + display them next time
#
# Updated 18th Feb 2006 to remember current Q for each
# channel seperately to avoid q's + a's in different
# channels getting mixed up


$script = 'xchat-parse-trivia-hints.pl';
$ver = '0.0.4';
$qdb = '/home/davidp/trivia-questions-db';

open(PTL, ">>/tmp/parse_trivia_log");


IRC::register ($script, $ver, "", "");
IRC::add_message_handler("PRIVMSG", "parse_line");
IRC::add_message_handler("NOTICE", "parse_line");
IRC::print("*** \0038,2$script v$ver loaded \003");

%qstate = ();



sub parse_line {
#Line::misspresh!~michelle@80.68.82.38 PRIVMSG #sharosmadhouse :rabbit

my $line = shift;


# replace the funky colour stuff:
$line =~ s/\cc[0-9]{2}//g;

print PTL "Line:$line\n";

if ($line =~ /:(.+)!(.+)@(.+)\s([A-Z]+)\s(.+)\s?:(.+)/)
	{
	($nick, $user, $host, $msgtype, $to, $msgtxt) = ($1, $2, $3, $4, $5, $6);
	print PTL "Nick:$nick User:$user Host:$host Type:$msgtype To:$to Msg:$msgtxt\n";
	}

if ($line =~ /Hint: (.+)/)
	{
	my @letters;

	#foreach $bit (split '/ /', $1)
	my @words = split / /, $1;
	foreach $bit (@words)
		{
		#$out .= length($bit) . ' ';
		push @letters, length($bit);
		}

	IRC::print( "Hint is: $1 (Letters: " . &output_list(@letters) . ')' );
	return 1;

	}

if ($msgtxt =~ /Question ([0-9]+)\/[0-9]+/)
	{
	$qstate{$nick}{'q'} = $1;
	$qstate{$nick}{'a'} = '';

	# see if we've seen it before:
	if ((($ans, $line, $qbot) = &find_answer($nick, $qstate{$nick}{'q'}))
		&& $ans)
		{
		$ans = lc($ans); # make it nicer to copy + paste <g>
		IRC::print("\0031,11ANSWER: $ans\003 (line:$line, bot:$qbot)\n");
		}
	
	}

if ($msgtxt =~ /The answer was ([^.]+)\./)
	{
	$qstate{$nick}{'a'} = $1;
	#IRC::print("setting current answer to: '$1'\n");
	}

if ($qstate{$nick}{'q'} && $qstate{$nick}{'a'})
	{
	unless (&find_answer($nick, $qstate{$nick}{'q'}))
		{
		&save_answer($nick, $qstate{$nick}{'q'}, $qstate{$nick}{'a'});
		IRC::print("Q:" . $qstate{$nick}{'q'} . ", a:" . $qstate{$nick}{'a'} . " for bot " . $nick . " saved.\n");
		$qstate{$nick} = '';
		}
	}
return 0;		
}
	

sub find_answer {

my ($botname, $findqnum) = @_;

open QDB, "$qdb";
my $line = 0;
while (my ($bot,$qnum, $a, $foo) = split /\|/, <QDB>)
	{
	$line++;
	if (($bot eq $botname) && ($qnum == $findqnum))
		{
		close QDB;
		my @ret = ($a, $line, $bot);
		return @ret;
		}
	}

close QDB;
my @ret = (0, 0, 0);
return @ret;

} # end of sub find_by_id



sub save_answer {

my ($botname, $qnum, $a) = @_;

open QDB, ">>$qdb";
print QDB "$botname|$qnum|$a|\n";
close QDB;


} # end of sub save_answer





sub output_list {
# takes an array of items, and write a friendly list, for example:
# output_list(@(1,2,3,4)) returns "one, two, three and four".
# David Precious, Aug 2003
my @items = @_;
my $items_done = 0;
my $out_string = '';
foreach $item (@items)
	{
	$out_string .= $item;
	$items_done++;
	if ($items_done == @items-1)
		{
		$out_string .= ' and ';
		} elsif ($items_done < @items) {
		$out_string .= ', ';
		}
	}
return $out_string;
}
