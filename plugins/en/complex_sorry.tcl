## IMP plugin: sorry

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

IMP_plugin_add_complex "sorry1" "(i'm)?( )?(very)?( )?sorry(,)? %botnicks" 100 IMP_plugin_complex_sorry "en"
IMP_plugin_add_complex "sorry2" "%botnicks:? sorry" 100 IMP_plugin_complex_sorry "en"

proc IMP_plugin_complex_sorry { nick host handle channel text } {
  global IMPCache
  #user needs to have been evil recently
  if {![regexp -nocase $nick $IMPCache(lastEvil)]} {return 0}
  set IMPCache(lastEvil) ""
  #IMP_putloglev d * "IMP: Apologised to by $nick on $channel"
  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{sorryok} %%"
  IMPGetHappy
  IMPGetUnLonely
  driftFriendship $nick 3
  return 1
}
