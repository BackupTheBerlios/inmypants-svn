# IMP - Internal counters
#
# $Id: counters.tcl,v 1.1 2003/11/25 16:06:32 jamesoff Exp $
#

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

if {![info exists IMP_counters]} {
  set IMP_counters(dummy,dummy) 0
}

proc IMP_counter_init { section name } {
  global IMP_counters

  if {$section == ""} {
    return 0
  }

  if {$name == ""} {
    return 0
  }

  if [info exists IMP_counters($section,$name)] {
    IMP_putloglev d * "not reiniting counter for $section $name"
    return 0
  }

  IMP_putloglev d * "initing counter for $section $name"
  set IMP_counters($section,$name) 0
}

proc IMP_counter_incr { section name { amount 1 } } {
  global IMP_counters

  IMP_putloglev d * "incring counter $section $name by $amount"
  
  if {$section == ""} {
    return 0
  }

  if {$name == ""} {
    return 0
  }

  incr IMP_counters($section,$name) $amount
}

proc IMP_counter_get { section name } {
  global IMP_counters
  
  if {$section == ""} {
    return 0
  }

  if {$name == ""} {
    return 0
  }

  return $IMP_counters($section,$name)
}

proc IMP_counter_set { section name amount } {
  global IMP_counters

  if {$section == ""} {
    return 0
  }

  if {$name == ""} {
    return 0
  }

  set IMP_counters($section,$name) $amount
}
