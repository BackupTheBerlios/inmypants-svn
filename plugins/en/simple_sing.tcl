## IMP simple plugin: sing

###############################################################################
# This is a IMP plugin
# Copyright (C) Dave Wickham 2004
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_plugin_add_simple "sing" "%botnicks,?:? (please )?(sing|sing something|sing a song)" 100 "%VAR{songs}" "en"
