#!/usr/bin/perl -I../lib
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2010 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      04-ParseIndex.pl
##
##  DESCRIPTION
##      Parse Gutenberg index, save results
##
##  USAGE
##      04-ParseIndex.pl
##
##      This will parse the data from a mounted Gutenberg ISO and save the results in easily
##        accessed form as Library.JSON. This file may be read by other programs for information
##        about individual files in the Gutenberg dataset.
##
##      During the scanning process, many books are tagged "unfit" for further processing. This is
##        mostly due to "Language not English", but may also be due to a defect in file processing,
##        bad CRC on zip file, and so on.
##
##      In these cases, the var $Book->{Unfit} contains a text message describing why the book was
##        deemed unfit for AI research. Feel free to set this var on any book that you deem non-useful
##        for your own AI researches.
##
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

use strict;
use warnings;
use Carp;

our $VERSION = '1.0';

use FindBin;

use lib "$FindBin::Bin/../lib";

use Site::Library;
use Site::Book;
use Site::Time;

########################################################################################################################
########################################################################################################################
##
## Data declarations
##
########################################################################################################################
########################################################################################################################

my $BaseDir = "$FindBin::Bin/..";
my $DataDir = "$BaseDir/DiskData";
my $DestDir = "$BaseDir/TextFiles";

my $Library = Site::Library->new($DataDir,$DestDir);

$| = 1;         # Flush output immediately

die "ISO not mounted at $DataDir"
    unless -r "$DataDir/LICENSE.TXT";

########################################################################################################################
########################################################################################################################
##
## Find the Gutenberg index file and parse it
##
########################################################################################################################
########################################################################################################################

$Library->ParseIndex();         # No arg: uses default index file from ISO

print "\n";
print "Read index file $Library->{IndexFile}\n";
print "    Index:  " . AsMB($Library->{IndexSize}) . "\n";;
print "    Books:  " .      $Library->{NumBooks } . "\n";
print "    Files:  " .      $Library->{NumFiles } . "\n";
print "    Unfit:  " .      $Library->{NumUnfit } . "\n";
print "    Tagged: " .      $Library->{NumTagged} . "\n";
print "\n";

my $NumScan = $Library->{NumBooks};

StartTime();
print "\n";
print "Scanning $NumScan books for encodings and size:\n";
$Library->ScanBooks($NumScan,0,100);
$Library->Save("$BaseDir/Library.JSON");

print "Scanned $NumScan books:\n";
print "    Total Size:   " .          AsMB($Library->{TotalBytes}) . "\n";
print "    Encodings:    " . (scalar keys %{$Library->{TotalEncs}})  . "\n";
print "    Elapsed time: " . ElapsedTime() . "\n";
print "\n";

$Library->PrintLanguageSummary();
print "\n";

$Library->PrintEncodingSummary();
print "\n";

# $Library->PrintTagSummary ();
# print "\n";

# $Library->PrintTaggedBooks();
# print "\n";

$Library->PrintUnfitSummary ();
print "\n";

# $Library->PrintDefectiveBooks();
# print "\n";

exit(0);


########################################################################################################################
########################################################################################################################
#
# AsMB - Return number converted to MB (string)
#
# Inputs:   Number to convert
#
# Outputs:  sprintf converted number, with units (ie: "15.43 MB")
#
sub AsMB {
    my $Num = shift // 0;

    sprintf("%-.2f MB",$Num/(1024*1024));
    }
