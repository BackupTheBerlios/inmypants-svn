## IMP plugin: sleeps

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

IMP_plugin_add_action_complex "sleeps" "^(falls asleep on|dozes off on|snoozes on|sleeps on) %botnicks" 100 IMP_plugin_complex_action_sleeps "en"

proc IMP_plugin_complex_action_sleeps { nick host handle channel text } {
  if [IMPLike $nick $host] {
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{rarrs}"
    IMPGetHorny
    IMPGetHappy
    IMPGetUnLonely
    driftFriendship $nick 1
  } else {
    frightened $nick $channel
    IMPGetUnHappy
    driftFriendship $nick -1
  }
  return 1
}
