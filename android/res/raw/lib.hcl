# Load some extra goodies here.

java org.hecl.Interp interp
java org.hecl.android.HeclHandler heclhandler
java android.os.Message message

# Library of helper procedures.

proc expand {toexpand lst} {
    # This could be replaced by either an expand command, or syntax.
    set res [list]
    set i 0
    foreach el $lst {
	if { = $i $toexpand } {
	    foreach elem $el {
		lappend $res $elem
	    }
	} else {
	    lappend $res $el
	}
	incr $i
    }
    return $res
}

# basicspinner --
#
#	Create a simple spinner using default pieces.

proc basicspinner {context lst args} {
    set aa [arrayadapter -new \
		[list $context \
		     [reslookup android.R.layout.simple_spinner_item] $lst]]

    $aa setdropdownviewresource \
	[reslookup android.R.layout.simple_spinner_dropdown_item]

    set cmd [expand 3 [list spinner -new $context $args]]
    set spinner [eval $cmd]
    $spinner setadapter $aa
    return $spinner
}

# basiclist --
#
#	Create a simple listview using default pieces.

proc basiclist {context lst args} {
    set aa [arrayadapter -new \
		[list $context \
		     [reslookup R.layout.list_item] \
		     $lst]]

    set cmd [expand 3 [list listview -new $context $args]]
    set lview [eval $cmd]

    $lview setadapter $aa
    return $lview
}

# newActivity --
#
#	Create a new activity from the old $context, and execute $code
#	in it.

proc newActivity { name context code} {
  # name -- name of activity like declared in AndroidManifest.xml
  # context -- oldcontext of parent activity
  # code -- code to be executed, in general a procedure

    set h [$name -new [list]]
    set intent [intent -new [list]]
    $intent setclass $context [$h getclass]
    $h setmailbox $code
    $context startActivity $intent
}

# proc newActivity {context code} {
    # set h [subhecl -new [list]]
    # set intent [intent -new [list]]
    # $intent setclass $context [$h getclass]
    # $h setmailbox $code
    # $context startActivity $intent
# }

proc myActivity {context code} {
    set h [logincontent -new [list]]
    set intent [intent -new [list]]
    $intent setclass $context [$h getclass]
    $h setmailbox $code
    $context startActivity $intent
}

# contentQuery --
#
#	Run a query and return a cursor object.

proc contentQuery {uri} {
    java android.net.Uri uri
    return [[activity] managedQuery [uri parse $uri] [null] [null] [null]]
}


# gui --
#
#	Posts a script to the main, GUI thread.  Use this if you need
#	to run gui events in 'after' events.

proc gui {code} {
    set hh [[activity] getHandler]
    set msg [message -new [list]]
    $msg -field obj $code
    set err ""
    catch {
	$hh sendmessage $msg
    } err
    if { strlen $err } {
	androidlog "GUI sendmessage error: $err"
    }
}
