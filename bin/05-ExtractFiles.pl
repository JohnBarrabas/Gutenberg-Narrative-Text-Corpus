#!/usr/bin/perl -I../lib
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2010 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      05-ExtractFiles.pl
##
##  DESCRIPTION
##      Unzip files, remove Gutenberg header/footer, and save as text.
##
##  USAGE
##      05-ExtractFiles.pl  [--max-save #] [--include-olde] [--only-olde] [--save-failures]
##
##      Where:
##
##          --max-save #        Maximum number of files to extract/save
##
##          --include-olde      Include "Olde English" texts along with modern English
##          --only-olde         Only extract "Olde English" texts, no modern English
##
##          --save-failures     Extract/Save texts that fail the selection process (for debugging)
##
##  EXAMPLE
##
##      05-ExtractFiles.pl --max-save 50 --only-olde
##
##      This will extract a randomized 50 (of the 100 or so) texts that are in "Olde English", remove the
##        Gutenberg headers/footers, and save the results as $ETextNo.txt in the "../ISOFiles/" directory.
##
##
##      05-ExtractFiles.pl --include-olde --save-failures
##
##      This will extract ALL of the books - more than 10,000 of them, including texts in Olde English - to the
##      "../ISOFiles/" directory. In addition, files that have some type of defect (such as "lang not English")
##      will be saved as $EText.unfit.txt as well, with a msg at the top of the file explaining the defect.
##
##      (Note: Don't do this, uses a boatload of disk space and takes a long time.)
##
##  NOTE
##      The the book files are processed in random order, and this really means random! If "max-save" is set,
##        running this program will extract a different set of books from the previous run, this is explicitly
##        enforced by randomizing the loop variable below.
##
##      Extracting *all* of the books will, of course, always extract all the books.
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
use List::Util qw(shuffle);

use lib "$FindBin::Bin/../lib";

use Site::Library;
use Site::Book;
use Site::Time;
use Site::CommandLine;

########################################################################################################################
########################################################################################################################
##
## Data declarations
##
########################################################################################################################
########################################################################################################################

my $BaseDir = "$FindBin::Bin/..";
my $DataDir = "$BaseDir/ISO";
my $DestDir = "$BaseDir/ISOFiles";

my $Library = Site::Library->new($DataDir);

my $KeepJunk  = 0;

$| = 1;         # Flush output immediately

die "ISO not mounted at $DataDir"
    unless -r "$DataDir/LICENSE.TXT";

my $IncludeOlde  = 0;
my $OnlyOlde     = 0;
my $SaveFailures = 0;
my $MaxSave      = 0;

ParseCommandLine("include-olde"  => \$IncludeOlde,
                 "only-olde"     => \$OnlyOlde,
                 "save-failures" => \$SaveFailures,
                 "max-save=i"    => \$MaxSave
                 );

########################################################################################################################
########################################################################################################################
##
## Find the Gutenberg index file and parse it
##
########################################################################################################################
########################################################################################################################

my $LibraryFile = "$BaseDir/Library.JSON";

print "\n";
print "Loading library: $LibraryFile\n";

$Library->Load($LibraryFile);
$Library->PrintSummary();

StartTime();

mkdir $DestDir
    unless -d $DestDir;

unlink <$DestDir/*>;

#
# Load all book files with an ASCII encoding
#
my $TotalBooks = @{$Library->{Books}};
$MaxSave = $TotalBooks
    unless $MaxSave;

if( $MaxSave ) { print "Extracting $MaxSave files and removing Gutenberg headers/footers\n\n"; }
else           { print "Extracting files and removing Gutenberg headers/footers\n\n"; }

my $Saved     = 0;
my $Processed = 0;
foreach my $Book (shuffle @{$Library->{Books}}) {

    $Processed++;

    print "\r$Processed/$TotalBooks..."
        unless $Processed % 100;

    next
        if $Book->{Unfit} ne "";

    foreach my $File (keys %{$Book->{Files}}) {

        next
            unless $Book->IsASCII($File);

        if( $Book->{Lang} eq "OldeEnglish" ) {
            next
                 unless $IncludeOlde or $OnlyOlde;
            }

        if( $Book->{Lang} ne "OldeEnglish" ) {
            next
                 if $OnlyOlde;
            }

        $Book->LoadText($File,$DataDir);

        $Book->RemoveGutenberg();

        if( $Book->{Unfit} eq "") {
            $Book->SaveText("$DestDir/$Book->{ETextNo}.txt");
            $Saved++;
            }

        if( $SaveFailures and $Book->{Unfit} ne "" ) {
            $Book->{Text} = "===== Unfit: " . $Book->{Unfit} . "\n" . $Book->{Text};
            $Book->SaveText("$DestDir/$Book->{ETextNo}.unfit.txt");
            }

        $Book->UnloadText();

        last;
        }

    last
        if $Saved >= $MaxSave;
    }

print " Done. $Processed files processed, $Saved texts saved.\n";
print "\n";

$Library->PrintUnfitSummary ();
print "\n";


exit(0);
