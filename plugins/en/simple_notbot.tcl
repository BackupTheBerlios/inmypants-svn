## IMP plugin: not a bot

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

IMP_plugin_add_simple "notbot" "%botnicks('s| is) a bot" 60 [list "%VAR{notbots}"] "en"

IMP_plugin_add_simple "arebot" "((is %botnicks a bot)|(are you a bot,? %botnicks)|(^%botnicks%:? are you a bot))" 60 [list "%VAR{nos}"] "en"

set notbots {
  "no I'm not"
  "am not :("
  "am not"
  "LIES."
  "SILENCE%colen"
  "LIES, ALL LIES%|unless a witness steps forward"
  "/smacks %%%|shut up"
  "shh%|sekrit"
}
