## IMP plugin: balefires

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

IMP_plugin_add_action_complex "balefires" "^balefires" 100 IMP_plugin_complex_action_balefires "en"

proc IMP_plugin_complex_action_balefires { nick host handle channel text } {  
  if [regexp -nocase "^balefires (.+)" $text ming who] {
    global IMPInfo
    if [regexp -nocase $botnicks $who] {
      IMPDoAction $dest $nick "%VAR{balefired}"
      IMPGetUnLonely
      IMPGetUnHappy
      driftFriendship $nick -1
    } else {
      if {![onchan $who $dest]} { return 0 }
      if {$IMPInfo(balefire) != 1} { return 0 }
      putserv "PRIVMSG $who :Sorry, you stopped existing a few minutes ago. Please sit down and be quiet until you are woven into the pattern again."
    }
    return 1
  }
}
