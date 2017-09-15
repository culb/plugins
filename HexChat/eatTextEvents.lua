-- File: eatTextEvents.lua
-- Language: Lua
-- Version: 0
--
-- Author: culb( nightfrog )
-- Contact: the01culb[at]protonmail[dot]com
--
-- Description: A simple script to hide events from showing
-- Usage: Add the events to hide in the for loop where 'Text events N' are
--
-- License: If this code is used in any way
--          then be courteous and include all of my information and notes
--------------------------------------------------------------------------

hexchat.register( 'Eat Events', '0', 'Eat events' )

for _, event in ipairs({ 'Text event 0',
                         'Text event 1',
                         'Text event 2' }) do
    hexchat.hook_print( event, function (args)
        return hexchat.EAT_HEXCHAT
    end)
end
