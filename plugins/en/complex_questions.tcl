## IMP plugin: question handlers

###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham 2004
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2003
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_plugin_add_complex "question" {[?>/]$} 100 IMP_plugin_complex_question "en"

proc IMP_plugin_complex_question { nick host handle channel text } {
  IMP_putloglev 2 * "Question handler triggerred"
  global botnicks IMPFacts

  regsub {(.+)[>\/]$} $text {\1?} text

  IMP_putloglev 3 * "Checking question for wellbeing"
  ## wellbeing question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how( a|')?re (you|ya)" $text] ||
       [regexp -nocase "^how( a|')?re (you|ya).*$botnicks ?\\?" $text] ||
       [regexp -nocase "${botnicks}?:? ?(how('?s|z) it going|hoe gaat het|what'?s up|'?sup|how are you),?( ${botnicks})?\\?" $text]} {
      IMP_question_wellbeing $nick $channel $host
      return 1
  }
    
  IMP_putloglev 3 * "Checking question for 'what'"
  ## What question targeted at me
  if [regexp -nocase "${botnicks}:? what ver(sion )?(of )?(imp|inmypants|in my pants) are you (running|using)\\?" $text] {
    global IMPVersion
    IMPDoAction $channel $nick "I'm running IN MY PANTS $IMPVersion (http://inmypants.berlios.de/)"
    return 1
  } elseif { [regexp -nocase "what('?s)?(.+)" $text matches s question] ||
       [regexp -nocase "what('?s)? (.*)\\?" $text matches s question] } {
    set term ""
    if [regexp -nocase {what(\'?s| is| was) ([^ ]+)} $text matches ignore term] {
      set question "is $term"
    }
    if {($term == "") && (![IMPTalkingToMe $text])} { return 0 }
    IMP_plugin_complex_question_what $nick $channel $host $question
    return 1
  }


  
    
  IMP_putloglev 3 * "Checking question for 'with/at/against'"
  ## With/at/against who question targeted at me
  if { [regexp -nocase "^$botnicks,?:? (with|at|against|by) who" $text ma mb prop] ||
       [regexp -nocase "^(with|at|against|by) who .* $botnicks ?\\?" $text ma prop ma] } {
    IMP_plugin_complex_question_with $nick $channel $host $prop
    return 1
  }

  IMP_putloglev 3 * "Checking question for 'who'"
  ## Who question targeted at me
  if { [regexp -nocase "^$botnicks,?:? who(se|'s)? " $text matches bot owner] ||
       [regexp -nocase "^who(se|'s)? .* $botnicks ?\\?" $text matches owner] } {
    IMP_plugin_complex_question_who $nick $channel $host $owner
    return 1
  }

  IMP_putloglev 3 * "Checking question for 'want'"
  ## Want question targetted at me
  if { [regexp -nocase "^$botnicks,?:? do you (need|want) (a|these|this|some|the|those|that)" $text] ||
        [regexp -nocase "^do you (want|need) (a|these|this|some|the|those|that) .* $botnicks ?\\?" $text] ||
        [regexp -nocase "^$botnicks,?:? would you like" $text] ||
        [regexp -nocase "^would you like .+ $botnicks" $text]} {
      IMP_plugin_complex_question_want $nick $channel $host
      return 1
  }

  IMP_putloglev 3 * "Checking question for 'why'"
  ## Why question targeted at me
  if { [regexp -nocase "^$botnicks,?:? why" $text] ||
       [regexp -nocase "why.* $botnicks ?\\?" $text] } {
    IMP_plugin_complex_question_why $nick $channel $host 
    return 1
  }

  IMP_putloglev 3 * "Checking question for 'where'"
  ## Where question targeted at me
  if { [regexp -nocase "^$botnicks,?:? where" $text] ||
       [regexp -nocase "^where .* $botnicks ?\\?" $text] } {
    IMP_question_where $nick $channel $host 
    return 1
  }

  IMP_putloglev 3 * "Checking question for 'how many'"
  ## How many question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how ?many" $text] ||
       [regexp -nocase "^how ?many .* $botnicks ?\\?" $text] } {
    IMP_plugin_complex_question_many $nick $channel $host 
    return 1
  }

  IMP_putloglev 3 * "Checking question for 'when'"
  ## When question targeted at me
  if { [regexp -nocase "^$botnicks,?:? (when|what time)" $text] ||
       [regexp -nocase "^(when|what time) .* $botnicks ?\\?" $text] } {
    IMP_plugin_complex_question_when $nick $channel $host 
    return 1
  }

  IMP_putloglev 3 * "Checking question for 'how'"
  ## How question targeted at me
  if { [regexp -nocase "^$botnicks,?:? how" $text] ||
       [regexp -nocase "^how .* $botnicks ?\\?" $text] } {
    IMP_plugin_complex_question_how $nick $channel $host 
    return 1
  }

  IMP_putloglev 3 * "Checking question for some general questions"    
  # some other random responses, handled here rather than simple_general so as not to break other code  
    if [regexp -nocase  "^${botnicks}:?,? do(n'?t)? you (like|want|find .+ attractive|get horny|(find|think) .+ (is ?)horny|have|keep)" $text] {
    IMP_putloglev 2 * "$nick general question"
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{yesnos}"
    return 1
  }
    
  # me .... ?
  if [regexp -nocase "^${botnicks}:?,? (.+)\\?$" $text ming ming2 question] {
    IMP_putloglev 2 * "$nick final question catch"
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{randomReplies}"
    return 1
  }

  # ... me?
  if [regexp -nocase "${botnicks}\\?$" $text bhar ming what] {
    IMP_putloglev 2 * "$nick very final question catch"
    if { [rand 2] == 1 } {
      IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{randomReplies}"
      return 1
    }
  }

  if [IMPTalkingToMe $text] {
    IMP_putloglev 2 * "$nick talkingtome catch"
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{randomReplies}"
    return 1
  }
  return 0
}

