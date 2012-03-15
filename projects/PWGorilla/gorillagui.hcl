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
  if { eq $option "open" } { newActivity subhecl $context selectFile }
}

proc selectFileCallback { aa tv oldcontext listview textview positionId rowId } {
  
  global path fileNames
  
  set file [$aa getItem $positionId]
  # error-check:
  # if { eq $file ""}
  # file.exists
  set pathfile [file.join [list $path $file]]

androidlog "+++ fileNames: $fileNames"
androidlog "+++ file: $file"
androidlog "+++ getItem: [$aa getItem $positionId]"

  if { = [file.isdirectory $pathfile] 1 } {
    
    # go to parent folder?
    if { eq $file "../" } {
      set splitted [file.split $path]
      set parentdir  [lrange $splitted 0 [- [llen $splitted] 2]]
      set path [file.join $parentdir]
      file.cd $path
      set fileNames [file.list $path]
      $aa clear
      
      foreach name $fileNames {
        if { = [file.isdirectory $name] 1} {
          append $name "/"
        }
        $aa add $name
      }
      
    } else {      
      # change to new directory
      
      # get the new path
      set path $pathfile
      file.cd $path
      set fileNames [file.list $path]
      
      $aa clear
      
      foreach name $fileNames {
        if { = [file.isdirectory $name] 1} {
          append $name "/"
        }
        $aa add $name
      }
    }
    
    if { ne $path "/" } {
      $aa insert "../" 0
    }
    
    $tv setText "Path: $path"
  
  } else {
    # newActivity logincontent $oldcontext [list openDB $positionId]
    androidlog "+++ selectedDatabase: $file , $path"
  }
  
  return
}

proc openDB { itemPos } {
  # itemPos - Position of clicked item in the listview
  
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

proc configureFilesLayout { layout } {
  androidlog "--- layout: $layout"
  $layout removeAllViews
}

proc selectFile {} {
  # screen 2: filepath - listview of file names
  
  global path fileNames
  
  # get the filenames
  set path "/sdcard"
  file.cd $path
  # androidlog "+++ cwd [file.getcwd]"
  set fileNames [file.list $path]
  
  # activity + layout
  set context [activity]
  androidlog "+++ context of selectFile: $context"
  [activity] settitle "Password Gorilla - Select Database"
  
  set layoutparams [linearlayoutparams -new {FILL_PARENT WRAP_CONTENT} ]
  set filesLayout [linearlayout -new $context -layoutparams $layoutparams]
  $filesLayout setorientation VERTICAL
  
  # androidlog "--- filesLayout: $filesLayout"
  # configureFilesLayout $filesLayout
  # nedds: filesLayout layoutparams context fileNames path

  set filesAdapter [arrayadapter -new \
		[list $context [reslookup R.layout.list_item] ] ]
  
  $filesAdapter add "../"
  
  foreach file $fileNames {
    # androidlog "+++ $file isdirectory [file.isdirectory $file]"
    # mark the file as directory directly in the adapter
    if { = [file.isdirectory $file] 1} {
      append $file "/"
    }
    $filesAdapter add $file
  }
  
  set filesListview [listview -new $context -layoutparams $layoutparams]
  
  # set filesListview [basiclist $context $fileNames \
    # -layoutparams $layoutparams]
  $filesListview setAdapter $filesAdapter
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
  
  $filesListview setonitemclicklistener \
   [callback -new [list [list selectFileCallback $filesAdapter $tv $context]]]
  # ---------------------------------

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


