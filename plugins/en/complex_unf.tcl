## IMP plugin: uNF

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

IMP_plugin_add_complex "unf" "((~(rarr|oof|unf)~)|unf|lick(s)?) %botnicks" 100 IMP_plugin_complex_unf "en"
  
proc IMP_plugin_complex_unf { nick host handle channel text } {
  IMPGetHorny
  return 1
}
