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

####################################
# How this module works:
# - first the input line is debrittified, removing al abbreviations etc.
# - then common expressions are translated
# - then single words are translated, even the substrings
####################################

proc IMP_module_extra_dutchify_single_word_replace_list { {inout} line } {
  # bloated function to get a little bit speed. This is one of the innerloop
  # functions. Breaks when $line is one word and we found a match

  set one_word [expr [string first " " $line] == -1]

  foreach {in out} $inout {
    if {[regsub -nocase -all "\[\[:<:\]\]$in\[\[:>:\]\]" $line $out line]} {
      if {$one_word} { 
        break
      }
    }
  }
  return $line
}

proc IMP_module_extra_dutchify_verb_replace { line } {
  set line [IMP_module_extra_dutchify_single_word_replace_list {
    lick lik  fuck paal  sit zit  see zie  fly vlieg  throw gooi  give geef
    tickle kietel  miss mis  kiss kus  run ren  honk toeter  beep piep
    hug knuffel  think denk  walk loop  sleep slaap  breathe adem  look kijk
    attempt probeer  write schrijf  try probeer
  } $line]
}

proc IMP_module_extra_dutchify_makeDutch_multiWord { line } {
  # this is mainly to replace multiple words before grammar is used.
  # also, this function isn't called from grammar, so it's less expensive
  set line [string map -nocase {"french kiss" "tongzoen"  "word" "woord"} $line]

  set line [IMP_module_extra_dutchify_single_word_replace_list {
    "(is|am) called" "heet"  "reserved sign" "gereserveerd bordje"  "to be" zijn
    {a(n)?} {een}  "you are" "jij bent"  "are you" "ben je"
    "are having" "hebben"  "is having" "heeft"  "will be" "zal"  
    "would be" "zou"  "is doing" "doet"  "are doing" "doen"
    "outer space" "de ruimte"
  } $line]

  return $line
}

