# File: gotoall.pl
# Language: Perl
# Version: 1
#
# Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Description: Clear the server list of activity
# Usage: /GTA
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
########################################################################

use strict;
use warnings;
use Xchat qw( :all );

register( 'Go to All', 0x01, 'Clear the server list of activity' );

hook_command 'GTA' => sub
{
    my $context = get_info( 'context' );
    for my $channel ( get_list( 'channels' ) )
    {
        command( "GUI COLOR 0", $channel->{channel}, $channel->{network} );
    }
    set_context $context;
    return EAT_XCHAT;
},
{
    help_text => 'Usage: GTA, Clear the server list(servers and channels) of activity'
};
