## IMP plugin: inserts
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

IMP_plugin_add_action_complex "insert" "(parks|puts|places|inserts|shoves|sticks) (his|her|a|the|some) (.+) (in|on|up) %botnicks" 100 IMP_plugin_complex_action_inserts "en"

proc IMP_plugin_complex_action_inserts { nick host handle channel text } {
  #parks/puts
  if [regexp -nocase "(parks|puts|places|inserts|shoves|sticks) (his|her|a|the|some) (.+) (in|on|up) $botnicks" $text ming verb other item] {
    #is it someone we like or are we kinky?
    if {![IMPLike $nick $host] && ![IMP_setting_get "kinky"]} {
        IMPDoAction $channel $nick "%VAR{parkedinsDislike}"
      IMPGetSad
      IMPGetUnLonely
      driftFriendship $nick -1
      return 1
    }

    IMPGetHorny
    IMPGetHappy
    IMPGetUnLonely
    global rarrs lovesits
    set responses [IMP_abstract_get_all "rarrs"]
    set responses [concat $responses [IMP_abstract_get_all "lovesits"]]
    IMPDoAction $channel $nick [pickRandom $responses]
    return 1
  }
}
