# IMP facts module

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

# maximum number of things about which facts can be known
set IMP_facts_max_items 500

# maximum number of facts to know about an item
set IMP_facts_max_facts 20

# initialise
if {![info exists IMPFacts]} {
  set IMPFacts(what,bmotion) [list "a very nice script"]
}

proc IMP_facts_load { } {
  global IMPFacts IMPModules

  IMP_putloglev 1 * "Attempting to load $IMPModules/facts/facts.txt"

  if {![file exists "$IMPModules/facts/facts.txt"]} {
    return
  }

  set fileHandle [open "$IMPModules/facts/facts.txt" "r"]
  set line [gets $fileHandle]

  set needResave 0
  set count 0

  while {![eof $fileHandle]} {
    if {$line != ""} {
      regexp {([^ ]+) (.+)} $line matches item fact
      if {![info exists IMPFacts($item)]} {
        set IMPFacts($item) [list]
      }
      if {[lsearch -exact $IMPFacts($item) $fact] == -1} {
        lappend IMPFacts($item) $fact
      } else {
        IMP_putloglev 4 * "dropping duplicate fact $fact for item $item"
        set needReSave 1
      }
      
      incr count
      
      if {[expr $count % 1000] == 0} {
        
      putlog "  still loading facts: $count ..."
      
      }
      
    
    }
    set line [gets $fileHandle]
  }

  if {[info exists fileHandle]} {
    close $fileHandle
  }

  if {$needReSave} {
    IMP_facts_save
  }
}

proc IMP_facts_save { } {
  global IMPFacts IMPModules
  global IMP_facts_max_facts
  global IMP_facts_max_items

  set tidy 0
  set tidyfact 0
  set count 0 

  IMP_putloglev 1 * "Saving facts to $IMPModules/facts/facts.txt"

  set fileHandle [open "$IMPModules/facts/facts.txt" "w"]

  set items [array names IMPFacts]
  if {[llength $items] > $IMP_facts_max_items} {
    putlog "Too many items are known ([llength $items] > $IMP_facts_max_items), tidying up"
    set tidy 1
  }
  foreach item $items {
    if {$tidy} {
      if {[rand 100]< 10} {
        #clear array entry
        unset IMPFacts($item)
        incr count
        continue
      }
    }
    if {[llength $IMPFacts($item)] > $IMP_facts_max_facts} {
      set tidyfact 1
    } else {
      set tidyfact 0
    }
    foreach fact $IMPFacts($item) {
      if {$tidyfact} {
        if {[rand 100] < 10} {
          #less critical so we won't waste time trying to delete from memory too :)
          continue
        }
        puts $fileHandle "$item $fact"
      }
    }
  }
  if {$tidy} {
    putlog "$count facts have been forgo.. los... delet... thingy *dribbles*"
  }
  close $fileHandle
}

proc IMP_facts_auto_save { min hr a b c } {
  putlog "IMP: autosaving facts..."
  IMP_facts_save
}

proc IMP_facts_forget_all { fact } {
  global IMPFacts IMPModules

  #drop the array element
  unset IMPFacts($fact)

  #resave to delete
  IMP_facts_save
}

# save facts every hour
bind time - "01 * * * *" IMP_facts_auto_save

# load facts at startup
catch {
  if {$IMP_loading == 1} {
    IMP_putloglev d * "autoloading facts..."
    IMP_facts_load
  }

}


putlog "loaded fact module"
