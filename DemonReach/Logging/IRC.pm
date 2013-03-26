package DemonReach::Logging::IRC;

use strict;
use warnings;
use Moose;
our $VERSION = '0.01';
my $poeHeap;
=head1 NAME

DemonReach::Logging::IRC - module for logging to an IRC channel

=head1 SYNOPSIS
 
    # $irc is a PoCo::IRC instance
    addHandler('log',DemonReach::Logging::IRC->new(irc => $irc, channel => "#demonreach-log"));

=head1 DESCRIPTION

Module for logging to IRC channels from demonreach core.

This module is mostly provided as an example, and should not be used inside the main loghandler event,
as this will flood the IRC channel with all events should the standard default be used. It is more 
designed for you to use inside other handler groups that should log to IRC.

=cut


has 'irc' => (
    is => 'ro',
    required => 1,
);

has 'channel' => (
    is => 'ro',
    required => 1,
    isa => 'Str',
);
=head2 Functions


=head3 logEvent

To be used from dr_log_event, This function handles log events from the core.

=cut

sub logEvent {
    my $self = shift;
    my $data = shift;

    my $irc = $self->irc ;
    $irc->yield("privmsg",$self->channel,$data);
}


=head1 AUTHOR

Joshua Theze (foxiepaws) <joshua.theze@gmail.com>

=cut
1;
