## IMP plugin: away reason learning

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

IMP_plugin_add_action_complex "away-learn" "^(is )?(away|gone)" 50 IMP_plugin_complex_action_away_learn "en"

#make sure this abstract is registered
IMP_abstract_register "randomAways"

proc IMP_plugin_complex_action_away_learn { nick host handle channel text } {
  #autoaway
  if [regexp -nocase {(auto[ -]?away)|idle} $text] {
    #don't want to learn this
    return 0
  }

  if [regexp -nocase {^(is )?(away|gone)[^a-z0-9]*([a-z0-9 ]+)} $text matches skip1 skip2 reason] {
    IMP_putloglev d * "learning away reason: $reason"
    IMP_abstract_add "randomAways" [string tolower $reason]
  }

  return 0
}
