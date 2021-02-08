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
##      Site::Book.pm
##
##  DESCRIPTION
##
##       Encapsulation of meta information about a single Gutenberg book 
##
##  DATA
##
##      ->{ETextNo}                 Project Gutenberg EText number
##      ->{Title}                   Title
##      ->{Author}                  Author
##      ->{Lang}                    Language (ex: "English")
##      ->{Files}->                 List of files comprising book
##          {$Filename}->               Filename of file
##              {File}                      Filename of file
##
##              If LoadText() has been called:
##
##              {Encoding}                  Purported Encoding (from file text)
##              {Size}                      Size of file (bytes, after unzip)
##
##      ->{Unfit}                   Msg describing why book can't be used (ex: "Language not English")
##      ->{Tag}                     Tag that describes book in some way
##
##      ->{Text}                    File contents (if LoadText() has been called)
##
##  FUNCTIONS
##
##      ->new($DivText,$DataDir)    Make a new Book by parsing the passed <div> text
##
##      ->LoadText($File)           Load contents of book file
##      ->SaveText($Dest)           Save text as specified Destination
##      ->UnloadText()              Free up local storage holding file contents
##
##      ->ParseEncoding()           Parse text, return encoding
##      ->RemoveGutenberg($File)    Remove gutenberg header/footer from text
##
##      ->PrintHeader()             Print out header info plus files and unfit info
##      ->PrintDesc  ()             Print out header info
##      ->PrintFiles ()             Print out list of files
##      ->PrintUnfit ()             Print out unfit msg
##      ->PrintTag   ()             Print out tag msg
##
##      ->AssertDiv($Test,$Msg)     Set Unfit msg if test fails
##      ->TagDiv   ($Test,$Msg)     Set Tag   msg if test fails
##
##      ->BOL($Index)               Return index of BOL (Beginning-Of-Line) in text starting at $Index
##      ->EOL($Index)               Return index of EOL                     in text starting at $Index
##      ->NextBlankLine($Index)     Return index of next blank line         in text starting at $Index
##      ->TrimBlankLines()          Remove blank lines at start/end of text
##
##      ->IsOlde()                  Return TRUE if text satisfies conditions for Olde English
##      ->IsASCII($File)            Return TRUE if file encoding is some form of ASCII
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

package Site::Book;
    use base Site::JSONStorable;

use strict;
use warnings;
use Carp;

use File::Slurp qw(read_file write_file);
use File::Path  qw(remove_tree);
use File::Basename;
use IO::Uncompress::Unzip qw(unzip $UnzipError) ;

########################################################################################################################
########################################################################################################################
##
## Data declarations
##
########################################################################################################################
########################################################################################################################

# <font color="#b76b15">EText-No.</font> 12764<br />
# <font color="#b76b15">Title:</font> The Forty-Niners - A Chronicle of the California Trail and El Dorado<br />
# <font color="#b76b15">Author:</font> White, Stewart Edward, 1873-1946<br />
# <font color="#b76b15">Language:</font> English<br />
# <font color="#b76b15">Link:</font> 
#   <a href="1/2/7/6/12764/12764-8.zip">1/2/7/6/12764/12764-8.zip</a><br /><font color="#b76b15">Link:</font> 
#   <a href="1/2/7/6/12764/12764.zip">1/2/7/6/12764/12764.zip</a>
#
our $ETextMatch  = qr|<font\scolor="#.*">EText-No.</font>\s*(\d*?)<br\s/>|;
our $TitleMatch  = qr|<font\scolor="#.*">Title:</font>\s(.*?)<br\s/>|;
our $AuthorMatch = qr|<font\scolor="#.*">Author:</font>\s(.*?)<br\s/>|;
our $LangMatch   = qr|<font\scolor="#.*">Language:</font>\s(.*?)<br\s/>|;
our $FilesMatch  = qr|<a\shref="(.*?)">|;

our @IgnoredExtensions = ( ".mp3", ".mid", ".htm", ".pdb", ".tex", ".ps", ".ly", ".mpg", ".pdf", ".xml", ".rtf", ".eng" );

