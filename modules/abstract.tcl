# IMP - Abstract Handling

###############################################################################
# IMP - an 'AI' TCL script for eggdrops
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2003
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or 
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but 
# WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License 
# along with this program; if not, write to the Free Software 
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
###############################################################################

# Summary of new abstract system design:
#
# Abstracts are getting out of control... the amount of information IMP tracks can get silly
# with the whole learning arrangement. The idea behind the new system is that abstracts are stored
# on disk, and loaded into memory when needed, at which point they're loaded into memory.
#
# At some point they're unloaded (i.e. deallocated) out of memory to free up space. This will
# probably be done by deallocating them 5 mins after their last use.
#
# This has important implications for IMP. No longer will abstracts be stored as global-scope
# lists, but in some name-indexed array. Code that directly fetches abstracts (rather than using
# %VAR{}) will fail.
#
# Due to the way the caching will work, abstracts should be fetched through an interface rather than
# directly indexing the array. This interface also means the way abstracts are stored internally can
# be changed later on without affecting the operation of the rest of IMP.
#
# Variables:
#   IMP_abstract_contents: a name-indexed array containing the lists of abstracts
#   IMP_abstract_timestamps: a name-indexed array containing the last access time of an abstract
#                                0 means not cached
#
# Functions:
#   IMP_abstract_register(abstract): register that an abstract should be tracked. A file for it
#                                        if created on disk if needed; if the file exists then the
#                                        contents are loaded
#   IMP_abstract_add(abstract, contents): add an abstract to a list. The change is immediately
#                                             written to disk
#   IMP_abstract_get(abstract): return a random element from the list. The list is transparnetly
#                                   loaded from disk if needed
#   IMP_abstract_gc(): the "garbage collector": unsets any abstracts not used recently
#   IMP_abstract_all(abstract): return the list of all elements from an abstract
#   IMP_abstract_delete(abstract, index): delete from an abstract. The change is immediately
#                                             written to disk
#   IMP_abstract_load(abstract): cache the abstract list in memory from disk
#   IMP_abstract_save(abstract): saves the cached version to disk
#
# Admin plugin to be loaded (but not from this module):
#   !impadmin abstract (add|list|view|del(ete)?|cache|gc) ...
#
# NOTE: This module should be loaded before plugins as they will need it to register abstracts
#
# The abstracts will be stored in ./abstracts/<abstract name>.txt in the IMP directory. The 
# fileformat is simply one per line.

#
set IMP_abstract_max_age 300
set IMP_abstract_max_number 600

# initialise the arrays

if {![info exists IMP_abstract_contents]} {
  set IMP_abstract_contents(dummy) ""
  set IMP_abstract_timestamps(dummy) 1
  set IMP_abstract_ondisk [list]
}

#init our counters
IMP_counter_init "abstracts" "faults"
IMP_counter_init "abstracts" "pageouts"
IMP_counter_init "abstracts" "gc"
IMP_counter_init "abstracts" "gets"

# garbage collect the abstracts arrays
proc IMP_abstract_gc { } {
  global IMP_abstract_contents IMP_abstract_timestamps
  global IMP_abstract_max_age IMP_abstract_ondisk

  IMP_putloglev 2 * "Garbage collecting abstracts..."

  IMP_counter_incr "abstracts" "gc"

  set abstracts [array names IMP_abstract_contents]
  set limit [expr [clock seconds] - $IMP_abstract_max_age]

  set expiredList ""
  set expiredCount 0

  foreach abstract $abstracts {
    if {($IMP_abstract_timestamps($abstract) < $limit) && ($IMP_abstract_timestamps($abstract) > 0)} {
      append expiredList "$abstract "
      incr expiredCount
      unset IMP_abstract_contents($abstract)
      set IMP_abstract_timestamps($abstract) 0
      lappend IMP_abstract_ondisk $abstract
      IMP_counter_incr "abstracts" "pageouts"
    }
  }

  if {$expiredList != ""} {
    IMP_putloglev d * "expired $expiredCount abstracts: $expiredList"
  }

}

proc IMP_abstract_register { abstract } {
  global IMP_abstract_contents IMP_abstract_timestamps
  global IMPModules IMP_testing IMP_loading

  #set timestamp to now
  set IMP_abstract_timestamps($abstract) [clock seconds]

  #load any existing abstracts
  if [file exists "[pwd]/$IMPModules/abstracts/${abstract}.txt"] {
    IMP_abstract_load $abstract
  } else {
    #file doesn't exist - create an empty one
    #create blank array for it
    set IMP_abstract_contents($abstract) [list]
    IMP_putloglev 1 * "Creating new abstract file for $abstract"
    set fileHandle [open "[pwd]/$IMPModules/abstracts/${abstract}.txt" "w"]
    puts $fileHandle " "
  }

  if {[info exists fileHandle]} {
    close $fileHandle
  }  
}

