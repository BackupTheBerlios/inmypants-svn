## sex plugin for IMP

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

IMP_plugin_add_complex "sex-oral" "^%botnicks:?,? go down on " 100 "IMP_plugin_complex_sex_go_down_on" "en"
IMP_plugin_add_complex "sex-oral2" "^%botnicks eat (.+) out" 100 "IMP_plugin_complex_sex_go_down_on_2" "en"

proc IMP_plugin_complex_sex_go_down_on { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "${botnicks}:?,? (please)?go down on (.+)" $text ming ming1 ming2 details] {    
    IMPGoDownOn $channel $details $nick    
    return 1
  }
}

proc IMP_plugin_complex_sex_go_down_on_2 { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "^${botnicks},?:? (please)?eat (.+) out" $text ming ming1 ming2 who] {
    IMPGoDownOn $channel $who $nick
    return 1
  }
}

## supporting functions

proc IMPGoDownOn {channel nick forNick} {
    global mood goDowns botnick IMPCache
    regsub {^([^ ]+)( .+)?} $nick {\1} nick
    IMP_putloglev d * "IMP: Was asked to go down on '$nick' in $channel by $forNick"
    if {[regexp -nocase "(himself|herself|your?self)" $nick] || [isbotnick $nick]} { 
      IMPDoAction $channel "" "No. (ERR_EXCESS_RIBS)"
      return 0
    }
    if [string match -nocase "me" $nick] { set nick $forNick }

    set host [getchanhost $nick]
    if {$host == ""} {
      putserv "NOTICE $forNick :Sorry, I can't find $nick to go down on for you."
      return 0
    }
    if {![IMPLike $nick $host]} {
      IMPDoAction $channel $nick "No, they're not my type."
      return 0
    }
    IMP_putloglev d * "IMP: Went down on $nick for $forNick"
    IMPDoAction $channel $nick [pickRandom %VAR{goDowns}]
    #TODO:
    #if [matchattr [nick2hand $nick $host] b|K $channel] {
    #  IMPDoAction $channel "" "%PICKBOT[name=$nick]%|%BOT[¬VAR{rarrs}]"
    #}
    incr mood(horny) 1
    incr mood(happy) 1
    incr mood(lonely) -1
    set IMPCache(lastDoneFor) "$nick $forNick"
    return 0
}
