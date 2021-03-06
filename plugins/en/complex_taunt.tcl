## IMP Taunt plugin
#

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

IMP_plugin_add_complex "taunt" "^!taunt" 100 IMP_plugin_complex_taunt "en"

proc IMP_plugin_complex_taunt {nick host handle channel text} {
  global randomTauntPrefixes randomTauntSuffixes botnick

  set prefix ""

  regsub -nocase "!taunt " $text "" text

  if [regexp -nocase $botnick $text] {
    set text $nick
  }

  if [regexp "(.+)" $text] {
    
    #check for plural
    if {[string index $text end] == "s"} {
      set plural "s"
    } else {
      set plural ""
    }

    if {$plural != ""} {
      set prefix "$text: You are"
    } else {
      set prefix "$text: You are a"
    }
  }

  IMPDoAction $channel "" "$prefix [pickRandom $randomTauntPrefixes] [pickRandom $randomTauntSuffixes]$plural"
  IMP_flood_undo $nick
  return 0
}


### and our abstracts...

set randomTauntPrefixes {
  "idiot"
  "stupid"
  "minging"
  "incompetent"
  "foolish"
  "silly"
  "prancing"
  "dancing"
  "buffoonesque"
  "horizontally-enhanced"
  "special"
  "Welsh"
  "Northern"
  "Southern"
  "fishguts"
  "imbecile"
  "credulous"
  "cretinous"
  "naughty"
  "disreputable"
  "absurd"
  "capricious"
  "lemon-flavoured"
}

set randomTauntSuffixes {
  "fool"
  "idiot"
  "buffoon"
  "mingbeast"
  "incompetent"
  "loser"
  "monstar"
  "foo'"
  "woolhead"
  "kenneth"
  "taunt"
  "individual"
  "failure"
  "imbecile"
  "cretin"
  "chap"
  "waste of space"
  "joker"
  "drone"
  "sailor"
  "moron"
}
