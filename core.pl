#use IRC::Message::Object;
use POE qw(Component::IRC Component::SSLify);
use YAML qw(LoadFile);
use Getopt::Long;
use Data::Dumper;

my $debug = '';
my $verbose = '';
my $configFile = 'config.yml';

GetOptions(
    'verbose|v' => \$verbose, 
    'debug|d' => \$debug, 
    'c|config=s' => \$configFile
);

sub verbprint {
    my $stuff = shift;
    print $stuff . "\n" if $verbose;   
}

sub debugprint {
    my $stuff = shift;
    print $stuff . "\n" if $debug;
}

debugprint "Debug mode activated";
verbprint "Verbose mode activated";
verbprint "Using config file: $configFile";

verbprint "Loading Config File";
my ($configdata) = LoadFile($configFile);

# for debug, dump the YAML object.
debugprint Dumper $configdata;

# 
my $hostname = $configdata->{hostname};
my $port     = $configdata->{port};
my $nick     = $configdata->{nick};
my $realname = $configdata->{realname};
my $username = $configdata->{username};
verbprint "Connecting to $hostname:$port as '$nick!~$username' with realname '$realname'";
# if SSL is 'on', set $SSL to 1, otherwise, 0
my $ssl = 0;
if ($configdata->{ssl} eq 'on') {
    $ssl = 1;
} 
verbprint ((sub {if ($ssl == 1) { return "SSL Enabled" } else { return "SSL Disabled" }})->());

# get Oper creds.
my $operuser = $configdata->{oper}->{username};
my $operpass = $configdata->{oper}->{password};

# POE::IRC stuff
my $irc = POE::Component::IRC->spawn(
        nick => $nick, 
        ircname => $realname,
        port=> $port, 
        server => $hostname, 
        username => $username,
        UseSSL => $ssl
    ) or die("Couldn't spawn POE component $!");

# start events
sub _start {
    my $heap = $_[HEAP];
    # retrieve our component's object from the heap where we stashed it
    my $irc = $heap->{irc};
    $irc->yield( register => 'all' );
    $irc->yield( connect => { } );
    return;
}

# default handler
sub _default {
    my ($event, $args) = @_[ARG0 .. $#_];
    my @output = ( "$event: " );
    for my $arg (@$args) {
        if ( ref $arg eq 'ARRAY' ) {
            push( @output, '[' . join(', ', @$arg ) . ']' );
        } else {
            push ( @output, "'$arg'" );
        }
    }
    verbprint join ' ', @output;
    return;
}




# POE Session 
POE::Session->create(
    package_states => [
        main => [ qw(_default _start) ],
    ],
    heap => { irc => $irc },
);

# run the fucking bot.
$poe_kernel->run();