proc IMP_plugin_complex_question_what { nick channel host question } {
    IMP_putloglev 2 * "$nick what !$question! question"
    global IMPInfo IMPFacts IMPOriginalInput
    #see if we know the answer to it
    if {$question != ""} {
      if [regexp -nocase {[[:<:]]a/?s/?l[[:>:]]} $question] {
        #asl?
        set age [expr [rand 20] + 13]
        IMPDoAction $channel $nick "%%: $age/$IMPInfo(gender)/%VAR{locations}"
        return 1
      }
      if [string match -nocase "*time*" $question] {
        #what time: redirect to when
        IMP_plugin_complex_question_when $nick $channel $host
        return 1
      }
      #let's try to process this with facts
      if [regexp -nocase {is ((an?|the) )?([^ ]+)} $question ignore ignore3 ignore2 term] {
        set term [string map {"?" ""} $term]
        catch {
          set term [string tolower $term]
          IMP_putloglev 1 * "looking for what,$term"
          set answers $IMPFacts(what,$term)
          #putlog $answers
          if {[llength $answers] > 0} {
            IMP_putloglev 1 * "I know answers for what,$term"
            if {![IMPTalkingToMe $IMPOriginalInput]} {
              IMP_putloglev 1 * "I wasn't asked directly"
              if [rand 5] {
                return 1
              }
              IMP_putloglev 1 * "... but I shall answer anyway."
            }
          }
          set answer [pickRandom $answers]
          #remove any timestamp
          regsub {(_[0-9]+_ )?(.+)} $answer "\2" answer
          IMPDoAction $channel [pickRandom $answers] "%VAR{question_what_fact_wrapper}"
          return 1
        } err
        if {$err == 1} {
          return 1
        }
      }
    }
    #generic answer to what
    if [IMPTalkingToMe $IMPOriginalInput] {
      IMP_putloglev 2 * "Talking to me, so using generic answer"
      IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{answerWhats}"
      return 1
    }
}

proc IMP_plugin_complex_question_when { nick channel host } {
  IMP_putloglev 2 * "$nick When question"
  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{answerWhens}"
  return 1
}

proc IMP_plugin_complex_question_with { nick channel host prop } {
  IMP_putloglev 2 * "$nick with question"
  set answer "$prop %VAR{answerWithWhos}"
  IMPDoAction $channel [IMPGetRealName $nick $host] $answer
  return 1
}

proc IMP_plugin_complex_question_who { nick channel host owner } {
    IMP_putloglev 2 * "$nick who question"
  if {$owner == "se"} {
    set line "%OWNER[%VAR{answerWhos}]"
  } else {
    set line "%VAR{answerWhos}"
  }
  IMPDoAction $channel [IMPGetRealName $nick $host] "$line"
  return 1
}

proc IMP_plugin_complex_question_want { nick channel host } {
    IMP_putloglev 2 * "$nick Want/need question"
    IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{question_want_reply_wrapper}"
    return 1
}

proc IMP_plugin_complex_question_why { nick channel host } {
    IMP_putloglev 2 * "$nick why question"
  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{answerWhys}"
  return 1
}

## obsolete, it's been moved
# proc IMP_plugin_complex_question_where { nick channel host } {
#   IMP_putloglev 2 * "$nick where question"
#   IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{answerWheres}"
#   return 1
# }

proc IMP_plugin_complex_question_many { nick channel host } {
    IMP_putloglev 2 * "$nick how many question"
  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{answerHowmanys}"
  return 1
}

proc IMP_plugin_complex_question_how { nick channel host } {
    IMP_putloglev 2 * "$nick how question"
  IMPDoAction $channel [IMPGetRealName $nick $host] "%VAR{answerHows}"
  return 1
}

set question_what_fact_wrapper {
  "%%"
  "%% i guess"
  "i think it's %%"
  "%% i think"
  "%% i suppose"
}

set question_want_reply_wrapper {
  "Why? I've got %VAR{sillyThings}!"
  "With %VAR{sillyThings} I have no need for anything else."
  "Ooh yes please, I've had %VAR{sillyThings} for so long it's boring me."
  "Will it feel as good as %VAR{sillyThings} from %ruser?"
  "Hell yes, %ruser's given me %VAR{sillyThings} and I can't wait to get away from it!"
  "I don't know, %VAR{sillyThings} from %ruser just %VAR{fellOffs}."
  "Yes, %VAR{confuciousStart} %VAR{confuciousEnd}."
  "No, %VAR{confuciousStart} %VAR{confuciousEnd}."
  "Can I have a %VAR{chocolates} too?"
  "Yes please, I left %VAR{sillyThings} in %VAR{answerWheres}."
  "Not until %VAR{answerWhens}."
  "Yes please, the Borg Queen offered me %VAR{trekNouns} and I only got %VAR{sillyThings}."
  "%VAR{sweet}."
}
