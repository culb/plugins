# File: 4x4EvolutionMormalizer.pl
# Language: Perl
# Version: 2
#
# Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Purpose: Show realnames instead of nicks to mimic 4x4 Evolution
#
# Shit that needs accomplished
#      2: Handle misc events that I forgot or overlooked
#      3: Fix any mistakes I have made
#################################################################

use strict;
use warnings;
use Xchat qw( :all );

# Add the network(s) this script should work with
my @netNames = qw( 4x4 4x4_nightfrog 4x4_sponji );

# Path to the evotool
# The \ in a Windows path needs to be escaped
my $evotool = "C:\\Users\\Jesse\\AppData\\Roaming\\HexChat\\addons\\evotool2.exe";

# Make a hash for the the nicks and realnames global yet not global
# Eventually make this an object with accessors
#
# Push to the list
# listPush( $net, $nick, $realname )
#
# Delete a user
# listDeleteUser( $net, $nick )
#
# Delete a network
# listDeleteNet( $net )
#
# Get the list
# listGet()
# A reference is return and you must dereference it!
# Example: my %hash = %{ listGet() };

{
    my %list;

    sub listPush
    {
        my ( $net, $nick, $realname ) = @_;

        if( $net and $nick and $realname )
        {
            $list{ $net }->{ $nick } = $realname;
            return 1;
        }
        return;
    }

    sub listDeleteUser
    {
        my ( $net, $nick ) = @_;

        if( exists $list{ $net }->{ $nick } )
        {
            delete $list{ $net }->{ $nick };
            return 1;
        }
        return;
    }

    sub listDeleteNet
    {
        my ( $net ) = @_;

        if( exists $list{ $net } )
        {
            delete $list{ $net };
            return 1;
        }
        return;
    }

    sub listGet
    {
        return \%list;
    }
}

# When the script is loaded into an already running XChat
# we need to "scan" the networks and WHO each channel on our network(s)
init0();
sub init0
{
    # Remember this context for later
    my $context = get_info( 'context' );

    my $tabType;
    my $tabNetwork;
    my $tabName;
    my $tabContext;

    for my $tab ( get_list( 'channels' ) )
    {
        $tabType    = $tab->{ type };
        $tabNetwork = $tab->{ network };
        $tabName    = $tab->{ channel };
        $tabContext = $tab->{ context };

        if( $tabType == 2 and grep { lc( $_ ) eq lc( $tabNetwork ) } @netNames )
        {
            set_context( $tabContext );
            whoGet( $tabNetwork, $tabName );
        }
    }

    # Go back to the original window
    set_context( $context );
}


# Most of the events are the same and can be looped through
for my $event ( 'Channel Message', 'Channel Msg Hilight' )
{
    hook_print( $event, \&eventChannelMessage, { 'data' => $event } );
}

for my $event ( 'Private Message', 'Private Message to Dialog' )
{
    hook_print( $event, \&eventPrivateMessage, { 'data' => $event } );
}

for my $event ( 'Notice', 'Notice Send' )
{
    hook_print( $event, \&eventNotice, { 'data' => $event } );
}

for my $event ( 'Channel DeOp',
                'Channel DeHalfOp',
                'Channel DeVoice',
                'Channel Half-Operator',
                'Channel Operator',
                'Channel Voice' )
{
    hook_print( $event, \&eventChannelMode, { 'data' => $event } );
}


# Channel messages
sub eventChannelMessage
{
    my ( $data, $event ) = @_;
    my ( $nick, $what, $mode ) = @$data;

    my $network = get_info( 'network' );
    my $channel = get_info( 'channel' );

    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };

        #That dirty little message the client sends when it joins a channel
        #emit a join message here since there is a realname to send in it
        if( $what =~ m/^\^STATUS\s(.+)/g )
        {
            my $realname = ( split( /\^0|\^1/, $1 ) )[0];
            emit_print( 'Join', $realname, $channel, user_info( $nick )->{ host } );
            return EAT_XCHAT;
        }

        #If the NICK has not been pushed into the list then
        #it needs to be done and hopefully before the emit.
        if( not exists $nnr{ $network }->{ $nick } )
        {
            whoGet( $network, $nick );
        }
        elsif( exists $nnr{ $network }->{ $nick } )
        {
            my $realname = ( split( /\^0|\^1/, $nnr{ $network }->{ $nick } ) )[0];
            emit_print( $event, $realname, $what, $mode );
            return EAT_XCHAT;
        }
    }

    return EAT_NONE;
}


