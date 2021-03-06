## IMP plugin: away handler

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

IMP_plugin_add_action_complex "zzz-failsafe" {^(.+?)s %botnicks} 100 IMP_plugin_complex_action_failsafe "en"

proc IMP_plugin_complex_action_failsafe { nick host handle channel text } {
  regexp {^(.+?)(e?(s)) } $text matches verb ee es
  if {$verb == ""} {
    return 1
  }

  if {$es != ""} {
    if [regexp -nocase {([^aeiouy])$} $verb matches letter] {
      append verb $letter
    }
  }
  IMP_plugins_settings_set "complex:failsafe" "last" "nick" "moo" [IMPGetRealName $nick]
  IMPDoAction $channel $verb "%VAR{failsafes}"
}


IMP_abstract_register "failsafes"
IMP_abstract_batchadd "failsafes" [list "%VAR{rarrs}" "%REPEAT{3:7:m} %%" "%VAR{thanks}" "i do love a good %%ing" "/%%s %SETTING{complex:failsafe:last:nick:moo} back with %VAR{sillyThings}" "what"]
