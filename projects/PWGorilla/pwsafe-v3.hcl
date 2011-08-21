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

proc pwsafe::computeStretchedKey {salt password iterations} {
	set token [sha2::SHA256Init]
# puts "salt [hex $salt]\npassword $password iterations $iterations"
    sha2::SHA256Update $token $password
# puts "sha2::Hex [sha2::Hex $token]"
    sha2::SHA256Update $token $salt
    set Xi [sha2::SHA256Final $token]
# puts "Xi [hex $Xi]"
    for {set i 0} {$i < $iterations} {incr i} {
			# give the result as binary
			set Xi [sha2::sha256 -bin $Xi]
    }
    return $Xi
}

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

# There is no "namespace" in Hecl. Perhaps we can structure the code
# with class structure, e.g.:
# Gorilla.io.inputstream read

set source [open /home/dia/Projekte/git/hecl/projects/PWGorilla/testdb.psafe3 r]
set myPassword test

set tag [$source read 4]

	if {ne $tag "PWS3"} {
	    puts "Error: File does not have PWS3 magic"
			exit
	}

	set salt [$source read 32]
	set biter [$source read 4]
	set hskey [$source read 32]
	set b1 [$source read 16]
	set b2 [$source read 16]
	set b3 [$source read 16]
	set b4 [$source read 16]
	set iv [$source read 16]

	# if {[string length $salt] != 32 || \
		# [string length $biter] != 4 || \
		# [string length $hskey] != 32 || \
		# [string length $b1] != 16 || \
		# [string length $b2] != 16 || \
		# [string length $b3] != 16 || \
		# [string length $b4] != 16 || \
		# [string length $iv] != 16} {
	    # pwsafe::int::randomizeVar salt hskey b1 b2 b3 b4 iv
	    # error "end of file while reading header"
	# }

	#
	# Verify the password
	#

# puts "salt: $salt"
$source close

# streched key iteration is saved 32bit little endian
# 00 08 00 00 -> big endian 00 00 08 00 -> 0x800 := 2048

java java.lang.Integer integer
puts [integer parseInt "800" 16] ;# hex -> int

# scanlehex -> scan little endian int to hex
# binscan -i -hex
# scanInt2Hex_le
set iter [ integer parseInt [scanlehex $biter] 16 ]

# Todo: the new commands have to throw HeclException

# iter min max warnings

# $db configure -keyStretchingIterations $iter

# the passord given by the user is stored encryptedly and has to be
# decrypted before use.
# set myskey [pwsafe::int::computeStretchedKey $salt [$db getPassword] $iter]



	# set myskey [computeStretchedKey $salt $myPassword $iter]
	# set myhskey [sha2::sha256 -bin $myskey]
# 
	# if {ne $hskey $myhskey]} {
	    # pwsafe::int::randomizeVar salt hskey b1 b2 b3 b4 iv myskey myhskey
	    # puts "wrong password"
			# exit
	# }

