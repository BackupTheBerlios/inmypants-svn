## IMP plugin: bhar (etc)

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

IMP_plugin_add_complex "woot" {^[a-zA-Z0-9]+[!1~]+$} 5 IMP_plugin_complex_woot "en"

proc IMP_plugin_complex_woot { nick host handle channel text } {
  if [regexp {^([a-zA-Z0-9]+)[!1~]+$} $text matches word] {
    IMPDoAction $channel $word "%VAR{woots}"
  }
}

set woots {
  "i like %%"
  "\\o/"
  "%REPEAT{3:7} %%"
  "\\o/ %%"
  "hurrah"
  "wh%REPEAT{3:7:e} %%"
  "%VAR{smiles}"
}
