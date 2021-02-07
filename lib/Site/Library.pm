#!/dev/null
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2016 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##
##      Site::Library.pm
##
##  DESCRIPTION
##
##       Encapsulation of meta information about a Gutenberg collection of books
##
##  DATA
##
##      ->{DataDir}             Directory of mounted ISO
##
##      ->{Books}[]             List of Gutenberg Book objects from index file
##      ->{ETextToBook}         Map for ETextNo to book
##
##      ->{IndexFile}           Name of index file read
##      ->{IndexSize}           Size of index file, in bytes
##      ->{NumBooks }           Number of books in Books array (== scalar @Books, convenience for other langs)
##      ->{NumFiles }           Total number of book files in index
##      ->{NumUnfit }           Number of books found unfit for use
##      ->{NumTagged}           Number of books tagged by user
##
##      ->{TotalBytes}          Total bytes seen in files that have been fully scanned
##      ->{TotalEncs }          Total files with specific encodings
##          ->{ASCII}               Total books with ASCII encoding
##          ->{UTF-8}               Total books with UTF8 encoding
##              :                   ...etc
##
##  FUNCTIONS
##
##      ->new($DataDir,$DstDir)     Make a new library object from files in $BaseDir
##
##      ->ParseIndex($IndexFile)    Read the index file and build the book list
##
##      ->ScanBooks($Num,$Print,$MinSize)    Scan $Num books for encodings and size
##
##      ->Load($File)               Load library description from file
##      ->Save($File)               Save library to file, for later retrieval
##
##      ->PrintSummary()            Print summary information
##
##      ->PrintLanguageSummary()    Print out summary of language types
##      ->PrintEncodingSummary()    Print out summary of encoding types
##
##      ->PrintTagSummary ()        Print summary of types of tag
##      ->PrintTaggedBooks()        Print header of each tagged book
##
##      ->PrintUnfitSummary()       Print summary of types of unfit
##      ->PrintUnfitBooks  ()       Print header of each unfit book
##
##  ISA
##
##      Site::JSONStorable          Makes object storable by JSON::PP
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

package Site::Library;
    use base Site::JSONStorable;

use strict;
use warnings;
use Carp;

use File::Slurp qw(read_file write_file);
use List::Util  qw(sum uniqstr);
use HTML::TreeBuilder;

use Site::Book;
use Site::Time;

########################################################################################################################
########################################################################################################################
##
## Data declarations
##
########################################################################################################################
########################################################################################################################

our $DefaultIndexFile = "indexbig.htm";             # Default index file on ISO

our $StartString = "<div><br />";
our $EndString   = "<br /></div>";

#
# The Project Gutenberg footer is roughly 18850 bytes long. In order for the header/footer strip algorithm
#   to work, the unzipped text file must be at least twice that length. Round up to 40K for good measure.
#
# It's very likely that texts smaller than 40K will not be narrative anyway. Files containing a single poem,
#   calendars with 1 paragraph for each month, and so on are not narrative in the sense intended.
#
our $MIN_SIZE    = 40000;                           # DEFAULT: Minimum size of unzipped text fit for AI

$| = 1;         # Flush output immediately

########################################################################################################################
########################################################################################################################
#
# Site::Library - Setup library object for future processing
#
# Inputs:   None.
#
# Outputs:  Library object
#
sub new {
    my $proto = shift;
    my $class = ref($proto) || $proto;
    my $self  = bless { DataDir     => shift,
                        Books       => [],
                        IndexSize   => 0,
                        NumBooks    => 0,
                        NumFiles    => 0,
                        NumUnfit    => 0,
                        NumTagged   => 0,
                        TotalBytes  => 0,
                        TotalEncs   => {},
                        ETextToBook => {},
        }, $class;

    die "Library: No DataDir supplied"
        unless defined $self->{DataDir} and length $self->{DataDir};

    die "Library: DataDir $self->{DataDir} doesn't exist"
        unless -d $self->{DataDir};

    return $self;
    }


