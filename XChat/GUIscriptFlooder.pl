#     File: GUIscriptflooder.pl
# Language: Perl
#  Version: 1
#
#  Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Description: A simple script to flood the scripts and plugins GUI with random scripts
#
#       Usage: /GUISCRIPTFLOODER
#               Change the NUMBER constant below to the number of scripts to add to the GUI
#
# NOTE: A deletion method isn't integrated and a restart is required to clear the GUI list
#       This serves no purpose to an average user and was only developed for testing another script
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
###################################################################################################

use strict;
use warnings;
use Xchat qw( :all );

use constant NUMBER => 4;

hook_command
(
    'GUISCRIPTFLOODER', sub
    {
        #-Must start at 1 or else NaN is listed in the GUI
        for my $number ( 1 .. NUMBER )
        {
            Xchat::Internal::register( name(), $number, name(), name() );
        }
        return EAT_XCHAT;
    },
    {
        help_text => "/GUISCRIPTFLOODER"
    }
);

sub name
{
    my @a = ( 'a'..'z', 'A'..'Z', 0..9 );
    return join '' => map $a[rand @a], 1..10;
}

register
(
    'Script GUI flooder',
    0x01,
    'Flood the "Plugins and Scripts" GUI with random scripts',
    undef
);