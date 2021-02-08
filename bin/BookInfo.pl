#!/usr/bin/perl -I../lib
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2010 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      BookInfo.pl
##
##  DESCRIPTION
##      Load the library listing and print out the info for a specific book.
##
##  USAGE
##      BookInfo.pl BookNo [BookNo ...]
##
##      Print the library entry for one (or more) books.
##
##      BookNo      EText book number of book to print
##
##  EXAMPLE
##
##      BookInfo.pl 1400
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

my $LibraryFile = "$BaseDir/Library.JSON";

exit HELP_MESSAGE()
    unless @ARGV;

print "\n";
print "Loading library: $LibraryFile\n";

$Library->Load($LibraryFile);

while(my $ETextNo = shift) {

    my $Book = $Library->{Books}[$Library->{ETextToBook}{$ETextNo}];

    die "No book with ETextNo $ETextNo in Library"
        unless defined $Book;

    print "\n";
    $Book->PrintHeader();
    print "\n";
    }

exit(0);
