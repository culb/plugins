# File: channel_switcher_user_count.pl
# Language: Perl
# Version: 1
#
# Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Description: Add the number of users in a channel next to the channel name
# Usage: N/A
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
########################################################################

use strict;
use warnings;
use Xchat qw( :all );


register(
    'Number of users',
    0x01,
    'Add the number of users to the channel switcher'
);


hook_print( "You Join", \&you_join );


hook_timer( 3000,
    sub
    {
        my $context = get_info 'context';

        for my $list ( get_list 'channels' )
        {
            if ( $list->{type} == 2 )
            {
                set_context $list->{context};
                command( 'SETTAB ' . $list->{users} . ' ' . $list->{channel} );
            }
        }

        set_context $context;
        return KEEP;
    }
);


sub you_join
{
    my $number;
    $number++ for get_list 'users';
    command( 'SETTAB ' . $number . ' ' . get_info 'channel' ) if $number;
}
