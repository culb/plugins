# File: highlight_op.pl
# Language: Perl
# Version: 1
#
# Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Description: Highlight the lines from channel operators
# Usage: N/A
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
########################################################################

use strict;
use warnings;
use Xchat qw( :all );

hook_print( 'Channel Message', sub
{
    my ( $nick, $what, $mode ) = @{$_[0]};
    my $prefixes = context_info->{nickprefixes};

    if ( $mode and $mode ne '+' and index( $prefixes, $mode ) <= index( $prefixes, '@' ) )
    {
        emit_print( 'Channel Msg Hilight', $nick, $what, $mode );
        return EAT_XCHAT;
    }
});

register ( 'Highlight OPS', 0x01, 'Highlight OPS' );
