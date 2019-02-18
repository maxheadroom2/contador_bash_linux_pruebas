#! /bin/bash

export MAIN_DIALOG='
<vbox>
  <frame Tree With Actions>
    <text>
      <label>
"The column 0 is the stoc icon name. However the exported column is the
1st column, so you see the first text column printed to the standard
output."
      </label>
    </text>
    <tree rules_hint="true" exported_column="1">
      <label>One     | Two     | Three </label>
      <item stock="gtk-yes">r1c1|r1c2|r1c3</item>
      <item stock="gtk-no">r2c1|r2c2|r2c3</item>
      <item stock="gtk-no">r3c1|r3c2|r3c3</item>
      <variable>TREE</variable>
      <height>100</height><width>200</width>
      <action>echo action[Double Click]: $TREE</action>
      <action signal="button-press-event">echo button-press-event[BUTTON=$BUTTON]: $TREE</action>
      <action signal="button-release-event">echo button-release-event[BUTTON=$BUTTON]: $TREE</action>
      <action signal="cursor_changed">echo cursor_changed: $TREE</action>
    </tree>
  </frame>
  <frame Another Tree With Actions>
    <tree rules_hint="true">
      <label>One     | Two     | Three </label>
      <item>r1c1|r1c2|r1c3</item>
      <item>r2c1|r2c2|r2c3</item>
      <item>r3c1|r3c2|r3c3</item>
      <variable>OTHERTREE</variable>
      <height>100</height><width>200</width>
      <action>echo action[Double Click]: $OTHERTREE</action>
      <action signal="button-press-event">echo button-press-event[BUTTON=$BUTTON]: $TREE</action>
      <action signal="button-release-event">echo button-release-event[BUTTON=$BUTTON]: $TREE</action>
      <action signal="cursor_changed">echo cursor_changed: $OTHERTREE</action>
    </tree>
  </frame>
</vbox>
'

gtkdialog --program=MAIN_DIALOG
