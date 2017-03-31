# File: ns_identify_conceal.pl
# Language: Perl
# Version: 0
# Author: culb (nightfrog)
# Contact: the01culb[at]gmail[dot]com
#
# Purpose: Prevent nickserv identification from accidentally being shown
########################################################################

use strict;
use warnings;
use Xchat qw( :all );

register( 'NS Identify Concealer', 0x0, 'Prevent nickserv identifying from accidentally being shown' );

hook_print 'Key Press' => sub
{
    if( context_info->{type} == 0x02 # Channel
        and $_[0][0] == 0xFF0D # Enter
        and my $text = get_info 'inputbox' )
    {
        if( $text =~ /^(?:\s+)?[\/ns|\/?msg\s+nickserv].*/cg )
        {
#            prnt 'Please fix your identification command';
            $text =~ s|^\s*(?:\/)?||;
            command $text;
            return EAT_XCHAT;
        }  
    }
};
