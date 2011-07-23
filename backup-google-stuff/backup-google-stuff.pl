#!/usr/bin/perl

# $Id: backup-google-stuff.pl 837 2010-02-24 11:58:23Z davidp $

use common::sense;
use DateTime;
use File::Copy;
use WWW::Mechanize;
use YAML;

# Sure, Google "do no evil", but I don't trust them to hold my data without me
# having a backup.

my $account = YAML::LoadFile($ENV{HOME} . "/.google_login")
    or die "Failed to read $ENV{HOME}/.google_login - $!";
my $backup_dir = '/mnt/backup/google';

# First, log in:
my $mech = WWW::Mechanize->new;
$mech->get('https://calendar.google.com/');
$mech->form_with_fields(qw(Email Passwd))
    or die "Failed to locate login form";
$mech->set_fields(
    Email => $account->{username}, Passwd => $account->{password}
);
$mech->submit or die "Failed to submit login form";

# Now, fetch the ical export ZIP file:
my $dt = DateTime->now;
my $ymd = $dt->ymd;

$mech->get(
    'http://www.google.com/calendar/exporticalzip',
    ':content_file' => "$backup_dir/calendar_$ymd.ical.zip"
) or warn "Failed to fetch ical export ZIP file";

# And now, export all contacts, both in Google's CSV format and vCard format,
# for ease of later use:
for my $format (qw(VCARD GMAIL_CSV)) {
    $mech->get('https://mail.google.com/mail/contacts/data/export'
        . '?exportType=GROUP&groupToExport=%5EMine&out=' . $format,
        ':content_file' => "$backup_dir/contacts_${format}_$ymd"
    ) or warn "Failed to fetch contacts as $format";
}

# Finally, Google Reader subscriptions:
$mech->get('http://www.google.com/reader/subscriptions/export',
    ':content_file' => "$backup_dir/reader_subscriptions_$ymd.xml"
) or warn "Failed to fetch Reader subscriptions";

# Finally, copy the contacts to /shared/backups so my laptop can access them:
File::Copy::copy(
    "$backup_dir/contacts_VCARD_$ymd",
    "/shared/backups/google-contacts.vcard"
);
