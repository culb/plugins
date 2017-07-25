# File: eatTextEvents.pl
# Language: Perl
#
# Author: culb (nightfrog)
# Contact: the01culb@gmail.com
#
# Purpose:
#  A simple script to hide events from showing
#  Add the events to hide in the for loop where 'Text events N' are
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
########################################################################

use strict;
use warnings;
use Xchat qw( :all );

register( 'Eat Events', 0x0, 'Eat events' );

for my $event ( 'Text event 0',
                'Text event 1',
                'Text event 2' )
{
    hook_print( $event, sub{ return EAT_XCHAT; } );
}
