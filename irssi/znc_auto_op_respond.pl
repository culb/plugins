use strict;
use warnings;
use Digest::MD5 qw( md5_hex );
use Irssi qw( signal_add );

our $VERSION = 1;
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
    my( $me, $challenge ) = $data =~ /^(\S+)\s{1}:!ZNCAO\s{1}CHALLENGE\s{1}(.+)$/;

    $server->command(   'NOTICE ' . $nick . ' !ZNCAO RESPONSE '
                      . md5_hex( 'PASSWORD_GOES_HERE' . "::" . $challenge ) );
};
