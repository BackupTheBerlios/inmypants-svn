## IMP plugin: pokemon stuff ;)

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

IMP_plugin_add_complex "attack" "^%botnicks,?:? (use (your )?)?(.+) attack" 100 IMP_plugin_complex_attack "en"
IMP_plugin_add_complex "chooseyou" "^%botnicks:?,? i choose you(,? ?(.+))?" 100 IMP_plugin_complex_chooseyou "en"
IMP_plugin_add_simple "pokemon_return" "^${botnicks},?:? return!?^" 100 [list "/returns to %%'s pokeball"] "en"

proc IMP_plugin_complex_attack { nick host handle channel text } {
  global botnicks botnick mood
  if [regexp -nocase "^${botnicks}:? (use (your )?)?(.+)" $text ming ming1 ming2 ming2 what] {
    global IMPInfo botnicks
    if [regexp -nocase {[[:<:]]attack[[:>:]]} [string tolower $what]] {
      global mood
      set attack [string range $what 0 [expr [string first "attack" [string tolower $what]] - 2]]
      IMP_putloglev d * "IMP: Requested attack: $attack"
      set onwhom [string range $what [expr [string first "attack" [string tolower $what]] + 6] end]
      set who ""
      if {[string length $onwhom] > 0} {
        if [regexp -nocase "(against|on|at) (.+)" $onwhom ming ming1 who] {
          set who [string tolower $who]
        }
      }
      set onwhom $who
      if [regexp -nocase "($botnicks|you|yourself)" $who] {
        set who "$nick instead"
      }

      if [regexp -nocase "thunder(bolt|shock)" $attack ming actualAttack] {
        checkPokemon "Pikachu" $channel
        if {$mood(electricity) < 0} {
          IMPDoAction $channel $nick "pikaa...."
          IMPDoAction $channel $nick "/collapses"
          putserv "NOTICE $nick :Sorry, I don't have enough power for a thunder$actualAttack at the moment :("
          IMPDoAction $channel $nick "... pikachu :("
          return 1
        }
        incr mood(electricity) -3
        IMPDoAction $channel $nick "pikaaa.... CH%REPEAT{3:6:U}"
        if {$who == ""} { IMPDoAction $channel $nick "/fires [getHisHer] thunder$actualAttack!" } else {
          IMPDoAction $channel $who "/fires [getHisHer] thunder$actualAttack at %%"
        }
        return 1
      }

      if [string match "*agility*" $attack] {
        checkPokemon "Pikachu" $channel
        IMPDoAction $channel $nick "pikachu!"
        if {$who == ""} { IMPDoAction $channel $nick "/runs around the channel in a random fashion!" } else {
          IMPDoAction $channel $who "/runs rings around %%"
        }
        return 1
      }

      if [string match "*lightning*" $attack] {
        checkPokemon "Pikachu" $channel
        if {$mood(electricity) < 0} {
          IMPDoAction $channel $nick "pikaa...."
          IMPDoAction $channel $nick "/collapses"
          putserv "NOTICE $nick :Sorry, I don't have enough power for a lightning attack at the moment :("
          IMPDoAction $channel $nick "... pikachu :("
          return 1
        }
        incr mood(electricity) -2
        IMPDoAction $channel $nick "pikaaa.... CH%REPEAT{3:6:U}"
        if {$who == ""} { IMPDoAction $channel $nick "/fires [getHisHer] lightning attack!" } else {
          IMPDoAction $channel $who "/fires [getHisHer] lightning attack at %%"
        }
        return 1
      }

      if [string match "*monkey*" $attack] {
        checkPokemon "Damoachu" $channel
        IMPDoAction $channel $nick "Damoa...chu!"
        if {$who == ""} { 
          IMPDoAction $channel $nick "*monkey* *monkey* *monkey* *squirtle*"
        } else {
          IMPDoAction $channel $who  "*monkey* *monkey* *monkey* *squitle at %%*"
        }
        return 1
      }

      if [string match "*gigaskrill*" $attack] {
        checkPokemon "Skrillachu" $channel
        IMPDoAction $channel $nick "sssskrrillll...ACHU!"
        if {$who == ""} {
          IMPDoAction $channel $nick "/activates [getHisHer] gigaskill attack"
        } else {
          IMPDoAction $channel $who "/activates [getHisHer] gigaskill attack against %%"
        }
        return 1
      }


      # Everything else
      if [regexp -nocase "(against|on|at) (.+)" $text ming ming1 who] {
        IMPDoAction $channel $who "$IMPInfo(pokemon)!"
        IMPDoAction $channel $who "/uses [getHisHer] $attack attack against $who"
        return 1
      } else {
        IMPDoAction $channel "" "$IMPInfo(pokemon)! *$attack attack*"
      }
      return 1
    }
  }
}

proc IMP_plugin_complex_chooseyou { nick host handle channel text } {
  if [regexp -nocase "^${botnicks}:?,? i choose you(,? ?(.+))?" $text ming ming1 who] {
    if {$who == ""} {
      IMPDoAction $channel $nick "er, thanks :P"
      return 1
    }
    checkPokemon $who $channel
  }
}
