## IMP plugin: sucks

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

IMP_plugin_add_complex "sucks" {sucks?$} 30 IMP_plugin_complex_sucks "en"

proc IMP_plugin_complex_sucks { nick host handle channel text } {
  if [regexp -nocase {([^ ]+) ((is|si|==) (teh|the)? )?sucks?} $text matches item] {
    if {$item == "=="} {
      return 0
    }
    IMPDoAction $channel $item "%VAR{sucks}"
  }
}

IMP_abstract_register "sucks"
IMP_abstract_add "sucks" "%% = %VAR{PROM}"

