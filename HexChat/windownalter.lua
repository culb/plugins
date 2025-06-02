--     File: windownalter.lua
-- Language: Lua
--   Author: culb( nightfrog )
--  Contact: the01culb[at]protonmail[dot]com
--
-- Reference: https://developer.gnome.org/gtk2/stable/GtkWindow.html
--
-- Known issues: When using <move down|up>, there are issues positioning when the window isn't maximized
--               I didn't spend time figuring out how to solve it.
--               All commands where designed to work from a maximized window state
--
-- Note: HexChat has a /GUI command that already has some of these commands
--
-- License: If this code is used in any way
--          then be courteous and include all of my information and notes
--------------------------------------------------------------------------------------------------------

local Gtk = require( 'lgi' ).require( 'Gtk', '2.0' )

hexchat.register( 'Windowalter', 0x133C5F2, 'Manipulate the GUI from commands' )

local usage =[[
Usage: WIN <min|max|fs|unfs|resize>

       WIN min , Minimize window
       WIN max , Maximize window
       WIN fs  , Fullscreen window
       WIN unfs, Unfullscreen window
       WIN resize WxH, Resize window widthXheight
       WIN move up|down|left|right, Move window to different area
]]

hexchat.hook_command( 'WIN', function( word )

    if not word[2] then
        hexchat.print( usage )
        return hexchat.EAT_HEXCHAT
    else
        name = string.lower( word[2] )
        window = Gtk.Window( hexchat.get_info( 'gtkwin_ptr' ) )
    end

    if name == 'min' then

        if window:get_window():is_visible() then
            window:iconify()
        else
            -- Will never see this unless called from another script while HexChat is minimized
            hexchat.print( 'HexChat is already minimized' )
        end

    elseif name == 'max' then

        if not window:get_window():get_state()['MAXIMIZED'] then
            window:maximize()
        else
            hexchat.print( 'HexChat is already maximized' )
        end

    elseif name == 'fs' then

        if not window:get_window():get_state()['FULLSCREEN'] then
            window:fullscreen()
        else
            hexchat.print( 'HexChat is already fullscreen' )
        end

    elseif name == 'unfs' then

        if window:get_window():get_state()['FULLSCREEN'] then
            window:unfullscreen()
        else
            hexchat.print( 'HexChat is already not fullscreen' )
        end

    elseif name == 'resize' then

        size = word[3]
        if size then
            local width, height = size:match( "(%d+)[x|X](%d+)" )
            if width and height then
                window:resize( width, height )
            else
                hexchat.print( 'Usage: WIN <resize WxH>, Resize widthXheight' )
            end
        else
            hexchat.print( 'Usage: WIN <resize WxH>, Resize widthXheight' )
        end

    elseif name == 'flash' then

        window:set_urgency_hint( 1 )

    elseif name == 'move' then

        if word[3] then

            window:maximize()-- ???
            local direction = string.lower( word[3] )

            if direction == 'left' or direction == 'right' then

                local widthScreen  = window:get_screen():get_width()
                --[[ Tested in Windows and screen height includes the taskbar
                     and using it will cause the move to be behind the taskbar
                     There might be a problem in Unix with X* or Wayland
                     I didn't look into this a lot but there has to be a better way
                     to get the mazimized window size without maximizing the window first --]]                
                local heightWindow  = window:get_window():get_height()

                if direction == 'left' then
                    window:resize( widthScreen / 2, heightWindow )
                    window:move( 0, 0 )                 
                else
                    window:resize( widthScreen / 2, heightWindow )
                    window:move( widthScreen / 2, 0 )
                end

            elseif direction == 'down' or direction == 'up' then

                local widthScreen  = window:get_screen():get_width()
                local heightWindow  = window:get_window():get_height()
 
                if direction == 'down' then
                    window:resize( widthScreen , heightWindow / 2 )
                    window:move( 0, heightWindow / 2 )
                else
                    window:resize( widthScreen, heightWindow )
                    --window:move( width , heightWindow / 2 )
                end

            else
                hexchat.print( 'WIN <move up|down|left|right>' )
            end
        else
            hexchat.print( 'WIN <move up|down|left|right>' )        
        end

    else
        hexchat.print( usage )
    end

    return hexchat.EAT_HEXCHAT
end)
