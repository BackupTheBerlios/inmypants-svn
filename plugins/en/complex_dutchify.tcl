# $Id: complex_dutchify.tcl,v 1.3 2003/01/25 12:27:42 sabre2th Exp $
#

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

proc IMP_plugin_complex_dutchify {nick host handle channel text} {
  IMPDoAction $channel $nick "$nick: [IMP_module_extra_dutchify $text]"
}

IMP_plugin_add_complex "dutchify" "^!nl" 100 "IMP_plugin_complex_dutchify" "en"
