## IMP plugins loader: complex

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

set languages [split $IMPSettings(languages) ","]
foreach language $languages {
  IMP_putloglev 2 * "IMP: loading complex plugins language = $language"
  set files [glob -nocomplain "$IMPPlugins/$language/complex_*.tcl"]
  foreach f $files {
    IMP_putloglev 1 * "IMP: loading ($language) complex plugin file $f"
    catch {
      source $f
    }
  }
}
