## IMP plugin: xmas

###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2004
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_plugin_add_complex "xmas" "(merry|happy|have a good) (xmas|christmas|chrismas|newyear|new year) %botnicks" 100 IMP_plugin_complex_xmas "en"

proc IMP_plugin_complex_xmas { nick host handle channel text } {
  IMPGetHappy
  IMPGetUnLonely
  IMPDoAction $channel [IMPGetRealName $nick $host] "merry christmas and happy new year %% %VAR{smiles}"
  driftFriendship $nick 3
  return 1
}
