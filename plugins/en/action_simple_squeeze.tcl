# IMP simple action plugin squeeze

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

#                         name  regexp            %   responses
IMP_plugin_add_action_simple "squeeze" "^(squeezes|beeps|honks|knijpt( in)?) %botnicks" 100 [list "%VAR{honks}"] "en"

set honks {
  "/honks"
  "/beeps"
  "beep beep"
  "honk honk"
}
