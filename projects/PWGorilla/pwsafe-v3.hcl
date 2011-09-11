#
#                Password Gorilla for Android
# 
# ----------------------------------------------------------------------
# pwsafe::v3::reader: reads an existing file from a stream
# ----------------------------------------------------------------------
#
# Android port written for Hecl (jars/j2se/Hecl.jar)
#
# Code is based on pwsafe-v3.tcl written by Frank Pilhofer
#
# License: GNU
# (c) Zbigniew Diaczyszyn 2011
#

# see pwsafe-int.tcl
#
# Password Safe 3 uses a "stretched key" of the user's passphrase and
# the SALT, as defined by the hash-function-based key stretching
# algorithm in http://www.schneier.com/paper-low-entropy.pdf
# (Section 4.1), with SHA-256 as the hash function, and a variable
# number of iterations that is stored in the file.
#

proc toLittleEndian { bigEndian } {
  # bigEndian - accepts big Endian hex string
  # returns little Endian hex string
  set le ""
  
  for { set i 0 } { < $i [strlen $bigEndian] } { incr $i 2 } {
    set byte "[strrange $bigEndian $i [+ $i 1]]"
    set le [append $byte $le]
  }

  return $le
}

proc computeStretchedKey {salt password iterations} {

  set i "[hex $password]$salt"
  set Xi [sha256 $i]
  
  for {set i 0} { < $i $iterations} {incr $i} {
    set Xi [sha256 $Xi]
  }
  return $Xi
    
}

proc readHeaderFields { crypto } {
  global source
  
  # fh - filehandler
  # while {![$source eof]}
  # while {file.readable} {
  # }
puts "crypto0: $crypto"  
  while { true } {
    set crypto [readField $crypto]
puts "crypto1: $crypto"  
    # set fieldType [lindex $field 0]
    # set fieldValue [lindex $field 1]
    set fieldType [hget $crypto fieldType]
    set fieldValue [hget $crypto fieldData]

    if { eq $fieldType "" } { puts eof; break } ;# eof

    if { = $fieldType 255} {
      break
    }

    # sha2::HMACUpdate $hmacEngine $fieldValue
    set value [hget $crypto hmac]
    append $value $fieldValue
    hset $crypto hmac $value

    #
    # Format the header's field type, if necessary
    #

    if { = $fieldType 0 } {
        #
        # Version
        #
        set fieldValue [list [strrange $fieldValue 2 3] [strrange $fieldValue 0 1] ]
    } elseif { = $fieldType 1 } {
        #
        # UUID
        #
        puts uuid
        # binary scan $fieldValue H* tmp
        # set fieldValue [string range $tmp 0 7]
        # append fieldValue "-" [string range $tmp 8 11]
        # append fieldValue "-" [string range $tmp 12 15]
        # append fieldValue "-" [string range $tmp 16 19]
        # append fieldValue "-" [string range $tmp 20 31]
    }

    # $db setHeaderField $fieldType $fieldValue
    # puts "db setHeaderField $fieldValue"

  } ;# end while

  #
	# If there is no version header field, then add one. The rest of
	# the code uses it to detect v3 files, assuming v2 otherwise.
	#

	# if {![$db hasHeaderField 0]} {
	    # $db setHeaderField 0 [list 3 0]
	# }

  return $crypto
      
} ;# end of proc

