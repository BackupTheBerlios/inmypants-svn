## IMP plugin: hides

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

IMP_plugin_add_action_complex "hides" "^hides behind %botnicks" 90 IMP_plugin_complex_action_hides "en"

proc IMP_plugin_complex_action_hides { nick host handle channel text } {
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{hiddenBehinds}"
    IMPGetUnLonely
    IMPGetHappy
    return 1
  }
}
