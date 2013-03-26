package DemonReach::Logging::Plain;

use strict;
use warnings;
use Moose;
#use POE qw(Wheel::ReadWrite);

use Data::Dumper;
our $VERSION = '0.01';

=head1 NAME

DemonReach::Logging::Plain - module for logging to plaintext files.

=head1 SYNOPSIS
 
    addHandler('log',DemonReach::Logging::Plain->new(file=> core.log));

=head1 DESCRIPTION



=cut

# handler modules are different, as they use an object approach.

has 'file' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);
my $fp;

=head2 Functions

Functions related to logging to plaintext files in DemonReach

=cut


sub BUILD {
    my $self = shift;
    open ($fp, ">>:encoding(UTF-8)",$self->{file});
}

=head3 logEvent
All the functions used by Demonare exported by default.

To be used from dr_log_event, This function handles log events from the core.

=cut
sub logEvent {
    my $self = shift;
    my $data = shift;
    print $fp "$data\n";
    my $old = select($fp);
    $| = 1;
    select($old); 
}

sub DEMOLISH {
    close $fp;
}
=head1 AUTHOR

Joshua Theze (foxiepaws) <joshua.theze@gmail.com>

=cut
1;
