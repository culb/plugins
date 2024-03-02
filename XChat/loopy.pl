# File: loopy.pl
# Language: Perl
# Version: 1
#
# Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Description: Cure my boredom
# Usage: N/A
#
# Note: This will lock XChat up
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
########################################################################

use strict;
use warnings;
use Xchat qw( :all );

hook_command( 'LOOPY', sub
{
    EATMEMORY:
    goto EATMEMORY;
}, 
{
    help_text => '/LOOPY - Lock it up.'
}
);

register( 'Loopy', 0x01, 'Infinite loop' );
