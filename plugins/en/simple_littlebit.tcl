## IMP plugin: not even a little bit?

###############################################################################
# This is a IMP plugin
# IMP is Copyright (C) Dave Wickham
# IMP is based on bMotion
# bMotion is Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

IMP_plugin_add_simple "littlebit" "(what, )?not even a little bit" 40 [list "%VAR{goonthens}"] "en"

set goonthens {
  "sssh sekrit"
  "go on then"
  "oh go on then"
  "ok then, but don't tell anyone"
}
