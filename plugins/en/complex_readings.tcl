## IMP plugin: readings

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

IMP_plugin_add_complex "st-readings" "%botnicks:?,? activate (.+) (detectors?|sensors?)!?$" 100 IMP_plugin_complex_readings "en"

proc IMP_plugin_complex_readings { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "${botnicks}:?,? activate (.+) (detectors?|sensors?)!?$" $text ming bhar reading] {
    set readingLevel [rand 101]
    IMPDoAction $channel $channel "%VAR{readings_scan}"
    set reading "[string toupper [string range $reading 0 0]][string range $reading 1 end]"
    IMP_plugins_settings_set "complex:readings" "reading" "reading" "" $reading
    IMPDoAction $channel $nick "%VAR{readings_result}"
    IMPGetUnLonely
    return 1
  }
}

set readings_scan {
  "/scans %%"
  "/analyses %%"
  "/checks %%"
  "/waves tricorder around a bit"
  "/looks at %ruser"
}

set readings_result {
  "%%: That reads as %NUMBER{10000} %VAR{units}."
  "%SETTING{complex:readings:reading:reading:_} levels of %NUMBER{101} percent detected."
}
