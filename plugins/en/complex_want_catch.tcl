## IMP plugin: want catcher
#
# Jolly sneaky.. if someone wants something, we'll remember it for ourselves :)
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

IMP_plugin_add_complex "want-catch" "i (want|need) (.+)" 100 IMP_plugin_complex_want_catcher "en"
IMP_plugin_add_complex "mmm-catch" "^mmm+ (.+)" 100 IMP_plugin_complex_mmm_catcher "en"
IMP_plugin_add_complex "noun-catch" {[[:<:]](?:a|an|the) ([[:alpha:]]+)} 100 IMP_plugin_complex_noun_catcher "en"

proc IMP_plugin_complex_want_catcher { nick host handle channel text } {
  if [regexp -nocase "i (want|need) (?!to)(.+? )" $text matches verb item] {
    #that's a negative lookahead ---^
    IMP_flood_undo $nick
    IMP_abstract_add "sillyThings" $item
  }
}

proc IMP_plugin_complex_mmm_catcher { nick host handle channel text } {
  if [regexp -nocase "^mmm+ (.+?) " $text matches item] {
    IMP_flood_undo $nick
    IMP_abstract_add "sillyThings" $item
  }
}

proc IMP_plugin_complex_noun_catcher { nick host handle channel text } {
  if [regexp -nocase {[[:<:]](a|an|the|some) ([[:alpha:]]+)( [[:alpha:]]+[[:>:]])?} $text matches prefix item second] {
    IMP_flood_undo $nick
    set item [string tolower $item]

    if [regexp "(ly)$" $item] {
      return 0
    }
    
    if [regexp "(ing|ed)$" $item] {
      if {$second == ""} {
        return 0
      }
      append item $second
    }

    set prefix [string tolower $prefix]
    if {$prefix == "the"} {
      if {[string range $item end end] == "s"} {
        set prefix "some"
      } else {
        set prefix "a"
      }
    }
    IMP_abstract_add "sillyThings" "$prefix $item"
  }
}
