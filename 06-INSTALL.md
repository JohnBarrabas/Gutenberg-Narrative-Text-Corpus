# Gutenberg Corpus: Installation

Extract a large corpus (3.4GB) of narrative text from Project Gutenberg, suitable for AI processing.

## Overview

* Get the ISO file from the Project Gutenberg website
* Mount the ISO and scan the contained books for suitability
* Select and uncompress book files from the ISO image
* **Extract narrative text from the uncompressed book files**

Some steps have options. For example, the "select books" step allows the user to
specify whether to include Olde English books.

All steps should be executed from the command line, in the "bin" project subdirectory.

### 4) List all books, and check for suitability

The script **06-ExtractText.pl** will load uncompressed book files from the previous step,
separate the narrative text from the non-narrative text, and save the narrative portions
as separate files.

````bash
> ./06-ExtractText.pl           # Extract narrative text from unpacked books
````

When complete, the subdirectory "TextData" in the project top-level directory
will contain extracted narrative text files, one for each processed book.

For example:

````
> chdir ../TextData
> ls
11124.txt  11721.txt  12424.txt  13057.txt  13711.txt  14369.txt  15022.txt  1566.txt	16321.txt  16986.txt
11125.txt  11722.txt  12425.txt  13058.txt  13712.txt  14371.txt  15025.txt  15670.txt	16322.txt  16987.txt
11126.txt  11723.txt  12426.txt  1305.txt   13713.txt  14373.txt  15026.txt  15671.txt	16323.txt  16991.txt
>
````

## IgnoreList.txt

The script automatically skips books listed in the file "IgnoreList.txt" in the project
top-level directory. Add books that generate bad results to this list to eliminate
such books on future runs.

Please report problematic books back to the author, so that they may be
added to the project IgnoreList.txt file for use by others.

## Heuristic algorithm

The narrative text heuristic is, as all heuristics are, chosen by the project author based on
"what seems good". Users are encouraged to modify and improve the heuristic to meet their
individual needs.

With over 11,000 books in the corpus, the results have not been manually checked.
Spot checks look good, but the end user is ultimately responsible for ensuring the quality
of any narrative text they use.

The separation process splits the book text into paragraphs on "blank line" boundaries, then determines the
narrative text on a paragraph-by-paragraph basis. Narrative paragraphs are kept, non-narrative paragraphs
are placed into a "junk" array.

Generally, a narrative paragraph:

1) Begins with a capital letter
2) The 2nd letter is lowercase
3) Ends with a period, exclamation point, question, comma, or colon

Generally, a non-narrative paragraph:

1) Is mostly uppercase
2) Is indented (inline poems)

Generally, a file is discarded as non-narrative if:

1) Fewer than 100 lines are deemed narrative
2) Less than 20% of the text is deemed narrative

Exceptions and corner cases are implemented to correct for quoted text (double quote chars are
skipped), single-char words in English (A, I, O), contractions ("I'll" as first
word), and so on.

The result of the heuristic generates narrative text of good quality, while placing some of the
obviously narrative (to a human reader) text with the junk. The paragraphs will for the most
part  correlate with nearby paragraphs in subject matter and tone.

The user can check the selection criteria by passing extra arguments to the script:

````
## 06-ExtractText.pl [--keep-junk] [--print-junk] [--print-keep]
##
## Where:
##
##     --keep-junk     Write out junk paragraphs to a separate file
##     --print-junk    Print out junk paragraphs when encountered
##     --print-keep    Print out kept paragraphs when encountered
##
````

When the "--keep-junk" argument is present, the non-narrative paragraphs are stored in a parallel file
with a ".jnk" extension. Each paragraph includes a header indicating the heuristic rule that flagged
the paragraph as junk.

for example:

````
# (excerpt from 18570.jnk)
#
=====Mostly UC
CHAPTER I.

=====No sentence end
[Illustration]

=====Mostly UC
YULE-TIDE OF THE ANCIENTS

=====Indented lines
    "There in the Temple, carved in wood,
    The image of great Odin stood,
    And other gods, with Thor supreme among them."
````

The user is encouraged to modify and improve the heuristic to meet their specific needs.

Please send improvements to the author, so that the changes may be included
and made available to others.
