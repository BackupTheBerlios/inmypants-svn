## IMP plugin: makes
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

IMP_plugin_add_action_complex "makes" "^makes %botnicks" 100 IMP_plugin_complex_action_makes "en"

proc IMP_plugin_complex_action_makes { nick host handle channel text } {
  if [regexp -nocase "makes $botnicks (.+)" $text ming ming2 details] {
    global IMPInfo

    if {![IMPLike $nick $host]} {
      frightened $nick $dest
      return 1
    }

    if [regexp -nocase "(come|cum)" $details] {
      if {![IMPLike $nick $host]} {
        frightened $nick $dest
        driftFriendship $nick -2
        return 1
      }

      if {$IMPInfo(gender) == "male"} {
        IMPDoAction $dest $nick "/cums over %%"
        IMPDoAction $dest $nick "ahhh... thanks, I needed that"
        IMPGetHappy
        IMPGetHappy
        IMPGetUnHorny
        driftFriendship $nick 2
        return 1
      }
      # female
      IMPDoAction $dest $nick "%VAR{lovesits} :D"
      IMPGetHappy
      IMPGetHappy
      IMPGetHorny
      driftFriendship $nick 2
      return 1
    }
  }
}
