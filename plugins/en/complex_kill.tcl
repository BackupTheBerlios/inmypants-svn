## IMP plugin: kill

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

IMP_plugin_add_complex "kill" "%botnicks,?:? (please )?(kill|destroy|detonate|terminate) " 100 IMP_plugin_complex_kill "en"

proc IMP_plugin_complex_kill { nick host handle channel text } {
  global botnicks
  if {[regexp -nocase "^${botnicks},?:? (please )?(kill|destroy|detonate|terminate) (.+)" $text ming ming2 frogs pop details]} {
    set who [string trim [string range $details 0 [string first " " $details]]]
    if {$who == ""} { set who $details }
    global kills
    if [regexp -nocase "with (.+)" $details ming1 weapon] {
      IMPDoAction $channel $who "/kills $who with $weapon"
      return 1
    }
    global kills
    IMPDoAction $channel $who "%VAR{kills}"
    return 1
  }
}
