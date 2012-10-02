#!/usr/bin/env perl
use 5.16.1;
use strict;
use warnings;
use POE qw(Component::IRC);
use YAML qw(LoadFile);
use Data::Dumper;

# hardcoding location of config file, feel free to change
my $configfilename = "config.yml";

# load YAML stream into perl data structures
my ($yamldata) = LoadFile("$configfilename");

# initializing essential variables
my $hostname = $yamldata->{hostname};
my $port = $yamldata->{port};
my $nick = $yamldata->{nick};
my $ircname = $yamldata->{ircname};
my $username = $yamldata->{username};

# Start IRC Connection (code borrowed from the module docs)
my $irc = POE::Component::IRC->spawn(
    nick => $nick,
    ircname => $ircname,
    port => $port,
    server => $hostname,
    username => $username,
) or die "Could not spawn POE component $!";

POE::Session->create(
    package_states => [
        main => [ qw(_start irc_001) ],
    ],
    heap => { irc => $irc },
);

$poe_kernel->run();

sub _start{
    my $heap = $_[HEAP];
    my $irc = $heap->{irc};
    $irc->yield( register => 'all' );
    $irc->yield( connect => { } );
    return;
}

sub irc_001 {
    my $sender = $_[SENDER];
    my $irc = $sender->get_heap();
    print "Connected to ", $irc->server_name(), "\n";
    return;
}
