#use IRC::Message::Object;
use POE qw(Component::IRC Component::SSLify);
use YAML qw(LoadFile);
use Getopt::Long;
use feature 'switch';
use Data::Dumper;
# base functions.
use DemonReach::Base;

# Protocol Line
use DemonReach::Protocol::ShadowIRCd;

# Additional Modules.
use DemonReach::Logging::Plain; 
#use DemonReach::Logging::Std;
#use DemonReach::Logging::IRC

# declerations
my $debug = '';
my $verbose = '';
my $testonly = '';
my $configFile = 'config.yml';
my %irc_public_hooks = ();
my %irc_private_hooks = ();
my @statistics_handlers;
my @logging_handlers;


GetOptions(
    'verbose|v' => \$verbose, 
    'debug|d' => \$debug, 
    'c|config=s' => \$configFile,
    't|testonly' => \$testonly
);

# console log stuff
sub verbprint {
    my $stuff = shift;
    print $stuff . "\n" if $verbose;   
}

sub debugprint {
    my $stuff = shift;
    print "\033[36m" . $stuff . "\033[0m \n" if $debug;
}

# add a hook 
sub addHook {
    my $type = shift;
    my $trigger = shift;
    my $code = shift;
    
    given ($type) {
        when('private') {
            $irc_private_hooks{$trigger} = \$code;
        }
        when ('public') {
            $irc_public_hooks{$trigger} = \$code;
        }
        
    }
}
sub addHandler {
    my $type = shift;
    my $object = shift;

    given ($type) {
        when ('stats') {
            push @statistics_handlers, $object;
        }
        when ('log') {
            push @logging_handlers, $object;
        }
    }
}

sub dr_event_log {
    my $data = shift;
    my $target = shift;
    
    foreach (@logging_handlers){
        $_->logEvent($data);
    }
}


# testonly implies verbose and debug
$verbose = 1 if $testonly;
$debug = 1 if $testonly; 
debugprint ("CONFIG TEST MODE ACTIVATED, WILL NOT START AN IRC SESSION") if $testonly;

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
my $channels = ($configdata->{channels});

verbprint "Connecting to $hostname:$port as '$nick!~$username' with realname '$realname'";
# if SSL is 'on', set $SSL to 1, otherwise, 0
my $ssl = 0;
if ($configdata->{ssl} eq 'on') {
    $ssl = 1;
} 
verbprint ((sub {if ($ssl == 1) { return "SSL Enabled" } else { return "SSL Disabled" }})->());
my $ignoreMOTD = 0;
if ($configdata->{ignoreMOTD} eq 'on') {
    $ignoreMOTD = 1;
} 
verbprint ((sub {if ($ignoreMOTD == 1) { return "Ignoring MOTD" } else { return "Not Ignoring MOTD" }})->());


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
    dr_event_log join ' ', @output;
    return;
}

sub irc_001 {
    my $sender = $_[SENDER];
    my $irc = $sender->get_heap();
    verbprint "Connected to ", $irc->server_name();
    $irc->yield( oper => $operuser => $operpass);
    # we join our channels
    debugprint Dumper (@{$channels});
    foreach(@{$channels}) { debugprint Dumper $_; $irc->yield( join => $_ ) }
    return;
}

sub irc_snotice {
    my ($sender, $what,$who) = @_[SENDER, ARG0, ARG1 ];
    debugprint Dumper handle_snotice($what);
    return;
}
sub irc_375 {
    my ($sender, $what, $who) = @_[SENDER, ARG0, ARG1];
    (verbprint ("$who: $what")) if !$ignoreMOTD;
    return;
}

sub irc_372 {
    my ($sender, $what, $who) = @_[SENDER, ARG0, ARG1];
    (verbprint ("$who: $what")) if !$ignoreMOTD;
    return;
}

sub irc_376 {
    my ($sender, $what, $who) = @_[SENDER, ARG0, ARG1];
    (verbprint ("$who: $what")) if !$ignoreMOTD;
    return;
}

sub irc_public {

}
# POE Session 
POE::Session->create(
    package_states => [
        main => [ qw(_default _start irc_001 irc_snotice irc_375 irc_376 irc_372) ],
    ],
    heap => { irc => $irc },
);

# run the fucking bot.
addHandler('log',DemonReach::Logging::Plain->new(file => "test.log"));
#addHandler('log',DemonReach::Logging::IRC->new($irc,'#anope'));
#addHandler('log',DemonReach::Logging::Std->new());
$poe_kernel->run() if !$testonly;
