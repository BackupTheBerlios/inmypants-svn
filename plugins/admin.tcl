## IMP plugins loader: admin

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
  IMP_putloglev 2 * "IMP: loading admin plugins language = $language"
  set files [glob -nocomplain "$IMPPlugins/$language/admin_*.tcl"]
  foreach f $files {
    IMP_putloglev 1 * "IMP: loading ($language) admin plugin file $f"
    catch {
      source $f
    }
  }
}

# load default admin stuff regardless
set files [glob -nocomplain "$IMPPlugins/admin_*.tcl"]
foreach f $files {
  IMP_putloglev 1 * "IMP: loading (generic) admin plugin file $f"
  catch {
    source $f
  }
}
