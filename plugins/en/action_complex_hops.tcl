## IMP plugin: hops

###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_plugin_add_action_complex "hops" "^hops (in|on)to %botnicks'?s lap" 100 IMP_plugin_complex_action_hops "en"

proc IMP_plugin_complex_action_makes { nick host handle channel text } {
  if [IMPLike $nick $host] {
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{rarrs}"
    IMPGetHorny
    IMPGetHappy
    IMPGetUnLonely
    driftFriendship $nick 1
  } else {
    frightened $nick $channel
    driftFriendship $nick -1
  }
  return 1
}
