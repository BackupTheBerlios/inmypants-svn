## IMP output plugin: english
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

IMP_plugin_add_output "english" IMP_plugin_output_english 1 "en"


#    Tries to straighten out b0rk3d English
#

proc IMP_plugin_output_english { channel line } {
  set line [string trim $line]

  # me at start of line is WRONG
  #
  # me ___s --> /me
  # me __[^s] --> I
  
  if [regexp -nocase {^me ([^ ]+) (.+)} $line matches first rest] {
    IMP_putloglev 2 * "IMP: output:english detected a me* line"
    if [regexp -nocase "s$" $first] {
      #use /me
      set line "/$first $rest"
    } else {
      #use I
      set line "I $first $rest"
    }
  }

  #"a" before a vowel needs to be "an"
  regsub -nocase -all {[[:<:]](a) ([aeiou].+)[[:>:]]} $line {\1n \2} line

  if {[rand 100] > 60} {
    #captials at start, . at end
    if [regexp {^([a-z])(.+)} $line matches first rest] {
      set line "[string toupper $first]$rest"
    }

    if [regexp -nocase {^[a-z].*[a-z0-9]$} $line] {
      append line "."
    }
  }

  return $line
}
