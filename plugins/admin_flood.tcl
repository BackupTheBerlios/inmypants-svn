# IMP: admin plugin file for flood mangement

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

proc IMP_plugin_admin_flood { handle idx { arg "" }} {
  global IMP_flood_info IMP_flood_last IMP_flood_lasttext IMP_flood_undo
 
  #flood show <handle>
  if [regexp -nocase {show ([^ ]+)} $arg matches handle] {
    putidx $idx "IMP: Flood for $handle is [IMP_flood_get $handle]\r"
    return 0
  }

  #flood set <handle> <n>
  if [regexp -nocase {set ([^ ]+) (.+)} $arg matches handle value] {
    set IMP_flood_info($handle) $value
    putidx $idx "IMP: flood for $handle set to 0\r"
    return 0
  }


  #status
  if [regexp -nocase {status} $arg] {
    set handles [array names IMP_flood_info]
    putidx $idx "IMP: current flood info:\r"
    foreach handle $handles {
      putidx $idx "$handle: [IMP_flood_get $handle]\r"
    }
    return 0
  }

  #all else fails, list help
  putidx $idx ".impadmin flood \[show|set|status\]\r"
  return 0
}

# register the plugin
IMP_plugin_add_admin "flood" "^flood" n "IMP_plugin_admin_flood" "any"
