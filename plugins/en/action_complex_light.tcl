## IMP plugin: light
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

IMP_plugin_add_action_complex "light" "^(lights?|sets fire to) %botnicks" 100 IMP_plugin_complex_action_light "en"

IMP_plugin_add_action_complex "light2" "^sets %botnicks (alight|on fire)" 100 IMP_plugin_complex_action_light "en"

proc IMP_plugin_complex_action_light { nick host handle channel text } {  
  IMPDoAction $channel $nick "%VAR{burns}"
  IMPGetUnLonely
  driftFriendship $nick -1
  return 1
}

set burns {
  "/burns%|%bot[50,¬VAR{extinguishes}]"
  "*flames*%|%bot[50,¬VAR{extinguishes}]"
  "B%REPEAT{2:5:O}M"
  "b%REPEAT{2:5:o}m"
  "BLAM"
  "pop"
  "/goes up in flames%|%bot[50,¬VAR{extinguishes}]"
  "*smoulder*%|%bot[50,¬VAR{extinguishes}]"
  "/explodes"
  "huk"
  "%colen"
  "/torches%|%bot[50,¬VAR{extinguishes}]"
  "/informs the world 'It's time to burn'"
}

set extinguishes {
  "/puts %% out"
  "/pours water on %%"
  "/wraps %% in a fire blanket"
  "/laughs%|%BOT[¬VAR{unsmiles}]"
  "%VAR{shocked}"
  "kaBLAM"
  "taunt"
}

IMP_abstract_register "burns"
IMP_abstract_batchadd "burns" $burns
unset burns

IMP_abstract_register "extinguishes"
IMP_abstract_batchadd "extinguishes" $extinguishes
unset extinguishes
