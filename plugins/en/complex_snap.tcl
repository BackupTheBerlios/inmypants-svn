## IMP plugin: blblbl

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

IMP_plugin_add_complex "snap" "." 100 IMP_plugin_complex_snap "en"

proc IMP_plugin_complex_snap { nick host handle channel text } {
  IMP_flood_undo $nick
  if {[string length $text] < 5} {
    return 0
  }
  if {($text == [IMP_plugins_settings_get "complex:snap" $channel "" "text"]) &&
      ($nick != [IMP_plugins_settings_get "complex:snap" $channel "" "nick"])} {
        if {[IMP_interbot_me_next $channel] && [rand 3]} {
          set othernick [IMP_plugins_settings_get "complex:snap" $channel "" "nick"]
          putlog "othernick = $othernick"
          IMPDoAction $channel $nick "%VAR{snaps}" $othernick
          IMP_plugins_settings_set "complex:snap" $channel "" "text" ""
          IMP_plugins_settings_set "complex:snap" $channel "" "nick" ""
        }
      }
  IMP_plugins_settings_set "complex:snap" $channel "" "text" $text
  IMP_plugins_settings_set "complex:snap" $channel "" "nick" $nick
  return 0
}

IMP_abstract_register "snaps"
IMP_abstract_batchadd "snaps" [list "o snap" "SNAP" "SNAP!" "/wins %% and %2"]
