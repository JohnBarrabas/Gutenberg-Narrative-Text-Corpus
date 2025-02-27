#!/bin/bash
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2021 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      09-MakeISO.sh
##
##  DESCRIPTION
##      Create an ISO containing the library database and all the generated text files.
##
##  USAGE
##      09-MakeISO.sh
##
##  NOTE: This step is optional.
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

CDLABEL="NarrativeText"
ISONAME="NarrativeText.iso"
TMPDIR="/tmp/ISO"

cd ..

########################################################################################################################
########################################################################################################################
#
# The mkisofs program automatically enters directories, so we need to forcefully create the directory
#   structure we want it to use.
#
echo    "============================================"
echo -n "Generating ISO from narrative text files... ";

mkdir -p "$TMPDIR";
rm -rf "$TMPDIR/*"

cp Library.JSON $TMPDIR
cp -rf TextData $TMPDIR/

mkisofs -o "$ISONAME" -A "$CDLABEL" -V "$CDLABEL" -iso-level 4 -relaxed-filenames -U -relaxed-filenames "$TMPDIR"

rm -rf $TMPDIR
