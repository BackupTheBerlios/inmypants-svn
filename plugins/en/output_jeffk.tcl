## IMP output plugin: jeffk
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

IMP_plugin_add_output "jeffk" IMP_plugin_output_jeffk 0 "en"

proc IMP_plugin_output_jeffk { channel line } {

  return [IMP_module_extra_jeffk $line]
}
