#!/bin/bash
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2021 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      02-CombineISOs.sh
##
##  DESCRIPTION
##      Combine the split parts of the ISO into a single ISO file
##
##      Uses the directory www.gutenberg.org/files/19159/parts in the top level
##        directory of the project containing the ISO part files.
##
##      Optionally, prompt the user and delete the parts file directory if requested.
##
##  USAGE
##      02-CombineISOs.sh
##
########################################################################################################################
########################################################################################################################
##
##  MIT LICENSE
##
##  Permission is hereby granted, free of charge, to any person obtaining a copy of
##    this software and associated documentation files (the "Software"), to deal in
##    the Software without restriction, including without limitation the rights to
##    use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
##    of the Software, and to permit persons to whom the Software is furnished to do
##    so, subject to the following conditions:
##
##  The above copyright notice and this permission notice shall be included in
##    all copies or substantial portions of the Software.
##
##  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
##    INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
##    PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
##    HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
##    OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
##    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
##
########################################################################################################################
########################################################################################################################

URL="www.gutenberg.org/files/10802/10802-parts"
ISO="pgdvd.iso"
CORRECT_MD5SUM="59d8a193874349181122ff52e2e3e114"           # Correct MD5 sum for pgdvd072006.iso

########################################################################################################################
########################################################################################################################
#
# Create the ISO from the part files
#
echo    "========================="
echo -n "Generating ISO from part files... ";

cat $URL/$ISO.???? > $ISO

echo "done."

########################################################################################################################
########################################################################################################################
#
# Sanity, check the MD5 of the resultant file
#
echo -n "Checking ISO MD5sum... ";

MD5SUM="$(md5sum $ISO | awk '{print $1}')"

if [ ! "$MD5SUM" = "$CORRECT_MD5SUM" ]; then
    echo "***FAILED! Result has incorrect MD5SUM"
    echo "***Fix the part files and rerun command."
    echo
    exit 1;
    fi

echo "done."
echo "MD5SUM check OK."

########################################################################################################################
########################################################################################################################
#
# File is OK, the part files are no longer needed. See if the user wants to delete them.
#
while true; do
    read -p "Delete the downloaded parts [y/n]? " yn
    case $yn in
        [Yy]* ) echo -n "Deleting part files... ";rm -rf "www.gutenberg.org"; echo "done.";break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";echo;;
    esac
done

echo "All done."
echo
echo "ISO $ISO is now available for use."
echo


exit 0