########################################################################################################################
########################################################################################################################
#
# Site::Book - Parse <div> text and generate new book listing
#
# Inputs:   Text between <div>...</div> elements
#
# Outputs:  Text corpus descriptor object
#
sub new {
    my $proto   = shift;
    my $class   = ref($proto) || $proto;
    my $DivText = shift;
    my $DataDir = shift;

    die "Book: No <div> text supplied"
        unless defined $DivText and length $DivText;

    die "Book: DataDir $DataDir doesn't exist"
        unless -d $DataDir;

#     print "$DivText\n";
#     print "\n";

    #
    # <font color="#b76b15">EText-No.</font> 12764<br />
    # <font color="#b76b15">Title:</font> The Forty-Niners - A Chronicle of the California Trail and El Dorado<br />
    # <font color="#b76b15">Author:</font> White, Stewart Edward, 1873-1946<br />
    # <font color="#b76b15">Language:</font> English<br />
    # <font color="#b76b15">Link:</font> 
    #   <a href="1/2/7/6/12764/12764-8.zip">1/2/7/6/12764/12764-8.zip</a><br /><font color="#b76b15">Link:</font> 
    #   <a href="1/2/7/6/12764/12764.zip">1/2/7/6/12764/12764.zip</a>
    #
    my ($ETextNo) = ($DivText =~ $ETextMatch);
    my ($Title  ) = ($DivText =~ $TitleMatch);
    my ($Author ) = ($DivText =~ $AuthorMatch);
    my ($Lang   ) = ($DivText =~ $LangMatch);
    my @Files     = ($DivText =~ m/$FilesMatch/g);

    my $self = bless { ETextNo => $ETextNo,
                       Title   => $Title  ,
                       Author  => $Author ,
                       Lang    => $Lang   ,
                       Files   => {},
                       Unfit   => "",
                       Tag     => "",
                       Text    => "",
                       }, $class;

    $self->AssertDiv(ref($self->{ETextNo}) eq "" ,"ETextNo is not scalar");
    $self->AssertDiv(ref($self->{  Title}) eq "" ,"Title is not scalar"  );
    $self->AssertDiv(ref($self->{ Author}) eq "" ,"Author is not scalar" );
    $self->AssertDiv(ref($self->{   Lang}) eq "" ,"Lang is not scalar"   );

    foreach my $File (@Files) {
        my ($Ext) = $File =~ /(\.[^.]+)$/;
        $self->AssertDiv(grep(/^$Ext$/, @IgnoredExtensions) == 0,"Filetype " . sprintf("%-4s",$Ext) . " not supported");
        $self->AssertDiv($Ext eq ".zip" or $Ext eq ".txt","Filetype " . sprintf("%-4s",$Ext) . " not zip or txt");
        $self->AssertDiv(-r "$DataDir/$File", "File does not exist");
        $self->AssertDiv(-s "$DataDir/$File", "File is empty");

        $self->{Files}{$File} = { File     => $File,
                                  Size     => 0,            # Size undetermined until unzip
                                  Encoding => "",
                                  };
        }

    $self->AssertDiv($self->{ETextNo} =~ m/\d/   ,"ETextNo not a number"   );
    $self->AssertDiv($self->{Title}   !~ m/\n/   ,"Title contains newline" );
    $self->AssertDiv($self->{Author}  !~ m/\n/   ,"Author contains newline");
    $self->AssertDiv($self->{Lang}    !~ m/\n/   ,"Lang contains newline"  );

    $self->AssertDiv(length($self->{Lang}) > 0   ,"Lang blank"             );
    $self->AssertDiv($self->{Lang} eq "English"  ,"Lang not English"  );

    $self->AssertDiv(scalar @Files               ,"No files specified");

    $self->AssertDiv($self->{ETextNo} !~ m/[<>]/ ,"ETextNo contains HTML");
    $self->AssertDiv($self->{Author}  !~ m/[<>]/ ,"Author contains HTML" );
    $self->AssertDiv($self->{Lang}    !~ m/[<>]/ ,"Lang contains HTML"   );

    $self->TagDiv($self->{Title}      !~ m/[<>]/ ,"Title contains HTML"  );

    $self->AssertDiv($self->{Title}   !~ m/poem/i ,"Title contains 'poem'");
    $self->AssertDiv($self->{Title}   !~ m/poetr/i,"Title contains 'poetr'");

#    PrintDesc($self);

    return $self;
    }