proc readField { crypto } {
  global source

	# first block contains field length and type

	set encryptedFirstBlock [$source readhex 16]
# puts "encryptedFirstBlock $encryptedFirstBlock"

  # test for eof marker "PWS3-EOFPWS3-EOF"
	if { eq $encryptedFirstBlock "505753332d454f46505753332d454f46" } {
	    # EOF marker
      hset $crypto fieldType ""
	    return $crypto
	}
  # if {[string length $encryptedFirstBlock] == 0 && [$source eof]} {
	    # error "EOF while reading field"
	# }
# 
	# if {[string length $encryptedFirstBlock] != 16} {
	    # error "less than 16 bytes remaining for first block"
	# }
  
  # in cbc mode the iv is taken from the last 16byte block from the cipher

  set key [hget $crypto key]
  set iv [hget $crypto iv]

	set decryptedFirstBlock [twofish::decrypt -cbc $encryptedFirstBlock $key $iv]
  # puts "decryptedFirstBlock: $decryptedFirstBlock"

  hset $crypto iv $encryptedFirstBlock
  set iv $encryptedFirstBlock

  set fieldLength [ integer parseInt [toLittleEndian [strrange $decryptedFirstBlock 0 7] ] 16 ]
  set fieldType [integer parseInt [strrange $decryptedFirstBlock 8 9] 16]

	# === field length sanity check ===

	if { or [ < $fieldLength 0 ] [ > $fieldLength 65536 ] } {
	    puts "field length $fieldLength looks insane"
      # exit
	}

# puts "length: $fieldLength type: $fieldType"

  # Todo: if { $type ni $typeList } error

	# remainder of the first block contains data

	if { <= $fieldLength 11} {
    set fieldData [strrange $decryptedFirstBlock 10 [+ [ * 2 $fieldLength ] 9]]
    # pwsafe::int::randomizeVar decryptedFirstBlock
    # puts "fieldType $fieldType fieldData $fieldData [strlen $fieldData]"

    hset $crypto fieldType $fieldType
    hset $crypto fieldData $fieldData
    
    return $crypto
	}

	set fieldData [strrange $decryptedFirstBlock 10 [incr [strlen $decryptedFirstBlock] -1]]
	# pwsafe::int::randomizeVar decryptedFirstBlock
	incr $fieldLength -11

	# remaining data is stored in multiple blocks

	set numBlocks [ / [+ $fieldLength 15] 16 ]
	set dataLength [* $numBlocks 16]

	# decrypt field

	set encryptedData [$source readhex $dataLength]

	if { != [strlen $encryptedData] [* 2 $dataLength]} {
	    puts "Error: out of data"
      exit
	}

  # puts "encryptedData $encryptedData len: [strlen $encryptedData]"
	set decryptedData [twofish::decrypt -cbc $encryptedData $key $iv]

  if { > [strlen $encryptedData] 32 } {
    # take the last 16 bytes from encryptedFirstBlock
    hset $crypto iv [strrange $encryptedData [- [strlen $encryptedData] 32] [ - [strlen $encryptedData] 1] ]
  } else {
    hset $crypto iv $encryptedData
  }
  
	# adjust length of data; truncate padding

	append $fieldData [strrange $decryptedData 0 [- [ * 2 $fieldLength] 1]]

	# field decrypted successfully

	# pwsafe::int::randomizeVar decryptedData
  # puts "+++ fieldData: [hexToAsc $fieldData]"

  hset $crypto fieldType $fieldType
  hset $crypto fieldData $fieldData

	return $crypto
  
} ;# end of proc readField

