package DemonReach::Logging::Std;

use strict;
use warnings;
use Moose;
#use POE qw(Wheel::ReadWrite);

use Data::Dumper;
our $VERSION = '0.01';

=head1 NAME

DemonReach:: - module for working with.

=head1 SYNOPSIS
 

=head1 DESCRIPTION

This is a module for DemonReach, which uses these modules internally to 
perform specific functions such as channel logging and such.

=cut

# handler modules are different, as they use an object approach.

=head2 Functions

All the functions used by DemonReach are exported by default.

=head3 functionname

function description

=cut

# code for module


sub logEvent {
    my $self = shift;
    my $data = shift;
    print "$data\n";
    $| = 1;
}

=head1 AUTHOR


=cut
1;
