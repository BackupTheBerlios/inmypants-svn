## IMP plugin: hnnn
#
# $Id: simple_hnn.tcl,v 1.1 2004/01/03 18:35:51 jamesoff Exp $
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

IMP_plugin_add_simple "hnnn" "^hn{3,}" 70 [list "%VAR{blindings}"]
