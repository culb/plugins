-- File: gotoall.lua
-- Language: Lua
-- Version: 1
--
-- Author: culb( nightfrog )
-- Contact: the01culb[at]protonmail[dot]com
--
-- Description: Clear the server list of activity
-- Usage: /GTA
--
-- License: If this code is used in any way
--          then be courteous and include all of my information and notes
-------------------------------------------------------------------------

hexchat.register( 'Go To All', 0x01, 'Clear the server list of activity' )

hexchat.hook_command( 'GTA', function()

    for channel in hexchat.iterate( 'channels' ) do
        channel.context:command( 'GUI COLOR 0' )
    end

    return hexchat.EAT_ALL
end, 'Usage: GTA, Clear the server list(servers and channels) of activity' )
