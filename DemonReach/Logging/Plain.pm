package DemonReach::Logging::Plain;

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

has 'file' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);
my $fp;

=head2 Functions

All the functions used by DemonReach are exported by default.

=head3 functionname

function description

=cut

# code for module

sub BUILD {
    my $self = shift;
    open ($fp, ">>:encoding(UTF-8)",$self->{file});
}

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


=cut
1;