########################################################################################################################
########################################################################################################################
#
# ParseIndex - Parse the gutenberg index file
#
# Inputs:   File to parse (DEFAULT: Known index file from ISO)
#
# Outputs:  None. ($self->{Books} is populated with results)
#
sub ParseIndex {
    my $self = shift;
    $self->{IndexFile} = shift // "$self->{DataDir}/$DefaultIndexFile";

    my $IndexData = eval{read_file($self->{IndexFile})}     # Catches/avoids Croak() in lib function
        or die "Cannot read $self->{IndexFile} ($!)";

    #
    # Parsing the big index file the correct way - using an HTML parsing function - takes way too
    #   long. Can get much faster results by simply text splitting the entries into an array.
    #
    $IndexData =~ s|.*</td><td||s;                          # Delete left hand table column
    $IndexData =~ s|^.*<hr />||;                            # Delete up to right hand column data
    $IndexData =~ s|</td></tr></table></body></html>||s;    # Delete after right hand column data

    my @Entries = split /<br \/>\n<br \/>/,$IndexData;      # Split into individual entries

    $self->{IndexSize } = -s $self->{IndexFile};

    $self->{NumBooks } = 0;
    $self->{NumFiles } = 0;
    $self->{NumUnfit } = 0;
    $self->{NumTagged} = 0;

    foreach my $Entry (@Entries) {
        my $Book = Site::Book->new($Entry,$self->{DataDir});
        push @{$self->{Books}},$Book;

        $self->{NumBooks}++;
        $self->{NumFiles} += keys %{$Book->{Files}};

        $self->{NumUnfit}++
            if $Book->{Unfit} ne "";

        $self->{NumTagged}++
            if $Book->{Tag} ne "";
        }
    }


########################################################################################################################
########################################################################################################################
#
# ScanBooks - Scan books for info
#
# Inputs:   Number of books to scan (undef == All books)
#           Minimum size to accept  (undef => $MIN_SIZE)
#           TRUE if should print out progress
#
# Outputs:  None.
#
sub ScanBooks {
    my $self          = shift;
    my $ScanNum       = shift // 0;
    my $MinSize       = shift // $MIN_SIZE;
    my $PrintProgress = shift // 100;

    $MinSize = $MIN_SIZE
        unless $MinSize;

    my $NumScanned = 0;

    foreach my $Book (@{$self->{Books}}) {

        next
            if $Book->{Unfit} ne "";

        foreach my $File (keys %{$Book->{Files}}) {

            next
                unless $Book->LoadText($File,$self->{DataDir});

            $Book->AssertDiv(length($Book->{Text}) > $MIN_SIZE,"Size < $MinSize bytes");

            $self->{TotalBytes} += $Book->{Files}{$File}{Size};
            $self->{TotalEncs }{$Book->{Files}{$File}{Encoding}}++;
            $Book->UnloadText();
            }

        $NumScanned++;

        last
            if $ScanNum > 0 and $NumScanned >= $ScanNum;

        if( $PrintProgress > 1 ) {
            print sprintf("\r%5d/%5d...",$NumScanned,$self->{NumBooks})
                if ($NumScanned % $PrintProgress) == 0;
            }
        }

    print sprintf("\r%5d/%5d\n\n",$NumScanned,$self->{NumBooks})
        if $PrintProgress;
    }


########################################################################################################################
########################################################################################################################
#
# Save - Save library to file, for later retrieval
#
# Inputs:      Full path of file to write
#
# Outputs:     None.
#
sub Save {
    my $self     = shift;
    my $Filename = shift;

    #
    # Convert to JSON and write file
    #
    my $JSONText = JSON::PP->new->pretty->allow_tags->encode($self);    # Catches/avoids Croak() in lib function

    die "Bad encoded JSON struct"
        unless defined $JSONText;

    eval {write_file($Filename,$JSONText)}                              # Catches/avoids Croak() in lib function
        or die "Error writing $Filename ($!)";
    }


########################################################################################################################
########################################################################################################################
#
# Load - Load library description from file
#
# Inputs:      Full path of saved library to read
#
# Outputs:     None.
#
sub Load {
    my $self     = shift;
    my $Filename = shift;

    #
    # Read file and convert from JSON
    #
    my $JSONText = eval{read_file($Filename)}                           # Catches/avoids Croak() in lib function
        or die "Cannot read $Filename ($!)";

    my $NewSelf = eval{JSON::PP->new->allow_tags->decode($JSONText)}    # Catches/avoids Croak() in lib function
        or die "Bad encoded JSON";

    %{$self} = %{$NewSelf};

    return $self;
    }


