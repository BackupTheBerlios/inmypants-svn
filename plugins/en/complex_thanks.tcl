## IMP plugin: thanks
#

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

IMP_plugin_add_complex "thanks" "^(thank(s|z|x)|thankyou|thank you|thx|thanx|ta|cheers|merki|merci) %botnicks" 100 IMP_plugin_complex_thanks "en"

proc IMP_plugin_complex_thanks { nick host handle channel text } {
  global IMPCache
  #need to have done something for this user recently
  #if {![regexp -nocase $nick $IMPCache(lastDoneFor)]} {return 0}
  #set IMPCache(lastDoneFor) ""

  #IMP_putloglev d * "IMP: Thanked by $nick on $channel"
  IMPDoAction $channel $nick "%VAR{welcomes}"
  IMPGetHappy
  driftFriendship $nick 3
  return 1
}
