## IMP simple plugin: here?

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

IMP_plugin_add_simple "here" "^any ?(one|body) (here|alive|talking)" 40 "%VAR{here_responses}" "en"

# abstracts

set here_responses {
  "%VAR{nos}"
}
