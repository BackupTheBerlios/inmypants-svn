## IMP simple plugins for taunting !list morons

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


IMP_plugin_add_simple "list-1" {^ftp\?\? } 100 "%VAR{list1}" "en"
IMP_plugin_add_simple "list-2" {^\?msg %botnicks ftp} 100 "%VAR{list2}" "en"


# abstracts
set list1 {
  "No. Try \002/msg NoTopic ftp?? ...\002 instead of saying it in the channel. Sheesh."
}

set list2 {
  "Heh, idiot."
  "Fool."
}
