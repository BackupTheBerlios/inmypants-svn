## IMP complex plugin: hello
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

IMP_plugin_add_complex "z-activate" "(activate|increase power to)" 100 IMP_plugin_complex_activate "en"

proc IMP_plugin_complex_activate { nick host handle channel text } {
  global botnicks
  if [regexp -nocase "^(${botnicks}:?,? )?(activate|increase power to) (.+)$" $text matches bot bot2 verb item] {
    if {($bot != "") || ([IMP_interbot_me_next $channel] && [rand 2])} {
      set item [IMP_uncolen $item]
      set item [string trim $item]
      if [string match "*." $item] {
        regsub "(.+)\.$" $item {\1} item
      }
      IMPDoAction $channel $item "%VAR{activateses}"
    }
    return 1
  }
}

set activateses {
  "/increases power to %%"
  "/brings %% online"
  "%% engaged%colen"
  "/activates %%"
  "%% to maximum%colen"
}