########################################################################################################################
########################################################################################################################
#
# LoadText - Load text of book file
#
# Inputs:   Book file of interest (one of the keys from $self->{Files})
#           Data dir containing book file
#
# Outputs:  TRUE  if text successfully loaded
#           FALSE if error, and $self->{Unfit} is set
#
#           $self->{Text}                   => <contents of file>
#           $self->{Files}{$File}{Encoding} => Parsed encoding from file
#           $self->{Files}{$File}{Size    } => Size of file (bytes)
#
# NOTE: Errors stemming from the file make the file unfit. Errors of programming (including bad args)
#         are considered fatal.
#
sub LoadText {
    my $self    = shift;
    my $File    = shift;
    my $DataDir = shift;

    die "Invalid file $File (accessing $self->{ETextNo})"
        unless defined $self->{Files}{$File};

    my $Filename = "$DataDir/$File";
    my ($Ext) = $Filename =~ /(\.[^.]+)$/;

    if( $Ext eq ".txt" ) {
        my $Text = eval{read_file($Filename)};          # Catches/avoids Croak() in lib function

        unless( $Text ) {
            $self->{Unfit} = "Cannot read zip file ($!)";
            return 0;
            }

        $self->{Text} = $Text;
        $self->{Files}{$File}{    Size} = length($Text);
        $self->{Files}{$File}{Encoding} = $self->ParseEncoding();

        if( $self->IsASCII($File) ) {
            $self->{Lang} = "OldeEnglish"
                if $self->IsOlde();
            }

        return 1;
        }

    #
    # Gah! The IO::Uncompress::Unzip module doesn't handle all the compression formats, but
    #   the local unzip command does.
    #
    # Use a circuitious route instead.
    #
    if( $Ext eq ".zip" ) {
        my $TmpDir = "/tmp/Book";

        remove_tree($TmpDir)
            if -d $TmpDir;

        mkdir $TmpDir
            or die "Cannot make $TmpDir ($!)";

        `unzip $Filename -d $TmpDir`;

        my @Files = <"$TmpDir/*">;

        unless( scalar @Files == 1 ) {
            $self->{Unfit} = "Zip contains multiple files";
            return 0;
            }

        my $Text = eval{read_file($Files[0])};              # Catches/avoids Croak() in lib function

        unless( $Text ) {
            $self->{Unfit} = "Cannot read zip file ($!)";
            return 0;
            }

        $self->{Text} = $Text;
        $self->{Files}{$File}{    Size} = length($Text);
        $self->{Files}{$File}{Encoding} = $self->ParseEncoding();

        if( $self->IsASCII($File) ) {
            $self->{Lang} = "OldeEnglish"
                if $self->IsOlde();
            }

        unlink(<"$TmpDir/*">);
        return 1;
        }

    die "Unsupported file extension $Ext";
    }


########################################################################################################################
########################################################################################################################
#
# ParseEncoding - Parse a text and return the embedded encoding
#
# Inputs:   None. Uses internal file text
#
# Outputs:  Encoding, taken from encoding line of text
#
sub ParseEncoding {
    my $self = shift;

    #
    # Be careful with MAC encoded EOL nonsense that can frack the encoding regex.
    #
    $self->{Text} =~ s/\r\n/\n/g;
    $self->{Text} =~ s/\r/\n/g;

    my ($Encoding) = $self->{Text} =~ m/encoding:\s*(.*?)\n/g;

    $Encoding = $Encoding //= "(none)";
    $Encoding =~ s/\r|\n//g;            # Remove EOL chars
    $Encoding =~ s/^\s+|\s+$//g;        # Remove leading and trailing spaces

    return $Encoding;
    }


########################################################################################################################
########################################################################################################################
#
# SaveText - Save text to specified file
#
# Inputs:   Filename to save to
#
# Outputs:  None.
#
sub SaveText {
    my $self = shift;
    my $File = shift;

    eval {write_file($File,$self->{Text})}              # Catches/avoids Croak() in lib function
        or die "SaveText: Error writing $File ($!)";
    }