proc  readAllFields { crypto } {
  global database source
	# if {ne $percentvar ""} {
	    # upvar $percentvar pcv
	    # puts "percentvar $percentvar"
	# }

	set fileSize [file.size $database]

	# Remaining fields are user data

	set first 1

  # Todo: implement [$source eof] -> true/false
	while { true } {
    
    # --- code to define percent index ---
    # set filePos [$source tell]
    # if {$filePos != -1 && $fileSize != -1 && \
      # $fileSize != 0 && $filePos <= $fileSize} {
  # set percent [expr {100.0*double($filePos)/double($fileSize)}]
    # } else {
  # set percent -1
    # }
    # set pcv $percent

    set crypto [readField $crypto]

    set fieldType [hget $crypto fieldType]
    set fieldValue [hget $crypto fieldData]

    if { eq $fieldType "" } { puts eof; break } ;# eof

    if { = $fieldType 255} {
      set first 1
      continue
    }

    if { != $first 0 } {
      # set recordnumber [$db createRecord]
      puts "Setting recordnumber to newly created record"
      set first 0
    }

    # update hmac message value
    set value [hget $crypto hmac]
    append $value $fieldValue
    hset $crypto hmac $value

    # Format the field's type, if necessary

	  if { = $fieldType 1 } {
      #
      # UUID
      #
      puts "formatting uuid field"
      # binary scan $fieldValue H* tmp
      # set fieldValue [string range $tmp 0 7]
      # append fieldValue "-" [string range $tmp 8 11]
      # append fieldValue "-" [string range $tmp 12 15]
      # append fieldValue "-" [string range $tmp 16 19]
      # append fieldValue "-" [string range $tmp 20 31]
		} elseif { or [= $fieldType 2] \
                  [= $fieldType 3] \
                  [= $fieldType 4] \
                  [= $fieldType 6] \
                  [= $fieldType 13] } {
      #
      # Text fields are always stored in UTF-8
      #

      # set fieldValue [encoding convertfrom utf-8 $fieldValue]
      puts "converting text to utf-8"
		} elseif { = $fieldType 5} {
      #
      # Notes field uses CRLF for line breaks, we want LF only.
      #

      # set fieldValue [encoding convertfrom utf-8 $fieldValue]
      # set fieldValue [string map {\r\n \n} $fieldValue]
      puts "replacing CRLF in Notes field with LF"
		} elseif { or [= $fieldType 7] \
                  [= $fieldType 8] \
                  [= $fieldType 10] \
                  [= $fieldType 12] } {
      #
      # (7) Creation Time, (8) Password Modification Time,
      # (9) Last Access Time, (10) Password Lifetime and
      # (11) Last Modification Time are of type time_t,
      # i.e., a 4 byte (little endian) integer
      #

      # if {[binary scan $fieldValue i fieldValue] != 1} {
        # continue
      # }
      puts "convert from little endian integer"

      #
      # Make unsigned
      #

      # set fieldValue [expr {($fieldValue + 0x100000000) % 0x100000000}]
      puts "make fieldValue unsigned"

		} ;# end if

	    # $db setFieldValue $recordnumber $fieldType $fieldValue
      puts "=== fieldValue [hexToAsc $fieldValue]"
	    # pwsafe::int::randomizeVar fieldType fieldValue
      
	} ;# end of while

  return $crypto
  
} ;# end of proc readAllFields {{percentvar ""}} 


# pwsafe-db.tcl
    # public method getPassword {} {
  # return [decryptField $password]
    # }
# 
        # private method decryptField {encryptedMsg} {
  # set eml [string length $encryptedMsg]
  # set blocks [expr {$eml/16}]
  # set decryptedMsg ""
  # for {set i 0} {$i < $blocks} {incr i} {
      # append decryptedMsg [$engine decryptBlock \
        # [string range $encryptedMsg [expr {16*$i}] [expr {16*$i+15}]]]
  # }
  # binary scan $decryptedMsg @4I msgLen
  # set res [string range $decryptedMsg 8 [expr {7+$msgLen}]]
  # pwsafe::int::randomizeVar decryptedMsg
  # return $res
    # }




