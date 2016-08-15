# Author: culb (nightfrog)
# Version: 1
# Description: Command to clear ACT of activity

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

command_bind 'unact' => sub
{
    my $active = active_win()->{refnum};
    for my $window ( windows() )
    {
        command( 'window goto ' . $window->{refnum} );
    }
    command( 'window goto ' . $active );
};