# Private messages
sub eventPrivateMessage
{
    my ( $data, $event ) = @_;
    my ( $nick, $what )  = @$data;

    my $network = get_info( 'network' );
    my $channel = get_info( 'channel' );

    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };

        #If the NICK has not been pushed into the list then
        #it needs to be done and hopefully before the emit.
        if( not exists $nnr{ $network }->{ $nick } )
        {
            whoGet( $network, $nick );
        }
        elsif( exists $nnr{ $network }->{ $nick } )
        {
            my $realname = ( split( /\^0|\^1/, $nnr{ $network }->{ $nick } ) )[0];
            emit_print( $event, $realname, $what );
            return EAT_XCHAT;
        }
    }

    return EAT_NONE;
}


# Notices
sub eventNotice
{
    my ( $data, $event ) = @_;
    my ( $nick, $what )  = @$data;

    my $network = get_info( 'network' );

    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };
        
        if( not exists $nnr{ $network }->{ $nick } and $nick !~ /^#/ )
        {
            whoGet( $network, $nick );
        }
        elsif( exists $nnr{ $network }->{ $nick } )
        {
            my $realname = ( split( /\^0|\^1/, $nnr{ $network }->{ $nick } ) )[0];
            emit_print( $event, $realname, $what );
            return EAT_XCHAT;
        }
    }

	return EAT_NONE;
}


# Channel modes
sub eventChannelMode
{
    my ( $data, $event ) = @_;
    my ( $by, $to ) = @$data;

    my $network = get_info( 'network' );

    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };

        #Don't need to who both if only one needs to be who'ed
        if( not exists $nnr{ $network }->{ $by } )
        {
            whoGet( $network, $by );
        }
        
        if( not exists $nnr{ $network }->{ $to } )
        {
            whoGet( $network, $to );
        }
        elsif( exists $nnr{ $network }->{ $by } and exists $nnr{ $network }->{ $to } )
        {
            my $realname0 = ( split( /\^0|\^1/, $nnr{ $network }->{ $by } ) )[0];
            my $realname1 = ( split( /\^0|\^1/, $nnr{ $network }->{ $to } ) )[0];
            emit_print( $event, $realname0, $realname1 );
            return EAT_XCHAT;
        }
    }

    return EAT_NONE;
}


#Delete a network from the hash when a Server context is closed
hook_print 'Close_Context' => sub
{
    my $network = context_info->{ network };
        
    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };

        #Proceed if it is a server context and from out list of networks
        if( context_info->{ type } == '1'
            and exists $nnr{ $network }
            and grep { lc( $_ ) eq lc( $network ) } @netNames )
        {
            listDeleteNet( $network );
        }
    }

    return EAT_NONE;
};

# EAT the event since it's handled in eventChannelMessage()
hook_print 'Join' => sub
{
    my ( $nick, $channel, $host ) = @{ $_[0] };

    my $network = get_info( 'network' );

    if( grep { lc( $_ ) eq lc( $network ) } @netNames 
        and $nick =~ /[A-P]{12}|^_/ ) # NICK must be Evo or Admin
    {
        return EAT_XCHAT;
    }

    return EAT_NONE;
};


hook_print 'Part' => sub
{
    my ( $nick, $host, $channel ) = @{ $_[0] };

    my $network = get_info( 'network' );

    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };
        if( exists $nnr{ $network }->{ $nick } )
        {
            my $realname = ( split( /\^0|\^1/, $nnr{ $network }->{ $nick } ) )[0];
            emit_print( 'Part', $realname, $host, $channel );
            listDeleteUser( $network, $nick );
            return EAT_XCHAT;
        }
    }

    return EAT_NONE;
};


hook_print 'Quit' => sub
{
    my ( $nick, $reason, $host ) = @{ $_[0] };

    my $network = get_info( 'network' );

    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };
        if( exists $nnr{ $network }->{ $nick } ) 
        {
            my $realname = ( split( /\^0|\^1/, $nnr{ $network }->{ $nick } ) )[0];
            emit_print( 'Quit', $realname, $reason, $host );
            listDeleteUser( $network, $nick );
            return EAT_XCHAT;
        }
    }

    return EAT_NONE;
};


