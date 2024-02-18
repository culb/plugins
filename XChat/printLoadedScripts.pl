# File: printLoadedScripts.pl
# Language: Perl
# Version: 0
#
# Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Description: A simple script to print loaded Perl scripts
# Usage: /printscripts
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
########################################################################

use strict;
use warnings;
use Xchat qw( :all );

hook_command(
    'PRINTSCRIPTS',
    sub{
        serverTab( get_info 'id' );
        # Find names ending in :: and remove the ::
        for my $fileName ( sort grep s!::$!!, keys %Xchat::Script:: )
        {
    	    # The following is needed to remove what the unpack does in
    	    # this regex in the file2pkg subroutine in the Embed.pm file
    	    # s|([^A-Za-z0-9/])|'_'.unpack("H*",$1)|eg
    	    $fileName =~ s!_5f!_!g;
    	    prnt $fileName;
        }
        return EAT_XCHAT;
    },
    {
        help_text => "/printscripts - Print out the loaded Perl scripts to the server tab"
    }
);

sub serverTab
{
    my $connectionId = shift;
    for my $tab ( get_list 'channels' )
    {
        if ( $tab->{id} == $connectionId && $tab->{type} == 1 )
        {
            return set_context( $tab->{context} );
        }
    }
    return;
}

register(
    'Print Loaded Scripts',
    0x01,
    'Print Loaded Perl Scripts',
    undef
);
