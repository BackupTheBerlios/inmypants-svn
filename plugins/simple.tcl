## IMP plugins loader: simple
#

###############################################################################
# This is an IMP plugin
# IMP is based on bMotion.
# IMP is Copyright (C) Dave Wickham 2004
# bMotion is Copyright (C) James Michael Seward 2000-2002
#
# This program is covered by the GPL, please refer the to LICENCE file in the
# distribution; further information can be found in the headers of the scripts
# in the modules directory.
###############################################################################

set languages [split $IMPSettings(languages) ","]
foreach language $languages {
  IMP_putloglev 2 * "IMP: loading simple plugins language = $language"
  set files [glob -nocomplain "$IMPPlugins/$language/simple_*.tcl"]
  foreach f $files {
    IMP_putloglev 1 * "IMP: loading ($language) simple plugin file $f"
    catch {
      source $f
    }
  }
}