proc IMP_abstract_load { abstract } {
  global IMP_abstract_contents IMP_abstract_timestamps
  global IMPModules IMP_abstract_ondisk
  global IMP_loading IMP_testing

  IMP_putloglev 1 * "Attempting to load $IMPModules/abstracts/${abstract}.txt"

  if {![file exists "$IMPModules/abstracts/${abstract}.txt"]} {
    return
  }

  #create blank array for it
  set IMP_abstract_contents($abstract) [list]

  #set timestamp to now
  set IMP_abstract_timestamps($abstract) [clock seconds]

  if {$IMP_testing} {
    return 0
  }

  #remove from ondisk list
  set index [lsearch -exact $IMP_abstract_ondisk $abstract]
  set IMP_abstract_ondisk [lreplace $IMP_abstract_ondisk $index $index]

  set fileHandle [open "$IMPModules/abstracts/${abstract}.txt" "r"]
  set line [gets $fileHandle]
  set needReSave 0
  set count 0

  while {![eof $fileHandle]} {
    set line [string trim $line]
    if {$line != ""} {
      if {[lsearch -exact $IMP_abstract_contents($abstract) $line] == -1} {
        lappend IMP_abstract_contents($abstract) $line
      } else {
        IMP_putloglev 4 * "dropping duplicate $line for abstract $abstract"
        set needReSave 1
      }
      incr count
      if {[expr $count % 200] == 0} {
        putlog "  still loading abstract $abstract: $count ..."
      }
    }
    set line [gets $fileHandle]
  }

  if {[info exists fileHandle]} {
    close $fileHandle
  }

  if {$needReSave} {
    IMP_abstract_save $abstract
  }
}

proc IMP_abstract_add { abstract text {save 1} } {
  global IMP_abstract_contents IMP_abstract_timestamps IMP_abstract_max_age
  global IMPModules

  IMP_putloglev 2 * "Adding '$text' to abstract '$abstract'"

  if {$IMP_abstract_timestamps($abstract) < [expr [clock seconds] - $IMP_abstract_max_age]} {
    #IMP_abstract_load $abstract
    #new more efficient way
    # - append it to the file regardless
    # - it can be filtered on load

    IMP_putloglev 2 * "updating abstracts '$abstract' on disk"
    if {$save} {
      set fileHandle [open "[pwd]/$IMPModules/abstracts/${abstract}.txt" "a+"]
      puts $fileHandle $text
      close $fileHandle
    }
    return
  }

  if {[lsearch -exact $IMP_abstract_contents($abstract) $text] == -1} {
    lappend IMP_abstract_contents($abstract) $text
    if {$save} {
      IMP_putloglev 2 * "updating abstracts '$abstract' on disk and in memory"
      set fileHandle [open "[pwd]/$IMPModules/abstracts/${abstract}.txt" "a+"]
      puts $fileHandle $text
      close $fileHandle
    }
  }
}

proc IMP_abstract_save { abstract } {
  global IMP_abstract_contents
  global IMPModules IMP_testing IMP_loading
  global IMP_abstract_max_number

  set tidy 0
  set count 0
  set drop_count 0

  #don't save if we're starting up else we'll lose saved stuff
  if {$IMP_testing} {
    return 0
  }

  IMP_putloglev 1 * "Saving abstracts '$abstract' to disk"

  set fileHandle [open "[pwd]/$IMPModules/abstracts/${abstract}.txt" "w"]
  set number [llength $IMP_abstract_contents($abstract)]
  if {$number > $IMP_abstract_max_number} {
    putlog "Abstract $abstract has too many elements ($number > $IMP_abstract_max_number), tidying up"
    set tidy 1
  }
  foreach a $IMP_abstract_contents($abstract) {
    if {$tidy} {
      if {[rand 100] < 10} {
        IMP_putloglev d * "Dropped '$a' from abstract $abstract"
        incr drop_count
        continue
      }
    }
    puts $fileHandle $a
    incr count
  }
  if {$tidy} {
    putlog "Abstract $abstract now has $count elements ($drop_count fewer)"
  }
  close $fileHandle
}

proc IMP_abstract_all { abstract } {
  global IMP_abstract_contents IMP_abstract_timestamps IMP_abstract_max_age

  if {$IMP_abstract_timestamps($abstract) < [expr [clock seconds] - $IMP_abstract_max_age]} {
    IMP_abstract_load $abstract
  }

  return $IMP_abstract_contents($abstract)
}

proc IMP_abstract_get { abstract } {
  global IMP_abstract_contents IMP_abstract_timestamps IMP_abstract_max_age

  IMP_putloglev 2 * "getting abstract $abstract"

  if {![info exists IMP_abstract_timestamps($abstract)]} {
    return ""
  }

  IMP_counter_incr "abstracts" "gets"

  if {$IMP_abstract_timestamps($abstract) < [expr [clock seconds] - $IMP_abstract_max_age]} {
    IMP_putloglev d * "abstract $abstract has been unloaded, reloading..."
    IMP_counter_incr "abstracts" "faults"
    IMP_abstract_load $abstract
  }

  set IMP_abstract_timestamps($abstract) [clock seconds]

  return [lindex $IMP_abstract_contents($abstract) [rand [llength $IMP_abstract_contents($abstract)]]]
}

proc IMP_abstract_delete { abstract index } {
  global IMP_abstract_contents 

  set IMP_abstract_contents($abstract) [lreplace $IMP_abstract_contents($abstract) $index $index]
  IMP_abstract_save $abstract
}

proc IMP_abstract_auto_gc { min hr a b c } {
  IMP_abstract_gc
}

proc IMP_abstract_batchadd { abstract stuff } {
  IMP_putloglev d * "batch-adding to $abstract"
  foreach i $stuff {
    IMP_abstract_add $abstract $i 0
  }
  IMP_abstract_save $abstract
}

bind time - "* * * * *" IMP_abstract_auto_gc
