#IMP - Output functions

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

# init our counters
IMP_counter_init "output" "lines"
IMP_counter_init "output" "irclines"

proc pickRandom { list } {
  return [lindex $list [rand [llength $list]]]
}

proc getPronoun {} {
  global IMPInfo
  if {$IMPInfo(gender) == "male"} { return "himself" }
  if {$IMPInfo(gender) == "female"} { return "herself" }
  return "itself"
}

proc getHisHers {} {
  global IMPInfo
  if {$IMPInfo(gender) == "male"} { return "his" }
  if {$IMPInfo(gender) == "female"} { return "hers" }
  return "its"
}

proc getHisHer {} {
  global IMPInfo
  if {$IMPInfo(gender) == "male"} { return "his" }
  if {$IMPInfo(gender) == "female"} { return "her" }
  return "it"
}


proc getHeShe {} {
  global IMPInfo
  if {$IMPInfo(gender) == "male"} { return "he" }
  if {$IMPInfo(gender) == "female"} { return "she" }
  return "it"
}


proc mee {channel action {urgent 0} } {
  set channel [chandname2name $channel]
  if {$urgent} {
    IMP_queue_add_now $channel "\001ACTION $action\001"
  } else {
    IMP_queue_add $channel "\001ACTION $action\001"
  }
}


## IMPDoAction ###########################################################
proc IMPDoAction {channel nick text {moreText ""} {noTypo 0} {urgent 0} } {
  IMP_putloglev 4 * "IMP: IMPDoAction($channel,$nick,$text,$moreText,$noTypo)"
  global IMPInfo IMPCache
  set IMPCache($channel,last) 1
  set IMPCache(typos) 0
  set IMPCache(typoFix) ""

  #check our global toggle
  global IMPGlobal
  if {$IMPGlobal == 0} {
    return 0
  }

  if [regexp "^\[#!\].+" $channel] {
    set channel [string tolower $channel]
    if {[lsearch $IMPInfo(randomChannels) [string tolower $channel]] < 0} {
      IMP_putloglev d * "IMP: aborting IMPDoAction ... $channel not allowed"
      return 0
    }
  }

  if {$IMPInfo(silence) == 1} { return 0 }
  catch {
    if {$IMPInfo(adminSilence,$channel) == 1} { return 0 }
  }

  IMP_counter_incr "output" "lines"

  switch [rand 3] {
    0 { }
    1 { set nick [string tolower $nick] }
    2 { set nick "[string range $nick 0 0][string tolower [string range $nick 1 end]]" }
  } 

  #do this first now
  set text [IMPDoInterpolation $text $nick $moreText $channel]

  set multiPart 0
  if [string match "*%|*" $text] {
    set multiPart 1
    # we have many things to do
    set thingsToSay ""
    set loopCount 0
    set blah 0
    
    #make sure we get the last section
    set text "$text%|"

    while {[string match "*%|*" $text]} {
      set sentence [string range $text 0 [expr [string first "%|" $text] -1]]
      if {$sentence != ""} { 
        if {$blah == 0} {
          set thingsToSay [list $sentence] 
          set blah 1
        } else {
          lappend thingsToSay $sentence
        }
      }
      set text [string range $text [expr [string first "%|" $text] + 2] end]
      incr loopCount
      if {$loopCount > 20} { 
        putlog "IMP ALERT! Bailed in IMPDoAction with $text. Lost output."
        return 0
      }
    }
  }

  if {$multiPart == 1} {
    foreach lineIn $thingsToSay {
      set temp [IMPSayLine $channel $nick $lineIn $moreText $noTypo $urgent]
      if {$temp == 1} {
        IMP_putloglev 1 * "IMP: IMPSayLine returned 1, skipping rest of output"
        #1 stops continuation after a failed %bot[n,]
        break
      }
    }
    set typosDone [IMP_plugins_settings_get "output:typos" "typosDone" "" ""]
    IMP_putloglev 2 * "IMP: typosDone (multipart) is !$typosDone!"
    if {$typosDone != ""} {
      IMP_plugins_settings_set "output:typos" "typosDone" "" "" ""
      if [rand 2] {
        IMPDoAction $channel "" "%VAR{typoFix}" "" 1
      }
      IMP_plugins_settings_set "output:typos" "typos" "" "" ""      
      

    }
    return 0
  }

  IMPSayLine $channel $nick $text $moreText $noTypo $urgent
  set typosDone [IMP_plugins_settings_get "output:typos" "typosDone" "" ""]
  IMP_putloglev 2 * "IMP: typosDone is !$typosDone!"
  if {$typosDone != ""} {
    IMP_plugins_settings_set "output:typos" "typosDone" "" "" ""
    if [rand 2] {
      IMPDoAction $channel "" "%VAR{typoFix}" "" 1
    }
    IMP_plugins_settings_set "output:typos" "typos" "" "" ""        
  }

  return 0
}

