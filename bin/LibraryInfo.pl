#!/usr/bin/perl -I../lib
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2010 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      LibraryInfo.pl
##
##  DESCRIPTION
##      Load the library listing and print out requested info
##
##  USAGE
##      LibraryInfo.pl [--print-summary] [--print-encodings] [--printlangs] [--print-unfits]
##
##  where:
##          --print-summary         Print library summary information
##          --print-encodings       Print encoding summary
##          --print-langs           Print language summary
##          --print-unfits          Print unfit summary
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
use Site::CommandLine;

########################################################################################################################
########################################################################################################################
##
## Data declarations
##
########################################################################################################################
########################################################################################################################

my $BaseDir = "$FindBin::Bin/..";

my $Library = Site::Library->new();

$| = 1;         # Flush output immediately

########################################################################################################################
########################################################################################################################
##
## Find the Gutenberg index file and parse it
##
########################################################################################################################
########################################################################################################################

my $PrintSummary   = 0;
my $PrintEncodings = 0;
my $PrintLangs     = 0;
my $PrintUnfits    = 0;

exit HELP_MESSAGE()
    unless @ARGV;

ParseCommandLine("print-summary"   => \$PrintSummary,
                 "print-encodings" => \$PrintEncodings,
                 "print-langs"     => \$PrintLangs,
                 "print-unfits"    => \$PrintUnfits);

my $LibraryFile = "$BaseDir/Library.JSON";

print "\n";
print "Loading library: $LibraryFile\n";

$Library->Load($LibraryFile);

$Library->PrintSummary()
    if $PrintSummary;

$Library->PrintLanguageSummary()
    if $PrintLangs;

$Library->PrintUnfitSummary()
    if $PrintUnfits;

$Library->PrintEncodingSummary()
    if $PrintEncodings;

exit(0);
