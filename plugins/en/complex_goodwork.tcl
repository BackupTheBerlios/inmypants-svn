## IMP plugin: good work

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

IMP_plugin_add_complex "goodwork" "^(well done|good(work|show)),? %botnicks\.?$" 100 IMP_plugin_complex_goodwork

proc IMP_plugin_complex_goodwork { nick host handle channel text } {
  IMPDoAction $channel $nick "%VAR{harhars}"
  IMPGetHappy
  IMPGetUnLonely
  driftFriendship $nick 1
  return 1
}
