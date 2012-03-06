# create a GUI skeleton for Password Gorilla on Android
#
# (c) 2012 Zbigniew Diaczyszyn
# License: GPL
#
# clickable listview of groups and logins
# onClickGroup: new activity with new listview
# onClickLogin: new activity with login contents
# add menu: find
# Note: There is only one main activity with different layouts
# Calling [activity] means creating a subhecl class which is already
# declared in AndroidManifest.xml

proc openDialog {} {
  # screen #1: Open - New - Exit
  
  set context [activity]
  androidlog "+++ context of openDialog: $context"
  set layoutparams [linearlayoutparams -new {FILL_PARENT WRAP_CONTENT}]
  
  set openDialogLayout [linearlayout -new $context -layoutparams $layoutparams]
  $openDialogLayout setorientation VERTICAL
  # Note: view orientation can be changed by click (KEYPAD 7 or 9)
  # better to provide also a landscape orientation
 
  $openDialogLayout addview [textview -new $context -text "\n Select a task:\n" \
    -layoutparams $layoutparams -textsize 14.0]
  set openButton [button -new $context -text "Open" \
    -layoutparams $layoutparams]
  set newButton [button -new $context -text "New" \
    -layoutparams $layoutparams]
  set exitButton [button -new $context -text "Exit" \
    -layoutparams $layoutparams]
    
  $openButton setonclicklistener [callback -new [list [ list openCallback "open" ]]]
  $newButton setonclicklistener [callback -new [list [ list openCallback "new" ]]]
  $exitButton setonclicklistener [callback -new [list [ list openCallback "exit" ]]]

  $openDialogLayout addview $openButton
  $openDialogLayout addview $newButton
  $openDialogLayout addview $exitButton
         
 [activity] setcontentview $openDialogLayout

}

proc openCallback { option button } {
  global context
  # androidlog "you pressed option: $option"
  # alert "You have pressed option: $option"
  if { eq $option "open" } { newActivity $context fileSelect }
}

proc selectedFileCallback { oldcontext listview textview positionId rowId } {
    myActivity $oldcontext [list openDB $positionId]
}

proc openDB { itemPos } {

  set context [activity]
  androidlog "+++ context of openDB: $context"
  [activity] settitle "Password Gorilla - View Database"
  set layoutparams [linearlayoutparams -new {FILL_PARENT WRAP_CONTENT} ]
  set viewDBLayout [linearlayout -new $context -layoutparams $layoutparams]
  $viewDBLayout setorientation VERTICAL
  $viewDBLayout addview [textview -new $context \
       -text " Selected item#: $itemPos" \
       -layoutparams $layoutparams -textsize 12.0 ]
  [activity] setcontentview $viewDBLayout
}

proc fileSelect {} {
  # screen 2: filepath - listview of file names
  
  # get the filenames
  set path "/sdcard"
  file.cd $path
  # androidlog "+++ cwd [file.getcwd]"
  set fileNames [file.list "./"]
  linsert $fileNames 0 "../"
  # file.isdirectory -> append /
  # append "../"
  # puts $path
  
  # activity + layout
  set context [activity]
  androidlog "+++ context of fileSelect: $context"
  [activity] settitle "Password Gorilla - Select Database"
  
  set layoutparams [linearlayoutparams -new {FILL_PARENT WRAP_CONTENT} ]
  set filesLayout [linearlayout -new $context -layoutparams $layoutparams]
  $filesLayout setorientation VERTICAL

  set filesListview [basiclist $context $fileNames \
    -layoutparams $layoutparams]
  $filesListview requestfocus
  
  set tv [textview -new $context \
       -text " Path: $path" \
       -layoutparams $layoutparams -textsize 12.0 ]
  # Note: Option is case-sensivte. "settypeface" will cause error!
  $tv setTypeface 1 1     ;# NORMAL BOLD
  $tv setTextColor -256   ;# yellow
  # Note: background in textview can only be set by XML definition file
  
  $filesLayout addview $tv
  $filesLayout addview $filesListview
  
  set selectFileCallback [callback -new [list [list selectedFileCallback $context]]]
  $filesListview setonitemclicklistener $selectFileCallback

  [activity] setcontentview $filesLayout
}

proc MenuSetup {} {

  proc MenuCallBack {menu} {
    $menu add "Find"
    $menu add "Preferences"
    $menu add "Copy"
    $menu add "Edit"
    $menu add "About"
  }

  [activity] -field onCreateOptionsMenuCallBack MenuCallBack

  # Sets up the actual callback code for when a menu item is
  # selected.

  proc OptionsSelected {menuitem} {
    alert "menuitem pressed is: $menuitem"
  }

  [activity] -field onOptionsItemSelectedCallBack OptionsSelected
}

proc itemview {  } {
  
  set textsize 12.0
  set context [activity]
  [activity] settitle "Login content"
  set layoutparams [linearlayoutparams -new {FILL_PARENT WRAP_CONTENT}]

  set scroll [scrollview -new $context -layoutparams $layoutparams]

  set layout [linearlayout -new $context -layoutparams $layoutparams]
  $layout setorientation VERTICAL

  $scroll addview $layout
  [activity] setcontentview $scroll

  $layout addview [textview -new $context \
       -text "Title: title" \
       -layoutparams $layoutparams -textsize $textsize]
} ;# end of proc

# for parameters see: android.widget.AdapterView.OnItemClickListener
proc selectItem {args} {
  global alertdialog
  # androidlog "position $position id $id"
  androidlog "args: $args"
  set itemview [lindex $args 1]
  # id = long
  set groupid [int [lindex $args 3]]
  incr $groupid
  androidlog "groupid: $groupid"
  # androidlog "groupid [classof $groupid]"
  # $itemview settext "Group $groupid\n  Title: login\n  Username: user"
  # alert "Group $groupid pressed"
  itemview
}

proc main {} {
  global context
  
  set context [activity]
  [activity] settitle "Password Gorilla"
  
  openDialog
  
  # MenuSetup
  
  # java android.app.AlertDialog alertdialog
  # set alertdialog [alertdialogbuilder -new $context -setmessage "hallo" ]

}

main

# Fails:
# String styledText = "This is <font color='red'>simple</font>.";
# textView.setText(Html.fromHtml(styledText), TextView.BufferType.SPANNABLE);


