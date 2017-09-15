# File: ns_identify_conceal.pl
# Language: Perl
# Version: 1
#
# Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Description: Prevent nickserv identification from accidentally being shown
# Usage: N/A
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
############################################################################

use strict;
use warnings;
use Xchat qw( :all );

register( 'NS Identify Concealer', 0x01, 'Prevent nickserv identifying from accidentally being shown' );

hook_print 'Key Press' => sub
{
    if( context_info->{type} == 0x02 # Channel
        and $_[0][0] == 0xFF0D # Enter
        and my $text = get_info 'inputbox' )
    {
        if( $text =~ /^(\s+)?[\/ns|\/?msg\s+nickserv].*/cg )
        {
            prnt 'Please fix your identification command';
            # The following two lines fix and then send the NS command
            #$text =~ s|^\s*(?:\/)?||;
            #command $text;
            return EAT_ALL;
        }
    }
};
