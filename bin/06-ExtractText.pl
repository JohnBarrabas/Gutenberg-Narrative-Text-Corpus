#!/usr/bin/perl -I../lib
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2010 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      06-ExtractText.pl
##
##  DESCRIPTION
##      Extract narrative text from all text files in the Gutenberg corpus
##
##      Save narrative text with original filename in the $DestDir. Optionally, save
##        discarded text (noted "junk") in original filename with "jnk" extension.
##
##  USAGE
##      06-ExtractText.pl [--keep-junk] [--print-junk] [--print-keep]
##
##      Where:
##
##          --keep-junk     Write out junk paragraphs to a separate file
##          --print-junk    Print out junk paragraphs when encountered
##          --print-keep    Print out kept paragraphs when encountered
##
##  EXAMPLE
##
##      06-ExtractText.pl --keep-junk
##
##      This will visit all files in the $DataDir, separate narrative text from non-narrative text
##        (chapter headings, titles, footnotes, &c), and save pairs of files (.txt and .jnk) in the
##        $DestDir containing the relevant text.
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

use File::Slurp qw(read_file write_file);
use List::Util  qw(shuffle);
use FindBin;

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

my $BaseDir    = "$FindBin::Bin/..";
my $DataDir    = "$BaseDir/ISOFiles";
my $DestDir    = "$BaseDir/TextData";
my $IgnoreFile = "$BaseDir/IgnoreList.txt";

my $UC_LIMIT = 0.2;                 # Portion of uppercase chars in string, above which is not narrative

my $Keep;
my $Junk;

my $Library = Site::Library->new($DataDir,$DestDir);

$| = 1;                             # Flush output immediately

my $IgnoreList;

my $KeepJunk  = 0;
my $PrintJunk = 0;
my $PrintKeep = 0;

ParseCommandLine("keep-junk"  => \$KeepJunk,
                 "print-junk" => \$PrintJunk,
                 "print-keep" => \$PrintKeep
                 );

########################################################################################################################
########################################################################################################################
##
## Grab the ignore list and parse it
##
########################################################################################################################
########################################################################################################################

my @IgnoreLines = eval{read_file($IgnoreFile)};              # Catches/avoids Croak() in lib function

die "Cannot read $IgnoreFile ($!)"
    unless @IgnoreLines;

foreach my $Line (@IgnoreLines) {

    chomp $Line;

    next
        unless length($Line);

    next
        if substr($Line,0,1) eq "#";

    $Line =~ m/^(\d*)/;

    my $EBookNo = $1;

    die "Bad EBookNo $1"
        unless $EBookNo;

    $IgnoreList->{$EBookNo} = 1;
    }

########################################################################################################################
########################################################################################################################
##
## Load all book files previously processed, with a .txt extension
##
########################################################################################################################
########################################################################################################################

StartTime();

mkdir $DestDir
    unless -d $DestDir;

unlink <$DestDir/*>;

my @Files    = shuffle <"$DataDir/*.txt">;
my $NumFiles = @Files;

my $SAVE_FAILURES = 0;

print "Extracting narrative text from $NumFiles files\n\n";

my $Saved     = 0;
my $Processed = 0;
foreach my $File (@Files) {

    $Processed++;

    print "\r$Processed/$NumFiles"
        unless $Processed % 100;

    die "Unknown file ETextNo or extension"
        unless $File =~ m#.*/(\d+).txt#;

    my $ETextNo = $1;

    if( $IgnoreList->{$ETextNo} ) {
        print "Ignoring book: $ETextNo (from Ignore List)\n";
        next;
        }    

    ProcessText($File);
    }

print "\n\nDone. $Processed files processed, $Saved texts saved.\n";
print "\n";

exit(0);


