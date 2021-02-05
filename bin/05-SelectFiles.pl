#!/usr/bin/perl -I../lib
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2010 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      05-ProcessFiles.pl
##
##  DESCRIPTION
##      Process Gutenberg files to generate AI text corpus
##
##  USAGE
##      05-ProcessFiles.pl
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

my $LibraryFile = "$BaseDir/Library.JSON";

# my $LibraryFile = "$BaseDir/Library.JSON";
#
# $Library->Load($LibraryFile);
# DeleteExcept(17871);
# $Library->Save("$BaseDir/Library1.JSON");
# exit(0);

$Library->Load($LibraryFile);

unlink <$DestDir/*>;

print "\n";
print "Loading library: $LibraryFile\n";

$Library->PrintSummary();

StartTime();

# $Library->PrintLanguageSummary();
# print "\n";

# $Library->PrintEncodingSummary();
# print "\n";

# $Library->PrintTagSummary ();
# print "\n";

# $Library->PrintTaggedBooks();
# print "\n";

# $Library->PrintUnfitSummary ();
# print "\n";

# $Library->PrintDefectiveBooks();
# print "\n";

#
# Load all book files with an ASCII encoding
#
my $NumToProcess = @{$Library->{Books}};
#my $NumToSave    = 500;
my $NumToSave = $NumToProcess;

my $SAVE_FAILURES = 0;

my $Saved     = 0;
my $Processed = 0;
foreach my $Book (@{$Library->{Books}}) {

    $Processed++;

    next
        if $Book->{Unfit} ne "";

    foreach my $File (keys %{$Book->{Files}}) {

        next
            unless $Book->{Files}{$File}{Encoding} eq "ASCII";

        $Book->LoadText($File,$DataDir);
        $Book->ProcessText();

        if( $SAVE_FAILURES ) {
            if( $Book->{Unfit} ne "" ) {
                $Book->SaveText("$DestDir/$Book->{ETextNo}-cut.txt");
                $Book->LoadText($File,$DataDir);
                $Book->SaveText("$DestDir/$Book->{ETextNo}.txt");
                $Saved++;
                }
            }
        else {
            if( $Book->{Unfit} eq "") {
                $Book->SaveText("$DestDir/$Book->{ETextNo}.txt");
                $Saved++;
                }
            }

        $Book->UnloadText();

        last;
        }

    last
        if $Saved > $NumToSave;
    }

print "Done. $Processed files processed, $Saved texts saved.\n";
print "\n";

$Library->PrintUnfitSummary ();
print "\n";


exit(0);


########################################################################################################################
########################################################################################################################
#
# DeleteExcept - Delete all books, except one specified
#
# Inputs:   ETextNo of book to save
#
# Outputs:  None.
#
sub DeleteExcept {
    my $ETextNo = shift;;

    shift @{$Library->{Books}}
        while $Library->{Books}[ 0]{ETextNo} != $ETextNo;

    pop  @{$Library->{Books}}
        while $Library->{Books}[-1]{ETextNo} != $ETextNo;
    }
