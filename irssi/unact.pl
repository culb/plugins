# File: unact.pl
# Language: Perl
# Version: 1
#
# Author: culb( nightfrog )
# Contact: the01culb[at]protonmail[dot]com
#
# Description: Command to clear ACT of activity
# Usage: /UNACT
#
# License: If this code is used in any way
#          then be courteous and include all of my information and notes
########################################################################

use strict;
use warnings;
use Irssi qw( active_win command command_bind windows );

our $VERSION = 1;
our %IRSSI = (
    authors     => 'culb (nightfrog)',
    contact     => 'the01culb@gmail.com',
    description => 'Command to clear ACT of activity',
    license     => 'BSD'
);

# Prevent errors
{ package Irssi::Nick }

command_bind 'UNACT' => sub
{
    my $active = active_win()->{refnum};
    for my $window ( windows() )
    {
        command( 'window goto ' . $window->{refnum} );
    }
    command( 'window goto ' . $active );
};