hook_print 'You Join' => sub
{
    my ( $me, $channel, $host ) = @{ $_[0] };

    my $network = get_info( 'network' );

    # This is the order of the commands the client sends when it joins a channel
    # Taken directly from the irc.log file
    #
    #  IN  | :aServer.com 366 NICK #EvoR :End of /NAMES list.
    #  OUT | RCHG :nightfrog^0
    #  OUT | PRIVMSG #EvoR :^STATUS nightfrog^0
    #  OUT | TOPIC #EvoR
    #  OUT | WHO #EvoR
    #
    # We need to detect the end of /names and then what we need to do.
    # Let's do this....

    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };
 
        my $namesEnd;
        $namesEnd = hook_server '366' => sub
        {
            if( lc( $_[0][3] ) eq lc( $channel ) )
            {

                # We will who the channel in a little bit and add our realname
                # to the hash then so for now use get_prefs() for our realname
                command( 'QUOTE RCHG :' . get_prefs( 'irc_real_name' ) );
                command( 'QUOTE PRIVMSG ' . $channel . ' :^STATUS ' . get_prefs('irc_real_name') );

                # Just an example if we were follow the order but XChat does this already
                # and we don't give a shit when we get the topic.
                # command( 'TOPIC ' . $channel );

                whoGet( $network, $channel );
            }  
            unhook( $namesEnd );
        };
    }

    return EAT_NONE;
};


hook_print 'Your Message' => sub
{
    my ( $nick, $what, $mode ) = @{ $_[0] };

    my $network = get_info( 'network' );

    # Only continue if the channel message is from one of the wanted networks
    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };

        # If the NICK has not been pushed into the list then
        # it needs to be done and hopefully before the emit.
        if( not exists $nnr{ $network }->{ $nick } )
        {
            whoGet( $network, $nick );
        }
        elsif( exists $nnr{ $network }->{ $nick } )
        {
            my $realname = ( split( /\^0|\^1/, $nnr{ $network }->{ $nick } ) )[0];
            emit_print( 'Your Message', $realname, $what, $mode );
            return EAT_XCHAT;
        }
    }

    return EAT_NONE;
};


hook_print 'Channel Notice' => sub
{
    my ( $nick, $channel, $what ) = @{ $_[0] };

    my $network = get_info( 'network' );

    # Do nothing unless there is a network in the network list
    return EAT_NONE unless $network;

    # Only continue if the channel message is from one of the wanted networks
    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };

        if( not exists $nnr{ $network }->{ $nick } )
        {
            whoGet( $network, $nick );
        }
        elsif( exists $nnr{ $network }->{ $nick } )
        {
            my $realname = ( split( /\^0|\^1/, $nnr{ $network }->{ $nick } ) )[0];
            emit_print( 'Channel Notice', $realname, $channel, $what );
            return EAT_XCHAT;
        }
    }

    return EAT_NONE;
};

#Add or change a user when the /RCHG command is executed
hook_server 'RCHG' => sub
{
    my $nick     = substr( $_[0][0], 1 );
    my $realname = substr( $_[1][2], 1 );
    my $network  = get_info( 'network' );

    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my %nnr = %{ listGet() };

        if( not exists $nnr{ $network }->{ $nick } )
        {
            $nnr{ $network }->{ $nick } = $realname;
        }
        elsif( exists $nnr{ $network }->{ $nick } )
        {
            my $me = user_info();

            #Only need to see when the actual realname changes
            #and not the lap count and other shit in the realnames
            my $nameNew = ( split( /\^0|\^1/, $realname ) )[0];
            my $nameOld = ( split( /\^0|\^1/, $nnr{ $network }->{ $nick } ) )[0];

            #Them
            if( lc( $nameNew ) ne lc( $nameOld ) and $me->{ nick } ne $nick )
            {
                $nnr{ $network }->{ $nick } = $nameNew;
                emit_print( 'Change Nick', $nameOld, $nameNew );
            }

            #Us
            elsif( lc( $nameNew ) ne lc( $nameOld ) and $me->{ nick } eq $nick )
            {
                $nnr{ $network }->{ $nick } = $nameNew;
                emit_print( 'Your Nick Changing', $nameOld, $nameNew );
            }
        }
    }

    return EAT_XCHAT;
};


