use strict;
use warnings;
use Digest::MD5 qw( md5_hex );
use Irssi qw( signal_add );

our $VERSION = 2;
our %IRSSI = (
    authors     => 'culb (nightfrog)',
    contact     => 'the01culb@gmail.com',
    name        => 'ZNC auto op responder',
    description => 'Respond to the ZNC auto op module',
    license     =>   'If this code is used in any way then be courteous'
                   . 'and include all of my information and notes' );

signal_add 'event notice' => sub
{
    my( $server, $data, $nick, $address ) = @_;
    my( $me, $challenge ) = $data =~
        /^(\S+)\s{1}:!ZNCAO\s{1}CHALLENGE\s{1}([\x21\x3F\x2E\x2C\x3A\x3B\x2F\x2A\x2D\x2B\x28\x29\w]{32})$/;

    $server->command(   'NOTICE ' . $nick . ' !ZNCAO RESPONSE '
                      . md5_hex( 'PASSWORD_GOES_HERE' . "::" . $challenge ) );
};
