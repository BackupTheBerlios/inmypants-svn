## IMP output plugin: pinky
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


proc IMP_plugin_output_pinky { channel line } {
  if {([string length $line] > 10) && ([rand 100] > 97)} {
    set line [string trim $line]
    if {![regexp {[.!?]$} $line]} {
      append line "."
    }
    append line " %VAR{narfs}"

    set line [IMPDoInterpolation $line "" "" $channel]
  }
  return $line
}

set narfs {
  "zort!"
  "narf"
  "poit."
  "poit!"
  "narf!"
}

IMP_plugin_add_output "pinky" IMP_plugin_output_pinky 1 "all"
