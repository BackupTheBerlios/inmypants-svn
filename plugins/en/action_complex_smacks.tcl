## IMP plugin: smacks

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

IMP_plugin_add_action_complex "smacks" "^attacks %botnicks" 100 IMP_plugin_complex_action_smacks "en"

proc IMP_plugin_complex_action_smacks { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "(kicks|smacks|twats|injures|beats up|punches|hits|thwaps|slaps|pokes|kills|destroys) ${botnicks}" $text] {
    IMPGetUnHappy
    IMPGetUnLonely
    driftFriendship $nick -2
    if [rand 2] {
      frightened $nick $dest
      return 1
    }
    IMPDoAction $dest $nick "/%VAR{smacks} %% back with %VAR{sillyThings}"
    return 1
  }
}
