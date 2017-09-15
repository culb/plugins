# File: eatTextEvents.pl
# Language: Perl
# Version: 0
#
# Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Description: A simple script to hide events from showing
# Usage: Add the events to hide in the for loop where 'Text events N' are
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
#########################################################################

use strict;
use warnings;
use Xchat qw( :all );

register( 'Eat Events', 0x00, 'Eat events' );

for my $event ( 'Text event 0',
                'Text event 1',
                'Text event 2' )
{
    hook_print( $event, sub{ return EAT_XCHAT; } );
}
