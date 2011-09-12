#
#
#                Password Gorilla for Android
# 
#
# ----------------------------------------------------------------------
# pwsafe-db.hcl: holds password records, and provides an API to them
# ----------------------------------------------------------------------
#
# Android port written for Hecl (jars/j2se/Hecl.jar)
#
# Code is based on pwsafe-db.tcl written by Frank Pilhofer
#
# License: GNU
# (c) Zbigniew Diaczyszyn 2011
#

    #
    # field types:
    #
    # Name                    Field Type    Value Type   Comments
    # -----------------------------------------------------------
    # UUID                        1         UUID
    # Group                       2         Text         [2]
    # Title                       3         Text
    # Username                    4         Text
    # Notes                       5         Text
    # Password                    6         Text
    # Creation Time               7         time_t
    # Password Modification Time  8         time_t
    # Last Access Time            9         time_t
    # Password Lifetime           10        time_t       [4]
    # Password Policy             11        4 bytes      [5]
    # Last Mod. time              12        time_t
    # URL                         13        Text
    # Autotype                    14        Text
    #
    # [2] The "Group" is meant to support displaying the entries in a
    # tree-like manner. Groups can be heirarchical, with elements separated
    # by a period, supporting groups such as "Finance.credit cards.Visa".
    # This implies that periods entered by the user will have a backslash
    # prepended to them. A backslash entered by the user will have another
    # backslash prepended.
    #
    # [4] Password lifetime is in seconds, and a value of zero means
    # "forever".
    #
    # [5] Unused so far
    #
    # Not all records use all fields. pwsafe-2.05 only seems to use the
    # UUID, Group, Title, Username, Nodes and Password fields. I have
    # omitted some documentation for the other fields.
    #
    # For more detail, look at the pwsafe documentation, or, better yet,
    # the pwsafe source code -- the documentation seems to be based on
    # a good helping of wishful thinking; e.g., it says that all Text
    # fields are Unicode, but they are not.
    #

    #
    # Preferences: {type number name registry-name default persistent}
    #
    # Need to keep in sync with pwsafe's corelib/PWSPrefs.cpp
    #

proc db::createRecord {} {
  global recordnumbers nextrecordnumber
  
	set nn [incr $nextrecordnumber]
	lappend $recordnumbers $nn
	return $nn
} ;# end proc

proc db::encryptField { value } {
  return $value
} ;# end of proc

proc db::decryptField { value } {
  return $value
} ;# end of proc

proc db::setFieldValue {rn field value} {
  global records
  # encrypt the value and store it in records
  
	## if {![existsRecord $rn]} {
	    # error "record $rn does not exist"
	# }

	if { or [= $field 2] \
          [= $field 3] \
          [= $field 4] \
          [= $field 5] \
          [= $field 6] } {
	    # store text fields utf8-encoded
	    ## set records($rn,$field) [db::encryptField \
					 # [encoding convertto utf-8 $value]]
      hset $records "$rn,$field" [db::encryptField $value]
	} else {
	    hset $records "$rn,$field" [db::encryptField $value]
	}
}

proc db::getFieldValue {rn field} {
  global records
	## if {![info exists records($rn,$field)]} {
	    # if {![existsRecord $rn]} {
		# error "record $rn does not exist"
	    # }
	    # error "record $rn does not have field $field"
	# }

	## if {$field == 2 || $field == 3 || $field == 4 || \
		# $field == 5 || $field == 6} {
	    # # text fields
	    # return [encoding convertfrom utf-8 \
			# [decryptField $records($rn,$field)]]
	# }
	    
	return [db::decryptField [hget $records $rn,$field]]
} ;# end proc

proc db::setPreferencesFromString {newPreferences} {
	#
	# String is of the form "X nn vv X nn vv..." Where X=[BIS]
	# for binary, integer and string, resp., nn is the numeric
	# value of the enum, and vv is the value, {1.0} for bool,
	# unsigned integer for int, and quoted string for String.
	# Only values != default are stored.
	#

  puts "newPreferences: [hexToAsc $newPreferences]"
} ;# end proc