proc IMP_module_extra_dutchify_makeDutch { line } {
  # these are mainly one-word replacements
  set line [string map -nocase { cow koe moron debiel retard retaar shit poep piece stukje movie film space ruimte} $line]

  # then the more simple ones
  set line [IMP_module_extra_dutchify_single_word_replace_list {
    it het  am ben  are zijn  i ik  no nee  he hij  of van  or of  you je
    the de  at in  on op  and en  has heeft  yes ja  how hoe  who wie  they zij
    do doe  air lucht  fuck neuk  miss mis  kiss kus  she zij  to naar
    with met  your jouw  like als  would zou  be zijn  if als  fail faal
    attempt poging  {(air)?plane} {vliegtuig}  not niet
    rather nogal  shall zal  as als  but maar  outer buitenste  inner binnenste
  } $line]

  set line [string map -nocase { question vraag chicken kip hello hoi line lijn my mijn have heb nice leuke name naam stolen gestolen want wil must moet yes ja thanks dank something iets because omdat prospectless kansloos } $line ]
  set line [string map -nocase { everyone iedereen bunch boel vulnerability kwetsbaarheid problem probleem } $line ]
  set line [string map -nocase { small kleine wrong fout tea thee cosy muts morning morgen that dat too ook also ook does doet middle midden therefore dus perhaps misschien maybe misschien tree BOOM$(* } $line]
  set line [string map -nocase { licking likken for voor fucking palen dictionary woordenboek dutch nederlands cool koel} $line]

  #Jeans
  set line [string map -nocase { one een two twee three drie four vier five vijf six zes seven zeven eight acht nine negen ten tien eleven elf twelve twaalf thirteen dertien fourteen veertien fifteen vijftien sixteen zestien seventeen zeventien eighteen achttien nineteen negentien } $line]
  set line [string map -nocase { twenty twintig thirty dertig fourty veertig fifty vijftig sixty zestig seventy zeventig eighty tachtig ninety negentig hundred honderd thousand duizend } $line]
  set line [string map -nocase { first eerste second tweede third derde fourth vierde fifth vijfde sixth zesde seventh zevende eighth achtste ninth negende tenth tiende } $line]
  set line [string map -nocase { where waar when wanneer why waarom what wat } $line]
  set line [string map -nocase { this dit that dat yonder ginds } $line]

  set line [string map -nocase { yesterday gisteren today vandaag tomorrow morgen week week month maand day dag year jaar second seconde minute minuut hour uur } $line]
  set line [string map -nocase { next volgend previous vorig } $line]
  set line [string map -nocase { morning ochtend afternoon middag evening avond night nacht } $line]
  set line [string map -nocase { good goed bad slecht nice leuk pretty mooi ugly lelijk beautiful mooi hideous afzichtelijk disgusting walgelijk } $line]
  set line [string map -nocase { have heeft breathe adem } $line]

  set line [string map -nocase { sun zon moon maan star ster sky hemel  heaven hemel hell hel ground grond grass gras cloud wolk } $line]
  set line [string map -nocase { bird vogel lion leeuw tiger tijger dog hond cat kat fish vis } $line]
  set line [string map -nocase { dictionary woordenboek translation vertaling } $line]
  set line [string map -nocase { car auto bike fiets train trein truck vrachtwagen boat boot ship schip balloon ballon } $line]
  set line [string map -nocase { under onder behind achter before voor } $line]

  #panique
  set line [string map -nocase { talk praten book boek pencil potlood rubber condoom theacup theekopje boat boot } $line]

  return $line
}

proc IMP_module_extra_dutchify_deBrittify {text} {
  regsub -all {'m[[:>:]]} $text { am} text
  regsub -all {'ve[[:>:]]} $text { have} text
  regsub -all {'re[[:>:]]} $text { are} text
  regsub -all {'ll[[:>:]]} $text { will} text
  regsub -all {shan't[[:>:]]} $text {shall not} text
  regsub -all {can't[[:>:]]} $text {can not} text
  regsub -all {n't[[:>:]]} $text { not} text

  # special case, we don't plural or possesive form (sp?) to be substituted
  # this will fail with 'has' instead of 'is'
  regsub -all -nocase {[[:<:]](she|he|it|that)'s[[:>:]]} $text {\1 is} text

  return $text
}

proc IMP_module_extra_dutchify_grammar {line} {
  # some rules in this proc will call makeDutch for small parts of word
  set subword ""

  #...ed --> ge...[dt]
  if {[regexp {(\w{3,})ed[[:>:]]} $line]} {
    set new_line ""
    foreach word [split $line] {
      if {[string length $new_line] > 0} {
        append new_line " "
      }
      set subword ""
      regexp {(\w{3,})ed[[:>:]]} $word discard subword

	  if {[string length $subword] > 0} {
        # ..i(ed) -> ..y
        regsub -nocase {(\w+)i[[:>:]]} $subword {\1y} subword

        set subword [IMP_module_extra_dutchify_verb_replace $subword]
        if {[regexp {(t|k|f|s|ch|p)} [string index $subword end]]} {
          if {[regexp {[^t]} [string index $subword end]]} {
            append new_line "ge${subword}t"
          } else {
            append new_line "ge${subword}"
          }
        } else {
          append new_line "ge${subword}d"
        }
      } else {
        append new_line $word
      }
    }
    set line $new_line
  }

  #...ify -> ver...en
  regsub -nocase -all {[[:<:]](.+?)ify[[:>:]]} $line {ver\1en} line

  # this has something to do with the above translation, but I can't seem
  # to figure out what :) It has something to do with removing double vowels
  regsub -nocase -all {[[:<:]](ver)(.+?)([auiou])\3([^auiou])(en)[[:>:]]} $line {\1\2\3\4\5} line

  # ...ing -> ...end   this fails most of the time :)
  #regsub -nocase -all {[[:<:]]([a-z]{4,})ing[[:>:]]} $line {\1end} line

  # <verb>s -> <verb>t
  if {[regexp {(\w{3,})s[[:>:]]} $line]} {
    set new_line ""
    foreach word [split $line] {
      if {[string length $new_line] > 0} {
        append new_line " "
      }
      set subword ""
      regexp {(\w+)s[[:>:]]} $word discard subword
      if {[string length $subword] > 0} {
        set subword_nl [IMP_module_extra_dutchify_verb_replace $subword]
        if {! [string equal $subword $subword_nl]} {
          if {[regexp {[^t]} [string index $subword end]]} {
            append new_line "${subword_nl}t"
          } else {
            append new_line "${subword_nl}"
          }
        } else {
          append new_line $word
        }
      } else {
        append new_line $word
      }
    }
    set line $new_line
  }

  return $line
}

proc IMP_module_extra_dutchify {text} {

  regsub "!nl +(.+)" $text {\1} text

  set leetMode 0
  if [regexp -nocase -- "^-l(ee|33)t (.+)" $text blah bling line] {
    set leetMode 1
  } else {
    set line $text
  }

  set line [IMP_module_extra_dutchify_deBrittify $line]
  set line [IMP_module_extra_dutchify_makeDutch_multiWord $line]
  set line [IMP_module_extra_dutchify_grammar $line]
  set line [IMP_module_extra_dutchify_makeDutch $line]

  if {$leetMode == 1} {
    set line [makeLeet2 $line]
  }

  return $line
}
