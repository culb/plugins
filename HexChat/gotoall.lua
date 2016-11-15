-- File: gotoall.lua
-- Language: Lua
-- Author: culb (nightfrog)
-- Contact: the01culb@gmail.com
-------------------------------

hexchat.register( 'Go To All', 1, 'Goto all contexts' )

hexchat.hook_command( 'GTA', function()

    for channel in hexchat.iterate( 'channels' ) do
        channel.context:command( 'GUI COLOR 0' )
    end

    return hexchat.EAT_ALL
end, 'Usage: /GTA, Clear the server list(servers and channels) of activity' )
