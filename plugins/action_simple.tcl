# IMP simple action plugins

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
#IMP_plugin_add_action_simple "licks" "(licks|bites) %botnicks" 100 [list "%VAR{rarrs}"]
IMP_plugin_add_action_simple "moo" "^(goes |does a )?moo+s?( at %botnicks)?" 40 [list "%VAR{moos}"] "all"


# now autoload the rest from plugins/action_simple_*.tcl

set files [glob -nocomplain "$IMPPlugins/action_simple_*.tcl"]
foreach f $files {
  IMP_putloglev 1 * "IMP: loading simple action plugin file $f"
  catch {
    source $f
  }
}
