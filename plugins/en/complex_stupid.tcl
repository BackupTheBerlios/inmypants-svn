## IMP plugin: stupid bots

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

IMP_plugin_add_complex "stupid" "(stupid|idiot|imbecile|incompetent|loser|luser) bot" 100 IMP_plugin_complex_stupid "en"

proc IMP_plugin_complex_stupid { nick host handle channel text } {
  global botnicks
  if {[regexp -nocase "(stupid|idiot|imbecile|incompetent|loser|luser)( bot)?" $text] && [regexp -nocase $botnicks $text]} {
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{stupidReplies}"
    IMPGetSad
    driftFriendship $nick -5
    return 0
  }
}