# If there are multiple networks, the generated connection information gets lost between the
# networks so the information for each network is temporarily saved based on the connections id and then used to Connect
# The temporary information is deleted upon connection
{
my %connectInfo;
hook_server 'RAW LINE' => sub
{
	my ( $wordOne, $wordTwo, $wordThree ) = @{$_[0]};

    my $network = get_info( 'network' );

    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my $id = get_info( 'id' );

        if( $wordOne eq 'CHALLENGE' )
        { $connectInfo{ $id }->{ 'challenge' } = $wordTwo; }

        # :server.name.com 302 unknown=+unknown@1.1.1.1
        if( defined $wordThree and $wordThree =~ /unknown=\+unknown\@(.+)/ )
        {
            $connectInfo{ $id }->{ 'ip' } = $1;
            $connectInfo{ $id }->{ 'nick' } = ipToNick( $1 );
            $connectInfo{ $id }->{ 'longip' } = longIP( $1 );
            $connectInfo{ $id }->{ 'password' } = `$evotool +2 $connectInfo{ $id }->{'nick'} $connectInfo{ $id }->{'longip'} $connectInfo{ $id }->{'challenge'}`;
            my( $network_info ) = grep { $_->{'network'} eq $network } get_list( 'networks' );

            command( "QUOTE PASS " . $connectInfo{ $id }->{ 'password' } );
            command( "QUOTE NICK " . $connectInfo{ $id }->{ 'nick' } );
            command( "QUOTE USER " . $network_info->{irc_user_name} . " " . $connectInfo{ $id }->{ 'ip' }
                              . " " . $connectInfo{ $id }->{ 'ip' } . " :" . $network_info->{irc_real_name} );
        }
    }

	return EAT_NONE;
};

hook_print 'Connected' => sub
{
    my $network = get_info( 'network' );

    if( grep { lc( $_ ) eq lc( $network ) } @netNames
         and $connectInfo{ get_info( 'id' ) } )
    {
        delete $connectInfo{ get_info( 'id' ) };
    }

    return EAT_NONE;
};
}


=pod
hook_server '302' => sub
{
	# :server.name.com 302 unknown=+unknown@1.1.1.1
	my ( $server, $numeric, $info ) = @{$_[0]};
	if( defined $info and $info =~ /unknown=\+unknown\@(.+)/ ){ $ip = $1; }
	return EAT_NONE;
};
=cut

sub whoGet
{
    # Handle channel and nick who's here
    # $channel can be either a channel or nick
    my ( $network, $channel ) = @_;

    if( $network and $channel ) #Make sure...
    {
        command( 'QUOTE WHO ' . $channel ); # Wasn't needed before

        my $hooked_who;
        $hooked_who = hook_server '352' => sub
        {
            #$_[0][3]  -- CHANNEL
            #$_[0][7]  -- NICK
            #$_[1][10] -- REALNAME
            if( lc( $_[0][3] ) eq lc( $channel )
                or lc( $_[0][7] ) eq lc( $channel ) )
            {
                listPush( $network, $_[0][7], $_[1][10] )
            }
            return EAT_XCHAT;
        };

        # At the end of the /who unhook each numeric event
        my $who_end;
        $who_end = hook_server '315' => sub
        {
            unhook( $hooked_who );
            unhook( $who_end );
            return EAT_XCHAT;
        };
    }
}

hook_command 'iptonick' => sub
 {
    my $ip = $_[0][1];
    my $regexIP = qr/^(?:(?:25[0-5]|2[0-4][\d]|[0-1]?[\d]{1,2})[.]
                         (?:25[0-5]|2[0-4][\d]|[0-1]?[\d]{1,2})[.]
                         (?:25[0-5]|2[0-4][\d]|[0-1]?[\d]{1,2})[.]
                         (?:25[0-5]|2[0-4][\d]|[0-1]?[\d]{1,2}))$/x;

    if( $ip =~ $regexIP )
    { prnt ipToNick( $ip ); }
    else
    { prnt 'Please enter a valid IP address.'; }

    return EAT_XCHAT;
},
{
    help_text => 'Convert a 32 bit IP to a valid 4x4 EvoR NICK'
};

