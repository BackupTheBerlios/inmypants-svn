## IMP plugin: sits

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

IMP_plugin_add_action_complex "sits" "^sits on %botnicks" 100 IMP_plugin_complex_action_sits "en"

proc IMP_plugin_complex_action_sits { nick host handle channel text } {
  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{satOns}"
  IMPGetSad
  IMPGetUnLonely
  driftFriendship $nick -1
  return 1
}
