## IMP plugin: watch out

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

IMP_plugin_add_complex "watchout" "^%botnicks,?:? (watch out|watch it|careful|run( for (it|the hills))?|hide|duck)!?" 100 IMP_plugin_complex_watchout "en"

proc IMP_plugin_complex_watchout { nick host handle channel text } {
  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{hides}"
  IMPGetUnLonely
  driftFriendship $nick 2
  return 0
}
