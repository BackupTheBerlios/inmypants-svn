## IMP plugin: bhar (etc)

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

IMP_plugin_add_complex "bhar" "^((((a|(bo*)|(gro+))r*)*ha?r+)|(ar+)( $botnicks)?)$" 50 IMP_plugin_complex_bhar "en"

proc IMP_plugin_complex_bhar { nick host handle channel text } {
  set arr [IMP_plugins_settings_get "complex:bhar" "contents" $channel $nick]
  if {$arr == ""} {
    IMP_plugins_settings_set "complex:bhar" "contents" $channel $nick $text
    IMPDoAction $channel $nick "%VAR{arrs}"
  }  
}

set arrs {
  "bhar"
  "boohar"
  "a%REPEAT{3:5:r}ha%REPEAT{3:6:r}"
  "r"
  "a%REPEAT{2:5:r}"
  "graha%REPEAT{3:5:r}"
  "bhar %%"
  "boohar %%"
  "a%REPEAT{3:5:r}ha%REPEAT{3:6:r} %%"
  "r %%"
  "a%REPEAT{2:5:r} %%"
  "graha%REPEAT{3:5:r} %%"
}
