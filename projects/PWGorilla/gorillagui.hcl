# create a GUI skeleton for Password Gorilla on Android
#
# (c) 2012 Zbigniew Diaczyszyn
# License: GPL
#
# openDialog
# clickable listview of groups and logins
# onClickGroup: new activity with new listview
# onClickLogin: new activity with login contents
# add menu: find

proc openDialog {} {
  # screen #1: Open - New - Exit
  
  set context [activity]
  set layoutparams [linearlayoutparams -new {FILL_PARENT WRAP_CONTENT}]
  
  set openDialogLayout [linearlayout -new $context -layoutparams $layoutparams]
  $openDialogLayout setorientation VERTICAL
  # Note: view orientation can be changed by click
  # better to provide also horizontal orientation
 
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
  # androidlog "you pressed option: $option"
  alert "You have pressed option: $option"
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
  global alertdialog context
  
  [activity] settitle "Password Gorilla"
  
  openDialog
  
  # ------------------
  # set lview [basiclist $context [list "Group 1" "Group 2" "Group 3"] \
         # -layoutparams $layoutparams]
  # 
  # $lview requestfocus
  # $layout addview $lview

  # callback is evaluating a vector
  # set handleItem [callback -new [list [list selectItem]]]
  # $lview setonitemclicklistener $handleItem
  # 
  # [activity] setcontentview $layout

  # MenuSetup
  
  # java android.app.AlertDialog alertdialog
  # set alertdialog [alertdialogbuilder -new $context -setmessage "hallo" ]

}

main


# $tv settext "Gruppenliste:\nbasiclist"
# String styledText = "This is <font color='red'>simple</font>.";
# textView.setText(Html.fromHtml(styledText), TextView.BufferType.SPANNABLE);


