# IMP complex plugin: smiley

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

IMP_plugin_add_complex "smiley" {^[;:=]-?[)D>]$} 40 IMP_plugin_complex_smiley "all"
IMP_plugin_add_complex "smiley2" {^([\-^])_*[\-^];*$} 40 IMP_plugin_complex_smiley "all"
IMP_plugin_add_complex "smiley4" {^%botnicks [;:=]-?[)D>]$} 80 IMP_plugin_complex_smiley2 "all"
IMP_plugin_add_complex "smiley5" {^%botnicks ([\-^])_*[\-^];*$} 80 IMP_plugin_complex_smiley2 "all"
IMP_plugin_add_complex "smiley3" {^heh(ehe?)*$} 30 IMP_plugin_complex_smiley "all"

proc IMP_plugin_complex_smiley { nick host handle channel text } {
  global mood
  global IMPCache

  if {![IMP_interbot_me_next $channel]} { return 0 }

  if {$IMPCache(lastPlugin) == "IMP_plugin_complex_smiley"} {
    return 0
  }

  if {$mood(happy) < 0} {
    return 0
  }

  IMPDoAction $channel "" "%VAR{smiles}"
  IMPGetHappy
  IMPGetUnLonely
  return 1
}

proc IMP_plugin_complex_smiley2 { nick host handle channel text } {
  global mood

  if {![IMP_interbot_me_next $channel]} { return 0 }

  if {$mood(happy) < 0} {
    return 0
  }

  IMPDoAction $channel "" "%VAR{smiles}"
  IMPGetHappy
  IMPGetUnLonely
  return 1
}
