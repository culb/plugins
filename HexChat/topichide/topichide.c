/*\
 * Hide Topic plugin for HexChat
 * Author: culb ( nightfrog )
\*/

#include "hexchat-plugin.h"

static hexchat_plugin *ph;

static char name[]    = "Hide Topic";
static char desc[]    = "Hide the topic when you join a channel";
static char version[] = "01";

static hexchat_hook *hookTopic;
static hexchat_hook *hookTopicCreation;

static int
topic_cb( char *word[], void *userdata )
{
	hexchat_unhook( ph, hookTopic );
	hookTopic = NULL;
	return HEXCHAT_EAT_HEXCHAT;
}

static int
topic_creation_cb( char *word[], void *userdata )
{
	hexchat_unhook( ph, hookTopicCreation );
	hookTopicCreation = NULL;
	return HEXCHAT_EAT_HEXCHAT;
}

static int
you_join_cb( char *word[], void *userdata )
{
	hookTopic = hexchat_hook_print( ph, "Topic", HEXCHAT_PRI_NORM, topic_cb, NULL );
	hookTopicCreation = hexchat_hook_print( ph, "Topic Creation", HEXCHAT_PRI_NORM, topic_creation_cb, NULL );
	return HEXCHAT_EAT_HEXCHAT;
}

int
hexchat_plugin_init( hexchat_plugin *plugin_handle, char **plugin_name, char **plugin_desc, char **plugin_version, char *arg )
{
	ph = plugin_handle;
	*plugin_name    = name;
	*plugin_desc    = desc;
	*plugin_version = version;

	hexchat_hook_print( ph, "You Join", HEXCHAT_PRI_NORM, you_join_cb, NULL );
	return 1;
}