hook_command 'nicktoip' => sub
{
    my $nick = $_[0][1];

    if( $nick  =~ /[A-P]{12}/ )
    { prnt nickToIPPort( $nick ); }
    else
    { prnt 'Please enter a valid 4x4 EvoR nick'; }

    return EAT_XCHAT;
},
{
    help_text => 'Convert a 4x4 EvoR nick to 32 bit IP address'
};

hook_command 'netfo' => sub
{
    my( $network ) = grep { $_->{'network'} eq get_info( 'network' ) } get_list( 'networks' );
    prnt $network->{irc_user_name};
    return EAT_XCHAT;
};

sub longIP
{
   return unpack 'N!', pack 'C4', split /\./, $_[0];
}

sub nickToIP
{
    my $nick = $_[0];
    $nick =~ tr/A-P/0-9A-F/;
    return sprintf( "%vd", unpack "A4n", pack "H*", $nick );
}

sub nickToIPPort
{
    my $nick = $_[0];
    $nick =~ tr/A-P/0-9A-F/;
    return sprintf( "%vd:d", unpack "A4n", pack "H*", $nick );
}

sub ipToNick
{
    if( $_[0] )
    {
        my $ip = unpack "H8", pack "C4n", split /\./, $_[0];
        $ip    =~ tr/0-9a-f/A-P/;

        # 65535 - 49152 = 16383
        my $port = unpack "H4", pack "S4n", int( rand( 16383 ) ) + 49152;
        $port    =~ tr/0-9a-f/A-P/;

        return $ip . $port;
    }
}

register(
    'Realnames',
    0x1368D1,
#    0x3DFB3F,
    'Replace NICKS in the Text Events with realnames to mimic 4x4 Evolution'
);

__END__

##########################################################################
##########################################################################

# UPDATE
# So I did some thinking and came up with what you are about to see
# Here is how it works
#
# The real client sends a PRIVMSG beginning with ^STATUS
# when it joins to let the other clients know it joined the channel.
# Since we know it will send this we can use it as a point to emit the join event
#
# 1: The JOIN hook_print hooks the join events for all of XChat
# 2: Check if this happened on a server specified in @netNames (Duh)
# 3: Hook the message and then and use the real name in it to add to the emit
# 4: $1 contains the realname in the ^STATUS message
# 5: Unhook the PRIVMSG event and the JOIN event
#
#
# While typing these comments I came up with a better solution
# $hookJoin being global doesn't sit well with me.


THIS IS WORKING CODE!

my $hookJoin; # Global :-(
$hookJoin =
hook_print 'Join' => sub
{
    my ( $nick, $channel, $host ) = @{ $_[0] };

    my $network = get_info('network');

    if( grep { lc( $_ ) eq lc( $network ) } @netNames )
    {
        my $hookPRIVMSG;
        $hookPRIVMSG =
        hook_server('PRIVMSG', sub
        {
            # Host    $_[0][0];
            # Event   $_[0][1];
            # Channel $_[0][2];
            # Message $_[1][3];
            if( lc( $_[0][2] ) eq lc( $channel )
                and $_[1][3] =~ m/^:\^STATUS\s(.+)/
                and exists $nnr{ $network }->{ $nick } )
            {
                my $realname = ( split( /\^0|\^1/, $1 ) )[0];
                emit_print( 'Join', $realname, $channel, $host );
            }
            unhook( $hookPRIVMSG );
        };
            
        unhook( $hookJoin );
        return EAT_XCHAT;
    }

	return EAT_NONE;
};

use EvoTool;
hook_command 'evogen' => sub
{
    my $nick = $_[0][1];
    my $longIP = longIP( $_[0][2] );
        
    my $password  = EvoTool::Evo1Password( $nick, $longIP );
    my $pwdVerify = EvoTool::verifyPasswordEvo1( $nick, $longIP, $password );
    if( $pwdVerify )
    {
        prnt $password;
    }
    return EAT_XCHAT;
},
{
    help_text => 'Convert a 4x4 EvoR password generator'
};
