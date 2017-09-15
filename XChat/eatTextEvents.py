# File: eatTextEvents.py
# Language: Python
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

import xchat

__module_name__ = 'Eat Events'
__module_author__ = 'culb (nightfrog)'
__module_version__ = '0'
__module_description__ = 'Eat Events'

def event_cb( word, word_eol, userdata ):
    return xchat.EAT_XCHAT

for event in ( 'Text event 0',
               'Text event 1',
               'Text event 2' ):
    xchat.hook_print( event, event_cb )
