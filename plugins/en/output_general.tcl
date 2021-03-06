# IMP output plugins

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

#                          name     callback                       enabled at load (1 = yes)
IMP_plugin_add_output  "leet"   IMP_plugin_output_leet     0 "en"

if [IMP_plugin_check_depend "complex:dutchify"] {
  IMP_plugin_add_output  "dutch"  IMP_plugin_output_dutch    0 "en"
}

proc IMP_plugin_output_leet { channel text } {
  return [makeLeet2 $text]
}

proc IMP_plugin_output_dutch { channel text } {
  catch {
    set text [IMP_plugin_complex_dutchify_makeDutch $text]
  }
  return $text
}
