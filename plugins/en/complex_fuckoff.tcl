## IMP plugin: fuck off

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

IMP_plugin_add_complex "fuckoff" "^fuck off,?;? %botnicks" 90 IMP_plugin_complex_fuckoff "en"
IMP_plugin_add_complex "fuckyou" "fuck you" 100 IMP_plugin_complex_fuckyou "en"

proc IMP_plugin_complex_fuckoff { nick host handle channel text } {
  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{fuckOffs}"
  puthelp "NOTICE $nick :If you want me to shut up, tell me to shut up|be quiet|go away in a channel."
  IMPGetLonely
  IMPGetSad
  driftFriendship $nick -3
  return 1
}

proc IMP_plugin_complex_fuckyou { nick host handle channel text } {
  if {![IMPTalkingToMe $text]} { return 0 }
  IMPDoAction $channel "" "%VAR{fuckYous}"
  IMPGetLonely
  IMPGetSad
  driftFriendship $nick -3
  return 1

}

IMP_abstract_register "fuckYous"
IMP_abstract_batchadd "fuckYous" [list "stfu" "shut up, you %VAR{PROM}" "eh fuck you buddy" "lalala not listening"]