########################################################################################################################
########################################################################################################################
#
# PrintSummary - Print summary information
#
# Inputs:      None.
#
# Outputs:     None.
#
sub PrintSummary {
    my $self = shift;

    print "    Books     : " . $self->{NumBooks } . "\n";
    print "    Files     : " . $self->{NumFiles } . "\n";
    print "    Unfit     : " . $self->{NumUnfit } . "\n";
    print "    All files : " . AsMB($self->{TotalBytes}) . "\n";
    print "    Encodings : " . (scalar keys %{$self->{TotalEncs}})  . "\n";
    print "\n";
    }


########################################################################################################################
########################################################################################################################
#
# PrintLanguageSummary - Print out summary of languages
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintLanguageSummary {
    my $self = shift;

    my %Langs;

    $Langs{$_->{Lang}}++
        foreach @{$self->{Books}};

    my $NonEnglish = 0;
    $NonEnglish += $Langs{$_}
        foreach grep { $_ ne "English" and $_ ne "Olde English" } keys %Langs;

    print "Languages:\n";
    if( $Langs{OldeEnglish} ) {
        print "     Modern English: " . sprintf("%5d",$Langs{English}    ) . "\n";
        print "     Olde   English: " . sprintf("%5d",$Langs{OldeEnglish}) . "\n";
        }
    else {
        print "     English       : " . sprintf("%5d",$Langs{English}    ) . "\n";
        }
    print     "     Non-English   : " . sprintf("%5d",$NonEnglish        ) . "\n";
    print "\n";

    print "    " . sprintf("%12s",$_ eq "" ? "(none)" : $_) . ": $Langs{$_}\n"
        foreach sort { $Langs{$b} <=> $Langs{$a} } grep { $_ ne "English" and $_ ne "Olde English" } keys %Langs;

    print "\n";
    }


########################################################################################################################
########################################################################################################################
#
# PrintEncodingSummary - Print out summary of encodings
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintEncodingSummary {
    my $self = shift;

    my %Encodings;

    foreach my $Book (@{$self->{Books}}) {
        foreach my $File (keys %{$Book->{Files}}) {
            $Encodings{$Book->{Files}{$File}{Encoding}}++;
            }
        }

    print "Encodings:\n";
    print "    " . sprintf("%4d",$Encodings{$_}) . ": $_\n"
        foreach sort grep { $_ ne "" } keys %Encodings;

    print "\n";
    }


########################################################################################################################
########################################################################################################################
#
# PrintTagSummary - Print out summary of tags
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintTagSummary {
    my $self = shift;

    my %Tags;

    $Tags{$_->{Tag}}++
        foreach @{$self->{Books}};

    print "Tag summary:\n";
    print "    " . sprintf("%4d",$Tags{$_}) . ": $_\n"
        foreach sort grep { $_ ne "" } keys %Tags;

    print "\n";
    }


########################################################################################################################
########################################################################################################################
#
# PrintTaggedBooks - Print out headers for all tagged books
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintTaggedBooks {
    my $self = shift;

    print "Tagged books:\n";
    foreach my $Tagged (grep { $_->{Tag} ne "" } @{$self->{Books}}) {
        $Tagged->PrintHeader();
        print "Tag:     $Tagged->{Tag}\n";
        print "\n";
        }
    }


########################################################################################################################
########################################################################################################################
#
# PrintUnfitSummary - Print out summary of unfit messages
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintUnfitSummary {
    my $self = shift;

    my %Unfits;

    $Unfits{$_->{Unfit}}++
        foreach grep { $_->{Unfit} ne "" } @{$self->{Books}};

    print "Unfit summary:\n";
    print "    " . sprintf("%4d",$Unfits{$_}) . ": $_\n"
        foreach sort { $Unfits{$a} <=> $Unfits{$b} } keys %Unfits;

    print "\n";
    }


########################################################################################################################
########################################################################################################################
#
# PrintUnfitBooks - Print out headers for all unfit books
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintUnfitBooks {
    my $self = shift;

    print "Unfit books:\n";
    foreach my $Unfit (grep { $_->{Unfit} ne "" } @{$self->{Books}}) {
        $Unfit->PrintHeader();
        print "\n";
        }
    }


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


#
# Perl requires that a package file return a TRUE as a final value.
#
1;
