## IMP complex plugin: techsupport
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

proc IMP_plugin_complex_techs { nick host handle channel text } {
  IMP_flood_undo $nick
  if [IMP_interbot_me_next $channel] {
    IMPDoAction $channel $nick "%%: %VAR{tech_answer}"
  }
  return 1
}

IMP_plugin_add_complex "techsup" "^!techsupport$" 100 IMP_plugin_complex_techs "en"

# abstracts

set tech_software {
  "windows"
  "xml spy"
  "installshield"
  "notepad"
  "media player"
  "wise for windows"
  "goldmine"
  "gmClass"
  "vmware"
  "the internet"
}
IMP_abstract_register "tech_software"
IMP_abstract_batchadd "tech_software" $tech_software

set tech_answer {
  "I just bought %VAR{tech_software} and I can't get it to %VAR{tech_problem}, I've tried %VAR{tech_tries} and it still won't work"
  "I've just got %VAR{tech_software}, and it won't %VAR{tech_problem}. I've tried everything including %VAR{tech_tries} but nothing helps"
  "I hear you do books by %VAR{answerWhos}, can you sell me one?"
  "I need a bit of software to %VAR{tech_functions} %VAR{sillyThings}"
}
IMP_abstract_register "tech_answer"
IMP_abstract_batchadd "tech_answer" $tech_answer

set tech_problem {
  "install"
  "work"
  "stop being purple"
  "stop rendering pictures of %VAR{sillyThings}"
  "connect to the network"
  "stop telling me 'you are too stupid to use this software'"
  "make the tea"
  "download pornography"
  "connect"
}
IMP_abstract_register "tech_problem"
IMP_abstract_batchadd "tech_problem" $tech_problem

set tech_tries {
  "sacrificing my boss"
  "reinstalling it"
  "going to a voodoo witch doctor"
  "covering it in honey"
  "putting the CD in the other way up"
  "putting the CD in the floppy drive"
  "smearing it with mud"
  "running it on my Mac"
  "rebooting"
}
IMP_abstract_register "tech_tries"
IMP_abstract_batchadd "tech_tries" $tech_tries

set tech_functions {
  "virus-scan"
  "validate"
  "manage"
  "install"
  "clean"
  "update"
  "audit"
}
IMP_abstract_register "tech_functions"
IMP_abstract_batchadd "tech_functions" $tech_functions
