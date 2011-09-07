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

puts $password
puts $salt
  set i "[hex $password]$salt"
  set Xi [sha256 $i]
  
puts "Start Xi  $Xi"
  for {set i 0} { < $i $iterations} {incr $i} {
    set Xi [sha256 $Xi]
  }
puts "End Xi $Xi"
  return $Xi
    
}

proc readHeaderFields {} {
  # fh - filehandler
  # while {![$source eof]}
  # while {file.readable} {
  # }
puts "while"
  while { true } {
    set field [readField]

    if { eq $field "" } { puts eof; break } ;# eof

    set fieldType [lindex $field 0]
    set fieldValue [lindex $field 1]
    
  puts "field $field"
  
    if { = $fieldType 255} {
      puts "while loop broken by $fieldType"  ;# -1 -> 255
      break
    }

# sha2::HMACUpdate $hmacEngine $fieldValue

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
    puts "db setHeaderField $fieldValue"
        
  } ;# end while

  puts "while loop left"

  #
	# If there is no version header field, then add one. The rest of
	# the code uses it to detect v3 files, assuming v2 otherwise.
	#

	# if {![$db hasHeaderField 0]} {
	    # $db setHeaderField 0 [list 3 0]
	# }
  
} ;# end of proc

proc readField {} {
  global source key iv
  #
	# first block contains field length and type
	#

	set encryptedFirstBlock [$source readhex 16]
puts "encryptedFirstBlock $encryptedFirstBlock"

	if { eq $encryptedFirstBlock "PWS3-EOFPWS3-EOF"} {
	    # EOF marker
	    return [list]
	}
  # if {[string length $encryptedFirstBlock] == 0 && [$source eof]} {
	    # error "EOF while reading field"
	# }
# 
	# if {[string length $encryptedFirstBlock] != 16} {
	    # error "less than 16 bytes remaining for first block"
	# }
  
  # set engine [itwofish::cbc \#auto $key $iv]
	# set decryptedFirstBlock [$engine decrypt $encryptedFirstBlock]

  # in cbc mode the iv is taken from the last 16byte block from the cipher

  # we have to pass the new iv

puts "key $key"
puts "iv $iv"
	set decryptedFirstBlock [twofish::decrypt -cbc $encryptedFirstBlock $key $iv]
  puts "decryptedFirstBlock: $decryptedFirstBlock"

  set iv $encryptedFirstBlock
  
  set fieldLength [ integer parseInt [toLittleEndian [strrange $decryptedFirstBlock 0 7] ] 16 ]
  # set fieldType [integer parseInt [strrange $decryptedFirstBlock 8 9] 16]
  set fieldType [integer parseInt [strrange $decryptedFirstBlock 8 9] 16]

  #
	# field length sanity check
	#

	if { or [ < $fieldLength 0 ] [ > $fieldLength 65536 ] } {
	    puts "field length $fieldLength looks insane"
      # exit
	}

  puts "length: $fieldLength type: $fieldType"

  # Todo: if { $type ni $typeList } error

  #
	# remainder of the first block contains data
	#

	if { <= $fieldLength 11} {
	    set fieldData [strrange $decryptedFirstBlock 10 [+ [ * 2 $fieldLength ] 9]]
	    # pwsafe::int::randomizeVar decryptedFirstBlock
  puts "fieldType $fieldType fieldData $fieldData [strlen $fieldData]"
	    return [list $fieldType $fieldData]
	}

puts "field > 11"
	set fieldData [strrange $decryptedFirstBlock 10 [incr [strlen $decryptedFirstBlock] -1]]
	# pwsafe::int::randomizeVar decryptedFirstBlock
	incr $fieldLength -11

	#
	# remaining data is stored in multiple blocks
	#

	set numBlocks [ / [+ $fieldLength 15] 16 ]
	set dataLength [* $numBlocks 16]

  #
	# decrypt field
	#
puts "dataLength $dataLength"
	set encryptedData [$source readhex $dataLength]

	if { != [strlen $encryptedData] [* 2 $dataLength]} {
	    puts "Error: out of data"
	}

	# set decryptedData [$engine decrypt $encryptedData]
puts "encryptedData $encryptedData"
puts "iv $iv"
	set decryptedData [twofish::decrypt -cbc $encryptedData $key $iv]
puts "decryptedData $decryptedData"
  set iv $encryptedData
  #
	# adjust length of data; truncate padding
	#

	append fieldData [strrange $decryptedData 0 [- $fieldLength 1]]

	#
	# field decrypted successfully
	#

	# pwsafe::int::randomizeVar decryptedData
puts "return readField:   [list $fieldType $fieldData]"
	return [list $fieldType $fieldData]
  
} ;# end of proc

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



# ================== main =======================

# -----------------------------------------------
# public method readFile {{percentvar ""}}
# -----------------------------------------------

# Note: There is no "namespace" in Hecl.
# proc gorilla::readFile {{percentvar ""}} {}

set source [open /home/dia/Projekte/git/hecl/projects/PWGorilla/testdb.psafe3 r]
set myPassword test

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

  #
  # Verify the password
  #

# Todo: the passord given by the user is stored as a encrypted one and has to be
# decrypted before use.
# set myskey [pwsafe::int::computeStretchedKey $salt [$db getPassword] $iter]

  set myskey [computeStretchedKey $salt $myPassword $iter]
  
  set myhskey [sha256 $myskey]

  puts "hskey $hskey"
  puts "myhskey $myhskey"
  
  if {ne $hskey $myhskey} {
      # pwsafe::int::randomizeVar salt hskey b1 b2 b3 b4 iv myskey myhskey
      puts "wrong password"
      exit
  }

  # pwsafe::int::randomizeVar salt hskey myhskey
  
  puts "Step 1: Password verified"
  
#
	# The real key is encrypted using Twofish in ECB mode, using
	# the stretched passphrase as its key.
	#

  # decrypt twofish key with ecb mode
	# pwsafe::int::randomizeVar myskey

  #
	# Decrypt the real key from b1 and b2, and the key L that is
	# used to calculate the HMAC
	#

	set key [twofish::decrypt -ecb $b1 $myskey]
	append $key [twofish::decrypt -ecb $b2 $myskey]
  
	#pwsafe::int::randomizeVar b1 b2

	set hmacKey [twofish::decrypt -ecb $b3 $myskey]
	append $hmacKey [twofish::decrypt -ecb $b4 $myskey]

  puts "Step 2: Twofish and Hmac key decrypted"

  readHeaderFields
	# set hmacEngine [sha2::HMACInit $hmacKey]
  
	# pwsafe::int::randomizeVar b3 b4 hmacKey

$source close
