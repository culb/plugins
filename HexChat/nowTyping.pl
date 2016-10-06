# File: nowTyping.pl
# Language: Perl
#
# Author: culb (nightfrog)
# Contact: the01culb@gmail.com
#
# Usage: Let a channel or private message dialog know that you are typing
#        Enable, /set nowtyping 1
#        Disable, /set nowtyping 0
#
# If this code is used in any way then
# be courteous and include all of my information and notes

use strict;
use warnings;
use HexChat qw( :all );

preference_set();
sub preference_set
{
    if( not plugin_pref_get 'nowTyping' )
    { plugin_pref_set 'nowTyping', 1; }
}

my $enable = 0;

hook_print 'Key Press' => sub
{
    my( $keyNum ) = @{ $_[0] };

    if( defined $keyNum
        and $keyNum != 65293
        and plugin_pref_get 'nowTyping'
        and not $enable
        and context_info->{ type } == 2 or context_info->{ type } == 3 )
    {
        $enable = 1;
        command( 'ME is typing...');
    }
    elsif( $keyNum == 65293 )
    { $enable = 0; }

    return EAT_NONE;
};

hook_command 'NOWTYPING' => sub
{
    plugin_pref_set 'nowTyping', @{ $_[0] }[1];
    return EAT_HEXCHAT;
},
{ help_text =>
    "Enable and disable the now playing feature\n"
    . "Set to 1 to enable and 0 to disable"
};

register(
    'Now typing',
    0X02,
    'Notify a channel/PM that you are typing'
);
