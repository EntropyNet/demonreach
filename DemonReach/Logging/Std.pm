package DemonReach::Logging::Std;

use strict;
use warnings;
use Moose;
#use POE qw(Wheel::ReadWrite);

use Data::Dumper;
our $VERSION = '0.01';

=head1 NAME

DemonReach::Logging::Std - module for logging to standard output.

=head1 SYNOPSIS

    addHandler('log',DemonReach::Logging::Std->new());

=head1 DESCRIPTION


=cut


=head2 Functions

=head3 logEvent

logs to std out and flushes.

=cut

# code for module


sub logEvent {
    my $self = shift;
    my $data = shift;
    print "$data\n";
    $| = 1;
}

=head1 AUTHOR

Joshua Theze (foxiepaws) <joshua.theze@gmail.com>

=cut
1;
