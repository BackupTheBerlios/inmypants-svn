## IMP plugin: pinch

###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_plugin_add_action_complex "pinch" "^(steals|pinches|theives|removes) %botnicks'?s .+" 100 IMP_plugin_complex_action_pinch "en"

proc IMP_plugin_complex_action_pinch { nick host handle channel text } {  
  global botnicks
  if [regexp -nocase "(steals|pinches|theives|removes|takes) ${botnicks}'?s (.+)" $text matches action object] {
    # TODO: check $object and $action (e.g. pinches arse)
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{stolens}"
    IMPGetSad
    # TODO: switch to using plugin settings for this
    set IMPCache(lastEvil) $nick
    driftFriendship $nick -1
    return 1
  }
}