proc IMPDoInterpolation { line nick moreText { channel "" } } {
  IMP_putloglev 3 * "IMPDoInterpolation: line = $line, nick = $nick, moreText = $moreText, channel = $channel"
  global botnick IMPCache

  if [string match "*%noun*" $line] {
    set line [IMPInsertString $line "%noun" "%VAR{sillyThings}"]
  }

  set loops 0
  IMP_putloglev 4 * "doing VAR processing"
  while {[regexp "%VAR\{(.+?)\}" $line matches BOOM]} {
    global $BOOM
    incr loops
    if {$loops > 10} {
      putlog "IMP: ALERT! looping too much in %VAR code with $line"
      set line "/has a tremendous error while trying to sort something out :("
    }
    #see if we have a new-style abstract available
    set newText [IMP_abstract_get $BOOM]
    if {$newText == ""} {
      #insert old style
      set var [subst $$BOOM]
      #set line [IMPInsertString $line "%VAR\{$BOOM\}" [pickRandom $var]]
      IMP_putloglev 1 * "before1: $line"
      regsub "%VAR\{$BOOM\}" $line [pickRandom $var] line
      IMP_putloglev 1 * "after1: $line"
    } else {      
      #set line [IMPInsertString $line "%VAR\{$BOOM\}" $newText]
      IMP_putloglev 1 * "before2: $line"
      regsub "%VAR\{$BOOM\}" $line $newText line
      IMP_putloglev 1 * "after2: $line"
    }
    if [string match "*%noun*" $line] {
      set line [IMPInsertString $line "%noun" "%VAR{sillyThings}"]
    }
  }

  set loops 0
  IMP_putloglev 4 * "doing SETTING processing"
  while {[regexp "%SETTING\{(.+?)\}" $line matches settingString]} {
    set var ""
    if [regexp {([^:]+:[^:]+):([^:]+):([^:]+):([^:]+)} $settingString matches plugin setting ch ni] {
      set var [IMP_plugins_settings_get $plugin $setting $ch $ni]
    }
    incr loops
    if {$loops > 10} {
      putlog "IMP: ALERT! looping too much in %SETTING code with $line"
      set line "/has a tremendous error while trying to infer the meaning of life :("
    }
    if {$var == ""} {
      putlog "IMP: ALERT! couldn't find setting $settingString (dropping output)"
      return ""
    }
    set line [IMPInsertString $line "%SETTING{$settingString}" $var]
  }
  
  set loops 0
  IMP_putloglev 4 * "doing NUMBER processing"
  while {[regexp "%NUMBER\{(.+?)\}" $line matches numberString]} {
    set var [IMP_get_number [rand $numberString]]
    incr loops
    if {$loops > 10} {
      putlog "IMP: ALERT! looping too much in %NUMBER code with $line"
      set line "/has a tremendous error while trying to think of a number :("
    }
    set line [IMPInsertString $line "%NUMBER\\{$numberString\\}" $var]
  }

  IMP_putloglev 4 * "doing misc interpolation processing"
  set line [IMPInsertString $line "%%" $nick]
  set line [IMPInsertString $line "%pronoun" [getPronoun]]
  set line [IMPInsertString $line "%himherself" [getPronoun]]
  set line [IMPInsertString $line "%me" $botnick]
  set line [IMPInsertString $line "%colen" [IMPGetColenChars]]
  set line [IMPInsertString $line "%hishers" [getHisHers]]
  set line [IMPInsertString $line "%heshe" [getHeShe]]
  set line [IMPInsertString $line "%hisher" [getHisHer]]
  set line [IMPInsertString $line "%2" $moreText]
  set line [IMPInsertString $line "%percent" "%"]

  #ruser:
  set loops 0
  while {[regexp "%ruser(\{(\[^\}\]+)\})?" $line matches param condition]} {
    set ruser [IMPGetRealName [IMP_choose_random_user $channel 0 $condition] ""]
    if {$condition == ""} {
      set findString "%ruser"
    } else {
      set findString "%ruser$param"
    }
    regsub $findString $line $ruser line
    incr loops
    if {$loops > 10} {
      putlog "bleh :( $line"
      return ""
    }
  }

  #rbot:
  set loops 0
  while {[regexp "%rbot(\{(\[^\}\]+)\})?" $line matches param condition]} {
    set ruser [IMPGetRealName [IMP_choose_random_user $channel 1 $condition] ""]
    if {$condition == ""} {
      set findString "%rbot"
    } else {
      set findString "%rbot$param"
    }
    regsub $findString $line $ruser line
    incr loops
    if {$loops > 10} {
      putlog "bleh :( $line"
      return ""
    }
  }

  IMP_putloglev 4 * "IMPDoInterpolation returning: $line"
  return $line
}

