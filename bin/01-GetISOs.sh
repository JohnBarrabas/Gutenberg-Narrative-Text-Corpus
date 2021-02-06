#!/bin/bash
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2021 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      01-GetISOs.sh
##
##  DESCRIPTION
##      Download the "split" parts of the gutenberg ISO file.
##
##      Makes a directory www.gutenberg.org/files/19159/parts in the top level
##        directory of the project containing the ISO part files.
##
##  USAGE
##      01-GetISOs.sh
##
##  NOTES
##      Net access can be intermittant and slow, so this command is restartable.
##
##      The recommended procedure is to run this script over and over until the
##        all files are complete.
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

URL="www.gutenberg.org/files/19159/parts"
PART_SIZE="15000000"

cd ..

########################################################################################################################
########################################################################################################################
#
# All "part" files from Gutenberg will be $PART_SIZE in length (except the last one), so any file that is
#   less than this length is a partial download and will be removed.
#
echo "========================="
echo "Deleting partial downloads";

find ./$URL -name "*.iso.*" -type 'f' -not -size 15000000c -delete

echo "Done."
echo

echo "========================="
echo "Retrieving remaining part files";

wget -c --recursive --no-parent -nc -A '*.iso.*' $URL

Files="$(ls -1 $URL | wc | awk '{print $1}')"

echo "Done. $Files files downloaded."
echo
