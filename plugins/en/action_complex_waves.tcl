## IMP plugin: waves
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

IMP_plugin_add_action_complex "waves" "waves (at|to) %botnicks" 100 IMP_plugin_complex_action_waves "en"

proc IMP_plugin_complex_action_waves { nick host handle channel text } {
  set lastGreeted [IMP_plugins_settings_get "complex:wave" "lastGreeted" $channel ""]

  if {$lastGreeted != $handle} {
    IMPDoAction $channel "" "/waves back"
    IMP_plugins_settings_set "complex:wave" "lastGreeted" $channel "" $handle
    IMPGetUnLonely
    driftFriendship $nick 1
  } else {
    if [rand 2] {
      IMPDoAction $channel "" "%VAR{waveTooMuch}"
    }
  }
  return 1
}

IMP_abstract_register "waveTooMuch"
IMP_abstract_batchadd "waveTooMuch" [list "What." "Are you practicing to be the Queen or something?" "..."]