proc IMPInterpolation2 { line } {

  #owners
  set loops 0
  while {[regexp -nocase "%OWNER\{(.*?)\}" $line matches BOOM]} {
    incr loops
    if {$loops > 10} {
      putlog "IMP: ALERT! looping too much in %OWNER code with $line"
      set line "/has a tremendous error while trying to sort something out :("
    }
    set line [IMPInsertString $line "%OWNER\{$BOOM\}" [IMPMakePossessive $BOOM]]
  }

  set loops 0
  while {[regexp -nocase "%REPEAT\{(.+?)\}" $line matches BOOM]} {
    incr loops
    if {$loops > 10} {
      putlog "IMP: ALERT! looping too much in %REPEAT code with $line"
      set line "/has a tremendous error while trying to sort something out :("
    }
    set line [IMPInsertString $line "%REPEAT\\\{$BOOM\\\}" [IMPMakeRepeat $BOOM]]
  }

  return $line
}

proc IMPSayLine {channel nick line {moreText ""} {noTypo 0} {urgent 0} } {
  IMP_putloglev 3 * "IMPSayLine: channel = $channel, nick = $nick, line = $line, moreText = $moreText, noTypo = $noTypo"
  global mood botnick IMPInfo IMPCache

  set line [IMPInterpolation2 $line]

  #TODO: Put %ruser and %rbot back in here

  #if it's a bot , put it on the queue on the remote bot
  if [regexp -nocase {%(BOT)\[(.+?)\]} $line matches botcmd cmd] {
    set condition ""
    set dobreak 0
    if {$botcmd == "bot"} {
      #random
      IMP_putloglev 1 * "IMP: %bot detected"
      regexp {%bot\[([[:digit:]]+),(@[^,]+,)?(.+)\]} $line matches chance condition cmd
      IMP_putloglev 1 * "IMP: %bot chance is $chance"
      set dobreak 1
      if {[rand 100] < $chance} {
        set line "%BOT\[$cmd\]"
        set dobreak 0
      } else {
        set line ""
      }
    } else {
      #non-random
      regexp {%BOT\[(@[^,]+,)?(.+)\]} $line matches condition cmd
    }

    if {($condition != "") && [regexp {^@(.+),$} $condition matches c]} {
      set condition $c
    } else {
      if {$condition != ""} {
        set cmd $condition
        set condition ""
      }
    }

    if {$line != ""} {
      set bot [IMP_choose_random_user $channel 1 $condition]
      IMP_putloglev 1 * "IMP: queuing botcommand !$cmd! for output to $bot"
      IMP_queue_add $channel "@${bot}@$cmd"
    }

    if {$dobreak == 1} {
      return 1
    }
    return 0
  }

  #if it's a %STOP, abort this
  if {$line == "%STOP"} {
    set line ""
    return 1
  }


  if {$mood(stoned) > 3} {
    if [rand 2] {
      set line "$line man.."
    } else {
      if [rand 2] {
        set line "$line dude..."
      }
    }
  }

  # Run the plugins :D

  if {$noTypo == 0} {
    set plugins [IMP_plugin_find_output $IMPInfo(language)]
    if {[llength $plugins] > 0} {
      foreach callback $plugins {
        IMP_putloglev 1 * "IMP: output plugin: $callback..."
        catch {
          set result [$callback $channel $line]
        } err
        IMP_putloglev 3 * "IMP: returned from output $callback ($result)"
        if [regexp "1¦(.+)" $result matches line] {
          break
        }
        set line $result
      }
    }
  }

  #check if this line matches the last line said on IRC
  global IMPThisText
  if [string match -nocase $IMPThisText $line] {
    IMP_putloglev 1 * "IMP: my output matches the trigger, dropping"
    return 0
  }

  set line [IMPInsertString $line "%slash" "/"]
  
  if [regexp "^/" $line] {
    #it's an action
    mee $channel [string range $line 1 end] $urgent
  } else {
    if {$urgent} {
      IMP_queue_add_now [chandname2name $channel] $line
    } else {
      IMP_queue_add [chandname2name $channel] $line
    }
  }
  return 0
}

