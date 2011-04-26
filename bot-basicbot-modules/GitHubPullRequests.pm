# A quick Bot::BasicBot::Pluggable module to fetch a count of open pull requests
# for a GitHub project.
#
# David Precious <davidp@preshweb.co.uk>

package Bot::BasicBot::Pluggable::Module::GitHubPullRequests;
use strict;
use base 'Bot::BasicBot::Pluggable::Module';
use LWP::Simple ();
use JSON;

sub help {
    return <<HELPMSG;
Monitors outstanding pull requests on a GitHub project.

Allows use of a !pr command to fetch the current count of open pull requests,
and can also periodically announce them on a timer.
HELPMSG
}


sub said {
    my ($self, $mess, $pri) = @_;
    
    #return unless $pri == 2;

    if ($mess->{body} =~ /!pr (?: \s+ (\S+))?/xi) {
        my $check_projects = $1;
        $check_projects ||=  $self->get('user_monitor_projects');
        if (!$check_projects) {
            $self->reply(
                $mess, 
                "No project(s) to check; either specify"
                . " a project, e.g. '!pr username/project', or use the Vars"
                . " module to configure the monitor_projects setting for this"
                . " module to set the default project to check."
            );
            return 1;
        }
        $self->reply($mess, "OK, I'll check for PRs on $check_projects");
        for my $project (split /,/, $check_projects) {
            my $prs = $self->_get_pull_request_count($project);
            $self->say(
                channel => $mess->{channel},
                body => "Open pull requests for $project : $prs",
            );
        }
        return 1; # "swallow" this message
    }
    return; # This message didn't interest us
}


sub _get_pull_request_count {
    my ($self, $project) = @_;
    my $url = "http://github.com/api/v2/json/pulls/" . $project;
    my $json = LWP::Simple::get($url)
        or return "Unknown - error fetching $url";
    my $pulls = JSON::from_json($json)
        or return "Unknown - error parsing API response";

    my %pulls_by_author;
    $pulls_by_author{$_}++
        for map { $_->{issue_user}{login} } @{ $pulls->{pulls} };
    my $msg = scalar @{ $pulls->{pulls} } . " pull requests open (";
    $msg .= join(", ", 
        map  { "$_:$pulls_by_author{$_}" }
        sort { $pulls_by_author{$b} <=> $pulls_by_author{$a} }
        keys  %pulls_by_author 
    );
    $msg .= ")";
    return $msg;
}

1;

