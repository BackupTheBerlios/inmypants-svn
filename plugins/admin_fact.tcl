# IMP: admin plugin file for facts

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

proc IMP_plugin_admin_fact { handle idx { arg "" }} {

  global IMPFacts

  #fact show <type> <name>
  if [regexp -nocase {show ([^ ]+) ([^ ]+)} $arg matches t name] {
    set known $IMPFacts($t,$name)
    putidx $idx "Known '$t' facts about: $name"
    set count 0
    foreach fact $known {
      putidx $idx "$count: $fact"
      incr count
    }
    return 0
  }

  #status
  if [regexp -nocase {status} $arg] {
    set items [lsort [array names IMPFacts]]
    set itemcount 0
    set factcount 0
    putidx $idx "Known facts:"
    foreach item $items {
      putidx $idx "$item ([llength $IMPFacts($item)])"
      incr itemcount
      incr factcount [llength $IMPFacts($item)]
    }
    putidx $idx "Total: $factcount facts about $itemcount items"
    return 0
  }

  #all else fails, list help
  putidx $idx ".impadmin fact \[show|status\]\r"
  return 0
}

# register the plugin
IMP_plugin_add_admin "fact" "^fact" n "IMP_plugin_admin_fact" "any"
