# File: detachedChanTree.pl
# Language: Perl
# Version: 2
#
# Author:      Khisanth( Lian Wan Situ )
# Modified by: culb( nightfrog )
# Contact:     Khisanth, atmcmnky[at]yahoo[dot]com | culb, the01culb[at]protonmail[dot]com
#
# Description: Create a separate window from Xchat that is identical to the server list 
#
# ChangeLog: 0.0001_01 - Initial Releaase
#                    2 - Support Xchat and HexChat and change the formating
#
# Known Issues: None known 
###########################################################################################

use strict;
use warnings;
use Glib;
use Gtk2 -init;
use Xchat qw( :all );

###   Settings   ###
my $USE_ICONS = 0;
### Settings End ###

my $HEXCHAT;
BEGIN{ $HEXCHAT = HexChat->can( 'register' ) ? 1 : 0; }

my $mainWindow;
register(
    'Detached Chantree',
    0x2,
    'Create a separate window that duplicates the chantree',
    sub{
        if( $mainWindow )
        {
            $mainWindow->destroy;
            undef $mainWindow;
        }
    }
);

use constant
{
    COL_NAME   => 0,
    COL_CHAN   => 1,
    COL_ATTR   => 2,
    COL_PIXBUF => 4
};

initialize();

sub initialize
{
    my $chanTree = get_chan_tree();

    return unless $chanTree;

    $mainWindow = Gtk2::Window->new( 'toplevel' );

    my $treeView = Gtk2::TreeView->new_with_model( $chanTree->get_model );

    my $gui_compact = get_prefs 'gui_compact' if $HEXCHAT;
    my $gui_tweaks  = get_prefs 'gui_tweaks'  if not $HEXCHAT;
	
    my $renderer;
    if( $USE_ICONS )
    {
        $renderer = Gtk2::CellRendererPixBuf->new();
        $renderer->set( 'ypad', 0 ) if $HEXCHAT and $gui_compact;
        $renderer->set( 'ypad', 0 ) if not $HEXCHAT and $gui_tweaks & 32;

        $treeView->insert_column_with_attributes(
            -1, undef, $renderer,
            'pixbuf', COL_PIXBUF,
        );
    }

    $renderer = Gtk2::CellRendererText->new();
    $renderer->set( 'ypad', 0 ) if $HEXCHAT and $gui_compact;
    $renderer->set( 'ypad', 0 ) if not $HEXCHAT and $gui_tweaks & 32;

    $renderer->set_fixed_height_from_font( 1 );
    $treeView->insert_column_with_attributes(
        -1, '', $renderer, 'text',
        COL_NAME, 'attributes', COL_ATTR,
    );

    my $mySelection = $treeView->get_selection();
    my $chanTreeSelection = $chanTree->get_selection();

    $mySelection->signal_connect( 'changed',
        sub{
            my $selection = shift;
            my $selected = $selection->get_selected();
            $chanTreeSelection->select_iter( $selected );
	}
    );

    $mainWindow->add( $treeView );
    $mainWindow->show_all;
}

sub get_ptr
{
    if( $^O ne 'MSWin32' )
    {
        return get_info 'win_ptr';
    }
    else
    {
        my $session    = unpack( 'P1532', pack( 'L', get_context() ) );
        my $guiAddress = unpack( 'x1516L', $session );
        my $guiSession = unpack( 'P232', pack( 'L', $guiAddress ) );
        return unpack( 'x8L', $guiSession );
    }
}

sub get_chan_tree
{
    my $widget = Glib::Object->new_from_pointer( get_ptr() , 0 );

    my @candidates = ($widget);

    while( @candidates )
    {
        my $candidate = shift @candidates;

        next unless $candidate->isa( 'Gtk2::Widget' );
        if( not $HEXCHAT and $candidate->get( 'name' ) eq 'xchat-tree'
            or  $HEXCHAT and $candidate->get( 'name' ) eq 'hexchat-tree')
        {
            return $candidate;
        } 
        elsif( $candidate->isa( 'Gtk2::Container' ) ) 
        {
            push @candidates, $candidate->get_children;
        }
    }
    return;
}

