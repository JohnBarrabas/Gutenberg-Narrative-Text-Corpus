# Gutenberg Corpus: Installation

Extract a large corpus (3.4GB) of narrative text from Project Gutenberg, suitable for AI processing.

## Overview

* Get the ISO file from the Project Gutenberg website
* **Mount the ISO and scan the contained books for suitability**
* Select and uncompress book files from the ISO image
* Extract narrative text from the uncompressed book files

Some steps have options. For example, the "select books" step allows the user to
specify whether to include Olde English books.

All steps should be executed from the command line, in the "bin" project subdirectory.

### 4) List all books, and check for suitability

The script **04-ParseIndex.pl** will read and parse parse the directory file "indexbig.htm" in
the ISO directory, noting all media. It will attempt to open each text file and determine the
language and encoding from the Gutenberg header.

This will take several minutes.

````bash
> ./04-ParseIndex.pl            # Parse the index file and collect info on all books.
````

When complete, the script will create the library catalog file "Library.JSON" in the
project top-level directory.

The catalog is JSON encoded, suitable for loading into a program you write. The
format is human-readable, so in a pinch you can examine entries with a text editor.

Some books at this step are automatically deemed "unfit" for narrative text processing for
various reasons. Rejections can be due to a non-English language, books of poetry
(which are assumed non-narrative), non-text files, and so on.

When complete, the script will print a summary of reasons with the book
counts for each.

An example output from this step:

````
Scanned 17541 books:
    Total Size:   8168.68 MB
    Encodings:    38
    Elapsed time: 00:05:35

Languages:
     Modern English: 15149
     Olde   English:   102
     Non-English   :  2392

          French: 873
          German: 356
         Finnish: 307
           Dutch: 208
         Spanish: 118
     OldeEnglish: 102
         Italian: 70
         Chinese: 64
      Portuguese: 54
         Tagalog: 44
          (none): 36
         Swedish: 32
           Latin: 31
          Danish: 17
         Catalan: 12
       Esperanto: 9
       Norwegian: 8
           Welsh: 7
       Bulgarian: 6
           Greek: 5
       Icelandic: 4
          Polish: 4
        Friulano: 3
         Serbian: 3
         Russian: 3
           Nauru: 3
           Czech: 2
           Iloko: 2
        Japanese: 2
          Hebrew: 1
       Iroquoian: 1
        Romanian: 1
        Sanskrit: 1
     Interlingua: 1
           Irish: 1
         Burmese: 1


Encodings:
    2552: (none)
    9278: ASCII
       2: ASCII (with a few ISO-8859-1 characters)
       1: ASCII, with 2 ISO-8859-1 characters
       4: ASCII, with a couple of ISO-8859-1 characters
      15: ASCII, with a few ISO-8859-1 characters
       1: ASCII, with one ISO-8859-1 character
      13: ASCII, with some ISO-8859-1 characters
       1: ASCII, with two ISO-8859-1 characters
       4: CP-1252
       1: EUC-KR
       1: IDO-8859-1
      30: ISO 8859-1
       1: ISO 8859-1 (Latin-1)
     120: ISO Latin-1
    1384: ISO-646-US (US-ASCII)
       1: ISO-8858-1
    5245: ISO-8859-1
       2: ISO-LATIN-1
     262: ISO-Latin-1
       3: ISO8859-1
      11: ISO8859_1
       2: ISO=8859-1
       1: Latin 1
      51: Latin-1
      42: Latin1
       1: MAC
       3: MP3
       1: MPEG
    1071: US-ASCII
       3: US-ASCII</p>
     237: UTF-8
       2: UTF8
      20: Unicode UTF-8
       1: Windows Code Page 1252
       1: Windows-1252
     274: iso-8859-1
       3: utf-8


Unfit summary:
       1: Filetype .pdb not supported
       1: Filetype .ps  not supported
       1: Filetype .rtf not supported
       1: Filetype .ly  not supported
       1: Filetype .eng not supported
       2: Filetype .tex not supported
       3: Filetype .xml not supported
       4: Filetype .mpg not supported
       4: Filetype .mp3 not supported
       5: Filetype .mid not supported
       5: Filetype .pdf not supported
      26: Lang blank
      48: Zip contains multiple files
      51: Title contains 'poetr'
      95: Filetype .htm not supported
     266: Title contains 'poem'
     377: Cannot read zip file (Is a directory)
     385: Size < 40000 bytes
    2254: Lang not English

14821 books available for narrative text processing.
````