# Note: There is no "namespace" in Hecl.
# proc gorilla::readFile {{percentvar ""}} {}
proc pwsafe::readFile { } {
  global source
  
  set myPassword test
  
  set crypto [hash [list key "" iv "" hmac "" fieldType "" fieldData ""] ]

  set tag [$source read 4]
  
    if {ne $tag "PWS3"} {
        puts "Error: File does not have PWS3 magic"
        # exit
    }
  
  # NOTE: length of hex strings returned by readhex is bytes*2
    set salt [$source readhex 32]
    set biter [$source readhex 4]
    set hskey [$source readhex 32]
    set b1 [$source readhex 16]
    set b2 [$source readhex 16]
    set b3 [$source readhex 16]
    set b4 [$source readhex 16]
    set iv [$source readhex 16]
  
    if { or [!= [strlen $salt] 64] \
            [!= [strlen $biter] 8] \
            [!= [strlen $hskey] 64] \
            [!= [strlen $b1] 32] \
            [!= [strlen $b2] 32] \
            [!= [strlen $b3] 32] \
            [!= [strlen $b4] 32] \
            [!= [strlen $iv] 32] }  {
      # pwsafe::int::randomizeVar salt hskey b1 b2 b3 b4 iv
      puts "end of file while reading header"
      exit
    }
  
  java java.lang.Integer integer
  set iter [ integer parseInt [toLittleEndian $biter] 16 ]
  # Todo: iter min max warnings
  
  # Todo: $db configure -keyStretchingIterations $iter
  
  # Step 1: Verify the password
  
  # Todo: the main passord given by the user is stored encrypted
  # one and has to be decrypted with [$db getPassword] before use.
  
    set myskey [computeStretchedKey $salt $myPassword $iter]
    set myhskey [sha256 $myskey]
  
    puts "hskey:\t\t$hskey"
    puts "myhskey:\t$myhskey"
    
    if {ne $hskey $myhskey} {
        # pwsafe::int::randomizeVar salt hskey b1 b2 b3 b4 iv myskey myhskey
        puts "wrong password"
        exit
    }
  
    # pwsafe::int::randomizeVar salt hskey myhskey
    
    puts "=== Step 1: Password verified"
    
    # Step 2: Decrypt Twofish and Hmac key
    
    # The real key is encrypted using Twofish in ECB mode, using
    # the stretched passphrase as its key.
  
    # pwsafe::int::randomizeVar myskey
  
    # Decrypt the real key from b1 and b2, and the key L that is
    # used to calculate the HMAC
  
    set key [twofish::decrypt -ecb $b1 $myskey]
    append $key [twofish::decrypt -ecb $b2 $myskey]
    puts "twofishkey:\t$key"
    #pwsafe::int::randomizeVar b1 b2
  
    set hmacKey [twofish::decrypt -ecb $b3 $myskey]
    append $hmacKey [twofish::decrypt -ecb $b4 $myskey]
    puts "hmacKey:\t$hmacKey"
    puts "=== Step 2: Twofish and Hmac key decrypted"

    # Step 3: Decrypt Header fields and Data fields
    
    hset $crypto key $key
    hset $crypto iv $iv
puts "crypto: $crypto"  
    
    set crypto [readHeaderFields $crypto]
    set crypto [readAllFields $crypto]

  
    puts "=== Step 3: Header fields and Data fields decrypted"
    # set hmacEngine [sha2::HMACInit $hmacKey]
    
    # pwsafe::int::randomizeVar b3 b4 hmacKey
  
    # Step 4: Read and validate HMAC 
  
    set hmac [$source readhex 32]
    set myHmac [sha256hmac [hget $crypto hmac] $hmacKey]
  puts "hmac\t$hmac"
  puts "myhmac\t$myHmac"
    if { ne $hmac $myHmac } {
        # set dbWarnings [$db cget -warningsDuringOpen]
        # lappend dbWarnings "Database authentication failed. File may have been tampered with."
        # $db configure -warningsDuringOpen $dbWarnings
        puts "Error: Database authentication failed. File may have been tampered with."
        # exit
    }
  
    puts "=== Step 4: Hmac authentification of all data fields proved"
    
    puts "+++ File is read successfully"
  
    # pwsafe::int::randomizeVar hmac myHmac
  
    # clean up
    # itcl::delete object $engine
    # set engine ""
  # 
      # constructor {db_ source_} {
    # set db $db_
    # set source $source_
    # set engine ""
    # set used 0
      # }
  # 
      # destructor {
    # if {$engine != ""} {
        # itcl::delete object $engine
    # }
      # }
  
  $source close
  
} ;# end proc readFile
