# IMP plugin: colen$(£&$

###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_plugin_add_complex "colen" {^[!\"£\$%\^&\*\(\)\@\#]{3,}} 40 IMP_plugin_complex_colen "all"

proc IMP_plugin_complex_colen { nick host handle channel text } {
  if [regexp "^\*\*\*" $text] {
    return 0
  }
  if [IMP_interbot_me_next $channel] {
    IMPDoAction $channel $nick [IMPGetColenChars]
  }
  return 1
}

