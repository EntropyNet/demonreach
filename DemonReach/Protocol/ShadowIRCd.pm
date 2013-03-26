package DemonReach::Protocol::ShadowIRCd;

use strict;
use warnings;
use base 'Exporter';
use feature 'switch';
our @EXPORT = qw(handle_snotice);

our $VERSION = '0.01';

=head1 NAME

DemonReach::Protocol::ShadowIRCd - Protocol module for working with ShadowIRCd.

=head1 SYNOPSIS
 
    # from within core edit the protocol line.
    use DemonReach::Protocol::ShadowIRCd;

=head1 DESCRIPTION

This is a protocol module for DemonReach, which uses these modules internally
to understand messages that the IRCd sends to the statistics bot, such as 
server notices, stats queries and understanding the output of links/map.

=head2 Functions

All the functions used by DemonReach are exported by default.

=head3 handle_snotice

DemonReach passes the function the raw snotice, and then this module 
returns a hash that describes the snotice to be used by demonreach.

=cut


sub handle_snotice {
    my $raw = shift;
 
    # clean up the snotice so we don't have to clean this up afterwards
    $raw =~ s/\*\*\* Notice --//;
 
    given ($raw) {
        when (/Client connecting/) {
            $raw =~ /Client connecting: (.*)\s\((.*)\)\s\[(.*)\]\s\{(\w+)\}\s\[(.*)\]/;
            my $data = { type => 'connect', nick => $1, hostmask => $2, ip => $3, class => $4, realname => $5 };
            return $data;
        }
        when (/Client exiting/) {
            $raw =~ /Client exiting: (.*)\s\((.*)\)\s\[(.*)\]\s\[(.*)\]/;
            my $data = { type => 'disconnect', nick => $1, hostmask => $2, reason => $3, ip => $4};
            return $data;
        }
        when (/Failed OPER attempt/) {
            $raw =~ /Failed OPER attempt - (.*) by (.*)\s\((.*)\)/;
            my $data = { type => 'failedoper', reason => $1, nick => $2, hostmask => $3 };
            return $data;
        }
        when (/is now an operator/) {
            $raw =~ /(.*)\s\((.*)\) is now an operator/;
            my $data = { type => 'oper', nick => $1, hostmask => $2 };
            return $data;
        }
        when (/Received KILL/) {
            my @r = $raw =~ /Received KILL message for\s(.*)\sFrom\s(.*)\sPath:\s(.*)\s\((.*)\)/;
            #my $n = $r[0] s/[!@]/!/r;
            my ($nick, $host) = split /!/,$r[0];
            my $data = { type => 'kill', nick => $nick, hostmask => $host, oper => $r[1], server => $r[2], reason => $r[3] };
            return $data;
        }
        default {
            return {type => 'unhandled', raw=> $raw};
        }
    }
}

=head1 AUTHOR

Joshua Theze <joshua.theze@gmail.com>

=cut
1;
