# IMP: admin plugin file for language mangement

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

proc IMP_plugin_admin_language { handle idx { arg "" }} {
  global IMPSettings

  if [regexp -nocase {remove (.+)} $arg matches lang] {
    putidx $idx "Removing language $lang...\r"
    set langs [split $IMPSettings(languages) ","]
    set newlangs [list]
    foreach language $langs {
      if {$lang != $language} {
        lappend newlangs $language
      }
    }
    if {[llength $newlangs] == 0} {
      set newlangs [list "en"]
    }

    set newlangstring [join $newlangs ","]

    set IMPSettings(languages) $newlangstring

    putidx $idx "IMP: new languages are $newlangstring ... rehash to load"

    return 0
  }

  if [regexp -nocase {add (.+)} $arg matches lang] {
    putidx $idx "Adding language $lang...\r"
    append IMPSettings(languages) ",$lang"
    putidx $idx "IMP: new languages are $IMPSettings(languages) ... rehash to load"
    return 0
  }

  if [regexp -nocase {use (.+)} $arg matches lang] {
    putidx $idx "Switching languages to $lang..."
    if [regexp $lang $IMPSettings(languages)] {
      global IMPInfo
      set IMPInfo(language) $lang
    } else {
      putidx $idx "Error! Language $lang not loaded"
    }
    return 0
  }

  #else list langs
  set langs "IMP loaded languages: "
  foreach lang $IMPSettings(languages) {
    append langs "$lang  "
  }
  global IMPInfo
  putidx $idx "$langs\r"
  putidx $idx "Current language is $IMPInfo(language)\r"
}

# register the plugin
IMP_plugin_add_admin "lang" "^lang(uage)?" n "IMP_plugin_admin_language" "any"
