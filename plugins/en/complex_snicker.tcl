## IMP plugin: snickers

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

IMP_plugin_add_complex "snicker" "\\\*snickers?\\\*" 50 IMP_plugin_complex_snickers "en"

proc IMP_plugin_complex_snickers { nick host handle channel text } {
  if [regexp -nocase "\\\*snicker(s)?\\\*" $text ming pop] {
    IMPDoAction $channel "" "*%VAR{chocolates}$pop*"
    return 1
  }
}
