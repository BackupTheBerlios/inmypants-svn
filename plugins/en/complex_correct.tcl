## IMP: correct common english errors by other people

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

IMP_plugin_add_complex "correct-of" "(must|should) of" 30 IMP_plugin_complex_correct "en"

proc IMP_plugin_complex_correct { nick host handle channel text } {
  #if {![IMP_interbot_me_next $channel]} { return 0 }

  if [regexp -nocase "(must|should) of" $text matches nnk] {
    IMPDoAction $channel $nnk "%VAR{shouldhaves}"
    return 1
  }
}

set shouldhaves {
  "\"%% have\" %VAR{smiles}"
  "%% what?"
  "%% HAVE, %% HAVE"
  "s/of/have/"
}