proc IMPInsertString {line swapout toInsert} {
  set loops 0
  set inputLine $line
  while {[regexp $swapout $line]} {
    regsub $swapout $line $toInsert line
    incr loops
    if {$loops > 10} {
      putlog "IMP: ALERT! Bailed in IMPInsertString with $inputLine (created $line) (was changing $swapout for $toInsert)"
      set line "/has a tremendous failure :("
      return $line
    }
  }
  return $line
}

proc IMPGetColenChars {} {
  set randomChar "!£$%^*@#~"

  set randomChars [split $randomChar {}]

  set length [rand 12]
  set length [expr $length + 5]

  set line ""

  while {$length >= 0} {
    incr length -1
    append line [pickRandom $randomChars]
  }

  regsub -all "%%" $line "%percent" line

  return $line
}

proc makeSmiley { mood } {
  if {$mood > 30} {
    return ":D"
  }
  if {$mood > 0} {
    return ":)"
  }
  if {$mood == 0} {
    return ":|"
  }
  if {$mood < -30} {
    return ":C"
  }
  if {$mood < 0} {
    return ":("
  }
  return ":?"
}

## Wash nick
#    Attempt to clean a nickname up to a proper name
#
proc IMPWashNick { nick } {
  #remove leading
  regsub {^[|`_\[]+} $nick "" nick

  #remove trailing
  regsub {[|`_\[]+$} $nick "" nick

  return $nick
}

proc OLDIMPGetRealName { nick { host "" }} {
  IMP_putloglev 4 * "IMP: IMPGetRealName($nick,$host)"

  #is it me?
  global botnicks
  set first {[[:<:]]}
  set last {[[:>:]]}
  if [regexp -nocase "${first}${botnicks}$last" $nick] {
    return "me"
  }

  #first see if we've got a handle
  if {![validuser $nick]} {
    IMP_putloglev 2 * "IMP: getRealName not given a handle, assuming $nick!$host"
    set host "$nick!$host"

    set handle [finduser $host]
    if {$handle == "*"} {
      #not in bot
      IMP_putloglev 2 * "IMP: no match, washing nick"
      return [IMPWashNick $nick]
    }
  } else {
    set handle $nick
  }

  IMP_putloglev 2 * "IMP: getRealName looking for handle $handle"

  # found a user, now get their real name
  set realname [getuser $handle XTRA irl]
  if {$realname == ""} {
    #not set
    return [IMPWashNick $nick]
  }
  putloglev 2 * "IMP: found $handle, IRLs are $realname"
  return [pickRandom $realname]
}

proc IMPGetRealName { nick { host "" }} {
  IMP_putloglev 3 * "IMP: IMPGetRealName($nick,$host)"

  if {$nick == ""} {
    return ""
  }

  #is it me?
  if [isbotnick $nick] {
    return "me"
  }

  if [validuser $nick] {
    #it's a handle already
    set handle $nick
  } else {
    #try to figure it out
    set handle [nick2hand $nick]
    if {($handle == "") ||($handle == "*")} {
      #not in bot
      IMP_putloglev 2 * "IMP: no match, using nick"
      return $nick
    }
  }

  IMP_putloglev 2 * "IMP: $nick is handle $handle"

  # found a user, now get their real name
  set realname [getuser $handle XTRA irl]
  if {$realname == ""} {
    #not set
    IMP_putloglev 2 * "no IRL set, using nick"
    return $nick
  }
  putloglev 2 * "IMP: IRLs for $handle are $realname"
  return [pickRandom $realname]
}

proc IMPTransformNick { target nick {host ""} } {
  set newTarget [IMPTransformTarget $target $host]
  if {$newTarget == "me"} {
    set newTarget $nick
  }
  return $newTarget
}

proc IMPTransformTarget { target {host ""} } {
  global botnicks
  if {$target != "me"} {
    set t [IMPGetRealName $target $host]
    IMP_putloglev 2 * "IMP: IMPGetName in IMPTransformTarget returned $t"
    if {$t != "me"} {
      set target $t
    }
  } else {
    set himself {[[:<:]](your?self|}
    append himself $botnicks
    append himself {)[[:>:]]}
    if [regexp -nocase $himself $target] {
      set target [getPronoun]
    }
  }
  return $target
}

# IMP_choose_random_user
#
# selects a random user or bot from a channel
# bot = 0 if you want a user, = 1 if you want a bot
# condition is one of:
#   * "" - anyone
#   * male, female - pick by gender
#   * like, dislike - pick by if we'd do them
#   * friend, enemy - pick by if we're friends
#   * prev - return previously chosen user/bot
proc IMP_choose_random_user { channel bot condition } {
  global IMPCache
  set users [chanlist $channel]
  set acceptable [list]

  #check if we want the previous ruser
  if {$condition == "prev"} {
    set what [list "" ""]
    catch {
      set what [array get IMPCache "lastruser$bot"]
    }
    IMP_putloglev 4 * "accept: prev ($what)"
    return [lindex $what 1]
  }

  foreach user $users {
    IMP_putloglev 4 * "eval user $user"
    #is it me?
    if [isbotnick $user] { continue }

    #get their handle
    set handle [nick2hand $user $channel]
    IMP_putloglev 4 * "  handle: $handle"

    #unless we're looking for any old user, we'll need handle
    if {(($handle == "") || ($handle == "*")) && ($condition != "")} {
      IMP_putloglev 4 * "  --reject: no handle"
      continue
    }

    #else, if we're accepting anyone and they don't have a handle, use nick
    if {(($handle == "") || ($handle == "*")) && ($condition == "")} {
      IMP_putloglev 4 * "  ++accept: $user (no handle)"
      lappend acceptable $user
      continue
    }

    #if we're looking for a bot, drop this entry if it's not one
    if {$bot == 1} {
      if {![matchattr $handle b]} {
        IMP_putloglev 4 * "  --reject: not a bot"
        continue
      }
      #check we can talk to this bot
      global IMP_interbot_otherbots
      if {[lindex [array names IMP_interbot_otherbots] $bot] == -1} {
        IMP_putloglev 4 * "  --reject: not a bmotion bot"
        continue
      }
    }

    #conversely if we're looking for a user...
    if {($bot == 0) && [matchattr $handle b]} {
      IMP_putloglev 4 * "  --reject: not a user"
      continue
    }

    switch $condition {
      "" {
        IMP_putloglev 4 * "  ++accept: any"
        lappend acceptable $handle
      }
      "male" {
        if {[getuser $handle XTRA gender] == "male"} {
          IMP_putloglev 4 * "  ++accept: male"
          lappend acceptable $handle
        }
      }
      "female" {
        if {[getuser $handle XTRA gender] == "female"} {
          IMP_putloglev 4 * "  ++accept: female"
          lappend acceptable $handle
        }
      }
      "like" {
        if {[IMPLike $user [getchanhost $user]]} {
          IMP_putloglev 4 * "  ++accept: like"
          lappend acceptable $handle
        }
      }
      "dislike" {
        if {![IMPLike $user [getchanhost $user]]} {
          IMP_putloglev 4 * "  ++accept: dislike"
          lappend acceptable $handle
        }
      }
      "friend" {
        if {[getFriendshipHandle $user] > 50} {
          IMP_putloglev 4 * "  ++accept: friend"
          lappend acceptable $handle
        }
      }
      "enemy" {
        if {[getFriendshipHandle $user] < 50} {
          IMP_putloglev 4 * "  ++accept: enemy"
          lappend acceptable $handle
        }
      }
    }
  }
  IMP_putloglev 4 * "acceptable users: $acceptable"
  if {[llength $acceptable] > 0} {
    set user [pickRandom $acceptable]
    set index "lastruser$bot"
    set IMPCache($index) $user
    return $user
  } else {
    if {$condition != ""} {
      return [IMP_choose_random_user $channel $bot ""]
    } else {
      return ""
    }
  }
}

proc IMPMakePossessive { text { altMode 0 }} {
  if {$text == ""} {
    return "someone's"
  }

  if {$text == "me"} {
    if {$altMode == 1} {
      return "mine"
    }
    return "my"
  }

  if {$text == "you"} {
    if {$altMode == 1} {
      return "yours"
    }
    return "your"
  }

  if [regexp -nocase "s$" $text] {
    return "$text'"
  }
  return "$text's"
}

proc IMPMakeRepeat { text } {
  if [regexp {([0-9]+):([0-9]+):(.+)} $text matches min max repeat] {
    set diff [expr $max - $min]
    set count [rand $diff]
    set repstring [string repeat $repeat $count]
    append repstring [string repeat $repeat $min]
    return $repstring
  }
  return ""
}

IMP_putloglev d * "IMP: output module loaded"