proc db::setHeaderField {field value} {
  global header

  if { = $field 2} {
    db::setPreferencesFromString $value
    return
	}
  hset $header $field $value
  
} ;# end proc

# ----------------------------------------------------------------------
#                               main
# ----------------------------------------------------------------------
    set utf8Default 0
    set utf8PrefNumber 24

    set allPreferences [list \
			[list B 0 AlwaysOnTop alwaysontop 0 1] \
			[list B 1 ShowPWDefault showpwdefault 0 1] \
			[list B 2 ShowPWInList showpwinlist 0 1] \
			[list B 3 SortAscending sortascending 1 1] \
			[list B 4 UseDefUser usedefuser 0 1] \
			[list B 5 SaveImmediately saveimmediately 0 1] \
			[list B 6 PWUseLowercase pwuselowercase 1 1] \
			[list B 7 PWUseUppercase pwuseuppercase 1 1] \
			[list B 8 PWUseDigits pwusedigits 1 1] \
			[list B 9 PWUseSymbols pwusesymbols 0 1] \
			[list B 10 PWUseHexDigits pwusehexdigits 0 1] \
			[list B 11 PWEasyVision pweasyvision 0 1] \
			[list B 12 DontAskQuestion dontaskquestion 0 1] \
			[list B 13 DeleteQuestion deletequestion 0 1] \
			[list B 14 DCShowsPassword DCShowsPassword 0 1] \
			[list B 15 DontAskMinimizeClearYesNo DontAskMinimizeClearYesNo 0 1] \
			[list B 16 DatabaseClear DatabaseClear 0 1] \
			[list B 17 DontAskSaveMinimize DontAskSaveMinimize 0 1] \
			[list B 18 QuerySetDef QuerySetDef 1 1] \
			[list B 19 UseNewToolbar UseNewToolbar 1 1] \
			[list B 20 UseSystemTray UseSystemTray 1 1] \
			[list B 21 LockOnWindowLock LockOnWindowLock 1 1] \
			[list B 22 LockOnIdleTimeout LockOnIdleTimeout 1 1] \
			[list B 23 EscExits EscExits 1 1] \
			[list B 24 IsUTF8 isutf8 0 1] \
			[list I 0 Column1Width column1width -1 0] \
			[list I 1 Column2Width column2width -1 0] \
			[list I 2 Column3Width column3width -1 0] \
			[list I 3 Column4Width column4width -1 0] \
			[list I 4 SortedColumn sortedcolumn 0 1] \
			[list I 5 PWLenDefault pwlendefault 8 1] \
			[list I 6 MaxMRUItems maxmruitems 4 1] \
			[list I 7 IdleTimeout IdleTimeout 5 1] \
			[list S 0 CurrentBackup currentbackup "" 1] \
			[list S 1 CurrentFile currentfile "" 0] \
			[list S 2 LastView lastview "list" 1] \
			[list S 3 DefUserName defusername "" 1] ]

    #
    # Internal data:
    #
    # header is an array, the index is <type>
    #
    # records is an array, the index is <record number>,<type>
    # all the values stored in this array are stored encrypted
    #
    # Record number and type are both integers. The type has the value
    # of the type byte, as identified in the pwsafe "documentation."
    # The value of the array element is the field value.
    #
    # recordnumbers is a list of all record numbers that are available
    # in the records array
    #

	set nextrecordnumber 0
	set recordnumbers [list]
  set records [hash [list]]
	# set engine [namespace current]::[itwofish::ecb #auto \
		# [pwsafe::int::randomString 16]]
    # Typical callers of SecureRandom invoke the following methods to retrieve random bytes:
# 
      # SecureRandom random = new SecureRandom();
      # byte bytes[] = new byte[20];
      # random.nextBytes(bytes);
 
	# set password [encryptField $password_]
	set preferences [hash [list]]
  set header [hash [list]]
	set keyStretchingIterations 2048
	set warningsDuringOpen [list]

puts "db::* loaded"
