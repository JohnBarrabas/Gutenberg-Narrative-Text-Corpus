# Gutenberg Corpus: Installation

Extract a large corpus (3.4GB) of narrative text from Project Gutenberg, suitable for AI processing.

## Overview

* Get the ISO file from the Project Gutenberg website
* Mount the ISO and scan the contained books for suitability
* **Select and uncompress book files from the ISO image**
* Extract narrative text from the uncompressed book files

Some steps have options. For example, the "select books" step allows the user to
specify whether to include Olde English books.

All steps should be executed from the command line, in the "bin" project subdirectory.

### 5) Unpack books and remove the Project Gutenberg headers and footers

The Gutenberg project adds a lengthy header and footer to each book text
in the ISO. This step selects books for processing, uncompresses these
books, and removes the headers and footers.

By default, the process will extract all modern English (and no Olde English)
books from the ISO, some 11,000 titles.

````bash
> ./05-ExtractFiles.pl      # Extract all books and remove headers/footers
````

When complete, the subdirectory "ISOFiles" in the project top-level directory
will contain the uncompressed books.

For example:

````
> chdir ../ISOFiles
> ls
11124.txt  11721.txt  12424.txt  13057.txt  13711.txt  14369.txt  15022.txt  1566.txt	16321.txt  16986.txt
11125.txt  11722.txt  12425.txt  13058.txt  13712.txt  14371.txt  15025.txt  15670.txt	16322.txt  16987.txt
11126.txt  11723.txt  12426.txt  1305.txt   13713.txt  14373.txt  15026.txt  15671.txt	16323.txt  16991.txt
>
````

The user may want fewer books, and may want to include Olde English as well.


````
## 05-ExtractFiles.pl  [--max-save n] [--include-olde] [--only-olde] [--save-failures]
## 
##      --max-save n        Maximum number of files to extract/save
##
##      --include-olde      Include "Olde English" texts along with modern English
##      --only-olde         Only extract "Olde English" texts, no modern English
##
##      --save-failures     Extract/Save texts that fail the selection process (for debugging)
````

Some examples:

````
#
# Extract a randomized 50 (of the 100 or so) texts that are in "Olde English", remove the
#   Gutenberg headers/footers, and save the results as $ETextNo.txt in the "../ISOFiles/" directory.
#
> 05-ExtractFiles.pl --max-save 50 --only-olde

#
# Extract 500 books, both Modern and Olde English, to the "../ISOFiles/" directory.
#
> 05-ExtractFiles.pl --max-save 500 --include-olde
````
