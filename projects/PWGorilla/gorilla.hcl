#
#
#                Password Gorilla for Android
# 
#
# ----------------------------------------------------------------------
# gorilla.hcl: holds password records, and provides an API to them
# ----------------------------------------------------------------------
#
# Android port written for Hecl (jars/j2se/Hecl.jar)
#
# Code is based on pwsafe-db.tcl written by Frank Pilhofer
#
# License: GNU
#
# (c) Zbigniew Diaczyszyn 2011
#

# ----------------------------------------------------------------------
# global variables
# ----------------------------------------------------------------------
# sensible data like the password or keys are passed encryptedly or as
# a parameter

# set database "/home/dia/Projekte/git/hecl/projects/PWGorilla/testdb.psafe3"
set database "/sdcard/testdb.psafe3"
set source [open $database r]

# source /home/dia/Projekte/git/hecl/projects/PWGorilla/pwsafe-db.hcl
# source /home/dia/Projekte/git/hecl/projects/PWGorilla/pwsafe-v3.hcl
source /sdcard/pwsafe-db.hcl
source /sdcard/pwsafe-v3.hcl


pwsafe::readFile

puts "[llen $recordnumbers] records read.\n\n"

puts "Command-line input: list 5 3"
puts "> [db::getFieldValue 5 3]"