########################################################################################################################
########################################################################################################################
#
# ProcessText - Process text for this step
#
# Inputs:   File to process
#
# Outputs:  None.
#
sub ProcessText {
    my $File = shift;

#$File = "$DataDir/18175.txt";

    $Keep = "";
    $Junk = "";
    my $Text = eval{read_file($File)};              # Catches/avoids Croak() in lib function

    unless( $Text ) {
        print "Cannot read file $File ($!)";
        return 0;
        }

#    print "Processing Book/File: $File\n";

    my @Paras = split /\n\n/,$Text;

    foreach my $Para (@Paras) {

        ################################################################################################################
        #
        # Trim orphan newlines at the beginning or at the end, and orphan spaces before newlines
        #
        substr($Para,0,1) = ""
            while substr($Para,0,1) eq "\n";

        substr($Para,-1) = ""
            while substr($Para,-1) eq "\n";

        substr($Para,-1) = ""
            while substr($Para,-1) eq " ";

        $Para =~ s/ \n/\n/g
            while $Para =~ m/ \n/g;

        ################################################################################################################
        #
        # Remove references "[#]" and surrounding spaces
        #
        $Para =~ s/\s*\[\d*\]\s*//g;

        ################################################################################################################
        #
        # Ignore blank paragraphs (side-effect of split function)
        #
        next
            unless length($Para);

        ################################################################################################################
        #
        # Paragraphs that are indented are likely non-narrative: poems, epigraphs, and so on.
        #
        if( $Para =~ m/\n / ) {
            JunkPara($Para,"Indented lines");
            next;
            }

        ################################################################################################################
        #
        # Paragraphs that are almost entirely uppercase are not narrative. (Title beginning with "A" or "I", &c)
        #
        my $UCCount = $Para =~ tr/A-Z//;

        if( $UCCount/length($Para) > $UC_LIMIT ) {
            JunkPara($Para,"Mostly UC");
            next;
            }

        ################################################################################################################
        #
        # Short paragraphs that don't end with punctuation (period, question, quote) are probably non-narrative
        #
        my $LastIndex = -1;

        my $LastColon = $Para =~ m/:--$|--$|--"$/;

        while(1) {

            my $LastChar = substr($Para,$LastIndex,1);

            last
                if $LastChar ne '"' and
                   $LastChar ne "'" and
                   $LastChar ne "_";

            $LastIndex--;
            }

        my $LastChar  = substr($Para,$LastIndex,1);

        if( $LastChar ne "." and
            $LastChar ne "!" and
            $LastChar ne "?" and
            $LastChar ne "," and 
            $LastChar ne ":" and 
            (not $LastColon) ) {

            JunkPara($Para,"No sentence end");

            next;
            }

        ################################################################################################################
        #
        # Lists and tables are not narrative
        #
        if( $Para =~ m/1\./ and $Para =~ m/2\./ and $Para =~ m/3\./ ) {
            JunkPara($Para,"Numeric list");
            next;
            }

        if( $Para =~ m/a\./ and $Para =~ m/b\./ and $Para =~ m/c\./ ) {
            JunkPara($Para,"Alpha list");
            next;
            }

        if( $Para =~ m/\.\.\.\./ ) {
            JunkPara($Para,"Table");
            next;
            }

        ################################################################################################################
        #
        # Single bold lines are *probably* not narrative
        #
        if( substr($Para,0,1) eq "_"  or 
            substr($Para,0,2) eq '"_'  ) {
            if( $Para =~ tr/\n// == 0 ) {
                JunkPara($Para,"Single bold line");
                next;
                }
            }

        ################################################################################################################
        #
        my $StartIndex = 0;

        while(1) {
            my $StartChar = substr($Para,$StartIndex,1);

            last
                if $StartChar ne '"' and
                   $StartChar ne "'" and
                   $StartChar ne "_";

            $StartIndex++;
            }

        my $Char1 = substr($Para,$StartIndex+0,1) // "";
        my $Char2 = substr($Para,$StartIndex+1,1) // "";
        my $Char3 = "";
        $Char3 = substr($Para,$StartIndex+2,1)
            if length($Para) > 2;

        if( $Char1 =~ m/^[[:upper:]]/ and $Char2 =~ m/^[[:lower:]]/ ) {
            KeepPara($Para);
            next;
            }

        if( ($Char1 eq "A" or $Char1 eq "I" or $Char1 eq "O") and ($Char2 eq " " or $Char2 eq ",") ) {
            KeepPara($Para);
            next;
            }

        if( $Char1 eq "I" and $Char2 eq "'" and $Char3 =~ m/^[[:lower:]]/ ) {        # I'm, I'll, &c
            KeepPara($Para);
            next;
            }

        JunkPara($Para,"No sentence start");
        }

    my $NewFile = $File;
    $NewFile =~ s/$DataDir/$DestDir/;

#     if( length($Keep) < length($Junk) ) {
#         print "==== $NewFile: More junk than keep\n";
#         }

    eval{write_file($NewFile,$Keep)};                   # Catches/avoids Croak() in lib function

    $Saved++;

    if( $KeepJunk ) {
        $NewFile =~ s/txt$/jnk/;
        $Junk = ">>>>>Processing file: $File\n\n" . $Junk;
        eval{write_file($NewFile,$Junk)};               # Catches/avoids Croak() in lib function
        }
    }


########################################################################################################################
########################################################################################################################
#
# KeepPara - Keep paragraph as part of narrative text
#
# Inputs:   Paragraph to keep
#
# Outputs:  None.
#
sub KeepPara {
    my $Para = shift;

    $Keep .= $Para . "\n\n";

    if( $PrintKeep ) {
        print "=====Keep\n";
        print $Para;
        print "\n";
        }
    }


########################################################################################################################
########################################################################################################################
#
# JunkPara - Discard paragraph as not being narrative
#
# Inputs:   Paragraph to discard
#           Reason for discard
#
# Outputs:  None.
#
sub JunkPara {
    my $Para   = shift;
    my $Reason = shift;

    $Junk .= "=====$Reason\n" . $Para . "\n\n";

    if( $PrintJunk ) {
        print STDERR "=====Junk, ($Reason)\n";
        print STDERR $Para;
        print STDERR "\n";
        }
    }
