# IMP - event supporting functions

###############################################################################
# IMP - an 'AI' TCL script for eggdrops
# IMP is Copyright (C) Dave Wickham 2004
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

proc finishdildo {} {
  global got mood dildoPlays

  set style $got(dildo,style)

  if {$style == "flute"} {
    global dildoFluteFinishes
    cum $got(dildo,channel) $got(dildo,nick)
    IMPDoAction $got(dildo,channel) $got(dildo,nick) "%VAR{dildoFluteFinishes}"
    set got(dildo,nick) ""
    set got(dildo,count) 0
    incr mood(happy) 1
    incr mood(horny) -2
    return 0
  }

  if {$style == "f_swap"} {
    global dildoFemaleFemaleSwap
    IMPDoAction $got(dildo,channel) $got(dildo,dildo) "%VAR{dildoFemaleFemaleSwap}"
    set got(dildo,style) "normal"
    utimer 70 finishdildo
    return 0
  }
  
  if {$style == "m_swap"} {
    global dildoMaleMaleSwap
    IMPDoAction $got(dildo,channel) $got(dildo,dildo) "%VAR{dildoMaleMaleSwap}"
    set got(dildo,style) "normal"
    utimer 70 finishdildo
    return 0
  }

  global dildoFinishes
  cum $got(dildo,channel) $got(dildo,nick)
  IMPDoAction $got(dildo,channel) $got(dildo,dildo) "%VAR{dildoFinishes}" $got(dildo,nick)
  set got(dildo,nick) ""
  set got(dildo,count) 0
  incr mood(happy) 1
  incr mood(horny) -2
}

## BEGIN lol function (TODO: rename this and calls to it)
proc lol {nick host handle channel text} {
  #ignore the J flag users
  if [matchattr $handle J] {
    return 0
  }

  global botnick mood lols IMPCache
  if {$nick == $botnick} {return 0}

  if {![IMPIsFriend $nick]} { return 0 }

  incr IMPCache(LOLcount)
  if {[string toupper $text] == $text} { incr IMPCache(LOLcount) }
  if {$IMPCache(LOLcount) > 3} {  
    if {$mood(happy) < -10} {
      incr mood(happy)
      return 0
    }
    if {[rand 10] > 6} {
      IMPDoAction $channel $nick "%VAR{lols}"
      set IMPCache(LOLcount) 0
    }
    checkmood "" ""
  }
}
## END

proc cum {channel nick} {
  global IMPInfo
  global mood
  if {![pastWatershedCheck $nick]} { return 0 }  
  if {![IMPIsFriend $nick]} { 
    IMPDoAction $channel $nick "%VAR{blehs} I can't cum thinking about someone I don't like"
    return 0
  }
  if {$IMPInfo(gender) == "male"} {
    IMPDoAction $channel $nick "/ejaculates over %%"
    incr mood(horny) -3
    incr mood(happy) 2
    return 0
  }
  IMPDoAction $channel $nick "/makes herself cum thinking about %%"
  incr mood(horny) -3
  incr mood(happy) 2
  return 0
}

proc frightened {nick channel} {
  global mood
  IMPDoAction $channel $nick "%VAR{frightens} %VAR{unsmiles}"
  incr mood(lonely) -1
  incr mood(happy) -1
}

proc IMPMakeItSo {nick channel} {
  global makeItSos
  IMPDoAction $channel $nick "%VAR{makeItSos}"
  global IMPCache
  set IMPCache(lastDoneFor) $nick
}

proc checkPokemon {which channel} {
  global IMPInfo
  if {$IMPInfo(pokemon) != [string tolower $which]} {
    IMPDoAction $channel $which "/morphs into %%!"
    set IMPInfo(pokemon) [string tolower $which]
  }
}

proc IMPYesNo {channel} {
  global yeses nos
  set yesnos [concat $yeses $nos]
  IMPDoAction $channel "" "%VAR{yesnos}"
  return 0
}

proc IMPBlessYou {channel nick} {
  global IMPInfo
  global blessyous
  if {![IMPIsFriend $nick]} { return 0 }
  if {[rand 2] && ($IMPInfo(balefire) == 1)} {
    IMPDoAction $channel $nick "%VAR{blessyous}"
    IMPGetUnLonely
  }
}

proc IMPRandomTime {channel nick} {
	set hour [expr [rand 11] + 1]
	set min [rand 59]
	if [rand 2] {
	  set ampm "am"
	} else {
	  set ampm "pm"
	  }

	if {$min < 30} {
	  set timestr "$min past $hour"
	  }

	if {$min == 30} {
	  set timestr "half-past $hour"
	  }

	if {$min > 30} {
	  set min [expr 60 - $min]
	  set timestr "$min to $hour"
	  }

  if {$min == 0} {
    set timestr "$hour"
  }

	IMPDoAction $channel $nick "%%: about $timestr $ampm"
	return 0
}

proc IMPRandomQuestion {channel} {

  set silly1 [IMP_abstract_get "sillyThings"]
  set silly2 [IMP_abstract_get "sillyThings"]

  IMPDoAction $channel "" "$silly1 or $silly2?"
  return 0
}

proc IMPEndTeamRocket {} {
  global IMPCache
  set IMPCache(teamRocket) ""
}    

IMP_putloglev d * "IMP: event support module loaded"
