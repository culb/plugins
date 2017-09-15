# File: hide_topic.pl
# Language: Perl
# Version: 2
#
# Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Description: Hide the topic, channel url, and ChanServ notice when a join a channel
# Usage: N/A
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
#####################################################################################
use strict;
use warnings;
use Xchat qw( :all );


hook_print( 'Notice', \&notice );
hook_print( 'You Join', \&you_join );


sub notice
{
    my ( $who, $message ) = @{$_[0]};

    if ( $who eq 'ChanServ' and $message =~ m/^\[#\w+\] Welcome to/ )
    {
        return EAT_XCHAT;
    }
}

sub you_join
{
    for my $event ( 'Channel Url', 'Topic', 'Topic Creation' )
    {
        hook_print( $event, sub{ return EAT_XCHAT; } );
    }
}


register(
    'Hide the topic',
    0x02,
    'Hide the topic when you join a channel'
);
