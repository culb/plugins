############################################
# File: gotoall.pl
# Language: Perl
# Version: 0
# Author: culb (nightfrog)
# Contact: the01culb[at]gmail[dot]com
# Usage: /GTA
# Purpose: Clear activities from all buffers
############################################

use strict;
use warnings;

weechat::register 'go_to_all', 'culb (nightfrog)', 0x0, 'BSD',
                  'Clear activities from all buffers', '', '';

weechat::hook_command 'GTA', 'Go to all', '',
                      'Clear activities from all buffers', '', 'go_to_all', '';

sub command{ weechat::command @_ }
sub infolist_get{ weechat::infolist_get @_ }
sub infolist_free{ weechat::infolist_free @_ }
sub infolist_next{ weechat::infolist_next @_ }
sub infolist_string{ weechat::infolist_string @_ }
sub buffer_get_integer{ weechat::buffer_get_integer @_ }
sub WEECHAT_RC_OK{ weechat::WEECHAT_RC_OK }

my %W = (
    prnt  => sub{ weechat::print @_ },
    RC_OK => sub{ weechat::WEECHAT_RC_OK },
    current_buffer => sub{ weechat::current_buffer }
);

sub get_buffers
{
    my @buffers;
    my $infoList = infolist_get 'buffer', '', '';
    while( infolist_next $infoList )
    {
        # Use names instead of numbers so multiple server buffers are affected
        my $absolutePath = infolist_string $infoList, 'name';
        push @buffers, $absolutePath if $absolutePath;
    };
    infolist_free $infoList;
    return \@buffers;
}

sub go_to_all
{
    my $currentBuffer = buffer_get_integer $W{ current_buffer }(), 'number';
#    $W{ prnt }( '', $currentBuffer );
    command '', '/BUFFER ' . $_  for @{ get_buffers() };
    command '', '/BUFFER ' . $currentBuffer;# Return to the original buffer
    return $W{ RC_OK };
}