########################################################################################################################
########################################################################################################################
#
# UnloadText - Unload (drop, delete) file text
#
# Inputs:   None.
#
# Outputs:  Loaded text data is deleted
#
sub UnloadText { my $self = shift; undef $self->{Text}; }


########################################################################################################################
########################################################################################################################
#
# RemoveGutenberg - Remove the Gutenberg header and footer from the file
#
# Inputs:   None - Local text object is processed.
#
# Outputs:  TRUE  if processed text seems OK for AI purposes
#           FALSE otherwise (and Defect is set)
#
# Notes: Additionally, the text body is checked for compliance with an ASCII encoding, and minimum length.
#          Any failures note the book as "Unfit".
#
sub RemoveGutenberg {
    my $self = shift;

    my @Guts;
    $_ = $self->{Text};
    push @Guts,pos
        while m/Gutenberg/igs;

    #
    # Take the midpoint of the text. The Gutenberg header is everything up to the last instance of "Gutenberg"
    #   before the midpoint. The footer is the first instance of "Gutenberg" after the midpoint, to the end.
    #
    my $Midpoint  = int length($self->{Text})/2;
    my $HeaderLoc = 0;
    my $FooterLoc = 0;

    foreach my $GutLoc (@Guts) {
        $HeaderLoc = $GutLoc
            if $GutLoc < $Midpoint;

        $FooterLoc = $GutLoc
            if $GutLoc > $Midpoint and $FooterLoc == 0;
        }

    $HeaderLoc = $self->EOL($HeaderLoc);
    $FooterLoc = $self->BOL($FooterLoc);

    substr($self->{Text},  $FooterLoc) = "";
    substr($self->{Text},0,$HeaderLoc) = "";

    $self->TrimBlankLines();

    my $FirstLine = substr($self->{Text},0,$self->EOL(0));

    #
    # Remove "Produced by" and any subsequent text, up to blank line
    #
    if( $FirstLine =~ m/produced/i ) {
        my $NextBlankLine = $self->NextBlankLine(0);
        substr($self->{Text},0,$NextBlankLine) = "";
        $self->TrimBlankLines();
        }

    if( length($self->{Text}) < 10000 ) {
        $self->{Unfit} = "Text between header/footer too short";
#print "Too short: $self->{ETextNo} (length=" . (length($self->{Text})) . ")\n";
        return 0;
        }

    if( $self->{Text} !~ m/[\x00-\x7f]/ ) {
        $self->{Unfit} = "Non-ASCII characters detected";

        my ($Char) = $self->{Text} !~ m/[\x00-\x7f]/;
#print "Non Ascii: $self->{ETextNo} " . sprintf("0x%x",ord($Char)) . "\n";
        return 0;
        }

    return 1;
    }


########################################################################################################################
########################################################################################################################
#
# AssertDiv - Assert correctness of DIV tag text
#
# Inputs:   Test to assert (== TRUE or FALSE)
#           Error msg to print if test fails
#
# Outputs:  None. Book->{Unfit} is conditionally set
#
sub AssertDiv {
    my $self = shift;
    my $Test = shift;
    my $Msg  = shift;

    #
    # If the first test has failed, subsequent tests will be invalid.
    #
    return
        unless $self->{Unfit} eq "";

    return
        if $Test;

    $self->{Unfit} = $Msg;
    }


########################################################################################################################
########################################################################################################################
#
# TagDiv - Set a tag on a book, based on <div> text
#
# Inputs:   Test to assert (== TRUE or FALSE)
#           Msg describing tag
#
# Outputs:  None. Book->{Tag} is conditionally set
#
sub TagDiv {
    my $self = shift;
    my $Test = shift;
    my $Msg  = shift;

    #
    # Skip if already tagged.
    #
    return
        unless $self->{Tag} eq "";

    return
        if $Test;

    $self->{Tag} = $Msg;
    }


########################################################################################################################
########################################################################################################################
#
# PrintHeader - Print out complete header info for book
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintHeader {
    my $self = shift;

    PrintDesc ($self);
    PrintUnfit($self);
    PrintFiles($self);
    }


########################################################################################################################
########################################################################################################################
#
# PrintDesc - Print out one book description
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintDesc {
    my $self = shift;

    print "Title:   \"$self->{Title}\"\n";
    print "ETextNo: $self->{ETextNo}\n";
    print "Author:  $self->{Author}\n";
    print "Lang:    $self->{Lang}\n";
    }


