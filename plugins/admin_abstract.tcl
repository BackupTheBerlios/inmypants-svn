# IMP: admin plugin file for abstracts

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

proc IMP_plugin_admin_abstract { handle idx { arg "" }} {

  #abstract show <name>
  if [regexp -nocase {show ([^ ]+)} $arg matches name] {
    set result [IMP_abstract_all $name]
    putidx $idx "Abstract $name has [llength $result] items.\r"
    set i 0
    foreach a $result {
      putidx $idx "$i: $a"
      incr i
    }
    return 0
  }

  #abstract gc
  if [regexp -nocase {gc} $arg matches] {
    putidx $idx "Garbage collecting...\r"
    IMP_abstract_gc
    return 0
  }


  #status
  if [regexp -nocase {status} $arg] {
    global IMP_abstract_contents IMP_abstract_timestamps IMP_abstract_max_age
    global IMP_abstract_ondisk

    set mem 0
    set disk 0

    set handles [array names IMP_abstract_contents]
    putidx $idx "IMP abstract info info:\r"
    foreach handle $handles {      
      set diff [expr [clock seconds]- $IMP_abstract_timestamps($handle)]
      putidx $idx "$handle: [llength [IMP_abstract_all $handle]] items, $diff seconds since used"
      incr mem
    }
    foreach handle $IMP_abstract_ondisk {
      putidx $idx "$handle: on disk"
      incr disk
    }
    putidx $idx "[expr $mem + $disk] total abstracts, $mem loaded, $disk on disk"
    return 0
  }

  if [regexp -nocase {info (.+)} $arg matches name] {
    set result [IMP_abstract_all $name]
    putidx $idx "Abstract $name has [llength $result] items.\r"
    return 0
  }

  if [regexp -nocase {delete (.+) (.+)} $arg matches name index] {
    putidx $idx "Deleting element $index from abstract $name...\r"
    IMP_abstract_delete $name $index
    return 0
  }

  #all else fails, list help
  putidx $idx ".impadmin abstract \[show|gc|status\]\r"
  return 0
}

# register the plugin
IMP_plugin_add_admin "abstract" "^abstract" n "IMP_plugin_admin_abstract" "any"
