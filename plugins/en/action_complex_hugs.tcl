## IMP plugin: hugs
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

IMP_plugin_add_action_complex "hugs" "^(hugs|snuggles|huggles|knuffelt) %botnicks" 100 IMP_plugin_complex_action_hugs "en"

proc IMP_plugin_complex_action_hugs { nick host handle channel text } {  
  IMPGetUnLonely
  IMPGetHappy
  if [IMPLike $nick $host] {
    IMPDoAction $channel "" "%VAR{rarrs}"
    driftFriendship $nick 3
    IMPGetHorny
  } else {
    IMPDoAction $channel "" "%VAR{smiles}"
    driftFriendship $nick 2
  }
  return 1
}
