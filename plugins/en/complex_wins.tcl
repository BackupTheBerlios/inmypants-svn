###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_plugin_add_complex "wins" "^${botnicks}(:?) (wins|exactly|precisely|perfect|nice one)" 100 IMP_plugin_complex_wins "en"

proc IMP_plugins_complex_wins { nick host handle channel text } {
  if [regexp -nocase "^${botnicks}(:?) (wins|exactly|precisely|perfect|nice one)\.?!?$" $text] {
    IMPDoAction $channel $nick "%VAR{notopic says yarrrrYARRRR bibble squeak. give me a welshman to nibble on"
    IMPGetHappy
    IMPGetUnLonely
    driftFriendship $nick 1
    return 0
  }
}