########################################################################################################################
########################################################################################################################
#
# PrintFiles - Print out files for one book
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintFiles {
    my $self = shift;

    print "Files:\n";
    print "    $_\n"
        foreach sort keys %{$self->{Files}};        # Keys are full paths
    }


########################################################################################################################
########################################################################################################################
#
# PrintUnfit - Print out one book unfit reason
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintUnfit {
    my $self = shift;

    print "Unfit:   $self->{Unfit}\n";
    }


########################################################################################################################
########################################################################################################################
#
# PrintTag - Print out one book tag
#
# Inputs:   None.
#
# Outputs:  None. Text is printed
#
sub PrintTag {
    my $self = shift;

    print "    Tags: " . ($self->{Tag} eq "" ? "<none>" : $self->{Tag}) . " \n";
    }


########################################################################################################################
########################################################################################################################
#
# BOL - Return index of BOL starting at index
#
# Inputs:   Index to start at.
#
# Outputs:  Index of nearest prev BOL
#
# Note: If text is NL at the $Index, $Index is returned
#
sub BOL {
    my $self  = shift;
    my $Index = shift;

    $Index--
        while substr($self->{Text},$Index,1) ne "\n";

    return $Index;
    }


########################################################################################################################
########################################################################################################################
#
# EOL - Return index of EOL starting at index
#
# Inputs:   Index to start at.
#
# Outputs:  Index of nearest prev EOL
#
# Note: If text is NL at the $Index, $Index is returned
#
sub EOL {
    my $self  = shift;
    my $Index = shift;

    $Index++
        while substr($self->{Text},$Index,1) ne "\n";

    return $Index;
    }


########################################################################################################################
########################################################################################################################
#
# NextBlankLine - Return index of next blank line
#
# Inputs:   Index to start at.
#
# Outputs:  Index of nearest next NL/NL pair
#
# Note: If text is NL/NL at the $Index, $Index is returned
#
sub NextBlankLine {
    my $self  = shift;
    my $Index = shift;

    $Index++
        while substr($self->{Text},$Index,2) ne "\n\n";

    return $Index;
    }


########################################################################################################################
########################################################################################################################
#
# TrimBlankLines - Remove dangling NL chars at beginning and end of text
#
# Inputs:   None.
#
# Outputs:  None. Text is modified in place.
#
sub TrimBlankLines {
    my $self  = shift;

    substr($self->{Text},0,1) = ""
        while substr($self->{Text},0,1) eq "\n";

    substr($self->{Text},-1) = ""
        while substr($self->{Text},-1) eq "\n";

    $self->{Text} .= "\n";
    }


########################################################################################################################
########################################################################################################################
#
# IsOlde - Return TRUE if text satisfies conditions for Olde English
#
# Inputs:   Text to check
#
# Outputs:  TRUE  if text appears to be Olde English
#           FALSE otherwise
#
sub IsOlde {
    my $self = shift;

    #
    # The string "selfe" seems to be a good indicator of Olde English (selfe, himselfe, myselfe, &c). There are
    #   no words that contain "selfe" followed by more chars in the corpus.
    #
    my $SelfeCount = () = ($self->{Text} =~ /selfe/g);

    return 1
        if $SelfeCount > 3;

    return 0;
    }


########################################################################################################################
########################################################################################################################
#
# IsASCII - Return TRUE if encoding is some form of ASCII
#
# Inputs:   Book to check
#           File of book to check
#
# Outputs:  TRUE  if encoding is ASCII
#           FALSE otherwise
#
sub IsASCII {
    my $self = shift;
    my $File = shift;

    my $Encoding = $self->{Files}{$File}{Encoding};

    die "No encoding for $self->{ETextNo}.$File"
        unless defined $Encoding and length $Encoding;

    return 1
        if $Encoding eq "ASCII";

    return 1
        if substr($Encoding,0,10) eq "ISO-646-US";

    return 1
        if substr($Encoding,0,10) eq "US-ASCII";

    return 1
        if substr($Encoding,0,10) eq "US-ASCII<p>";
    }



#
# Perl requires that a package file return a TRUE as a final value.
#
1;
