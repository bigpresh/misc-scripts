# set-slack-status

A simple Perl script to update status on Slack.

Takes a legacy Slack token:
https://api.slack.com/legacy/custom-integrations/legacy-tokens

Sadly the ability to generate those is going away soon, and you instead have to
create a Slack app and stuff.

Set an entry in `~/.netrc` for `machine slack.com` with the `account` set to
your Slack legacy API token.

You can then run the script to set your status, optionally with an emoji as
the first argument.

## Examples

./set-slack-status :beers: "It's time for beer!"
./set-slack-status :clown_face: "Talking to THG"
./set-slack-status "Just text, no silly emojis here"

