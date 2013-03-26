package DemonReach::Logging::IRC;

use strict;
use warnings;
use Moose;
our $VERSION = '0.01';
my $poeHeap;
=head1 NAME

DemonReach:: - module for working with.

=head1 SYNOPSIS
 

=head1 DESCRIPTION

This is a module for DemonReach, which uses these modules internally to 
perform specific functions such as channel logging and such.

=cut

# handler modules are different, as they use an object approach.

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

All the functions used by DemonReach are exported by default.

=head3 functionname

function description

=cut


sub logEvent {
    my $self = shift;
    my $data = shift;
    
    my $irc = $self->irc ;
    $irc->yield("privmsg",$self->channel,$data);

}

# code for module

=head1 AUTHOR


=cut
1;
