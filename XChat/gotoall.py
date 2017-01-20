# File: gotoall.py
# Language: Python
#
# Author: culb (nightfrog)
# Contact: the01culb@gmail.com
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
########################################################################


__module_name__ = 'Go to All'
__module_author__ = 'culb'
__module_version__ = '1'
__module_description__ = 'Clear the server list of activity'

import xchat

def gotoall( word, word_eol, userdata ):
    for channel in xchat.get_list( 'channels' ):
        channel.context.command( 'GUI COLOR 0' );

    return xchat.EAT_XCHAT
 
xchat.hook_command(
    'GTA',
    gotoall,
    help = 'Usage: GTA, Clear the server list(servers and channels) of activity'
)

