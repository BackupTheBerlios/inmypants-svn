# IMP - Global variable init

###############################################################################
# IMP - an 'AI' TCL script for eggdrops
# IMP is Copyright (C) 2004 Dave Wickham
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2002
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

# Defaults

# Mood stuff is in mood.tcl

if {![info exists got]} {
  set got(tissues,nick) ""
  set got(tissues,channel) ""
  set got(coffee,nick) ""
  set got(coffee,channel) ""
  set got(bodyPaint,nick) ""
  set got(bodyPaint,channel) ""
  set got(dildo,nick) ""
  set got(dildo,count) 0
  set got(dildo,style) ""
}

if {![info exists IMPInfo]} {
  set IMPInfo(pokemon) "pikachu"
  set IMPInfo(lowerWatershed) 8
  set IMPInfo(upperWatershed) 21
  set IMPInfo(cloaked) 0
  set IMPInfo(warp) 0
  set IMPInfo(impulse) 0
  set IMPInfo(brig) ""
  set IMPInfo(leet) 0
  set IMPInfo(dutch) 0
  set IMPInfo(leetChance) 3
  set IMPInfo(silence) 0
  set IMPInfo(away) 0
  set IMPInfo(clothing) 5 
}

if {![info exists IMPCache]} {
  set IMPCache(away) ""
  set IMPCache(lastGreeted) ""
  set IMPCache(lastHows) ""
  set IMPCache(lastDoneFor) ""
  set IMPCache(lastEvil) ""
  set IMPCache(teamRocket) ""
  set IMPCache(LOLcount) 0
  set IMPCache(lastLeft) ""
  set IMPCache(opme) ""
  set IMPCache(typos) 0
  set IMPCache(typoFix) ""
  set IMPCache(remoteBot) ""
  set IMPCache(randomUser) ""
  set IMPCache(lastPlugin) ""
}

#this is set later
set botnicks ""

set arrcachearr ""
set arrcachenick ""
set colenMings [expr srand([clock clicks])]

set IMPAdminFlag "n"

#typing queue
set IMPQueue [list]
set IMPQueueTimer 0

set IMPThisText ""

#0 for off
set IMPGlobal 1
