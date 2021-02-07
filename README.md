# Gutenberg-Narrative-Text-Corpus

Extracts a large corpus (3.4GB) of narrative text from Project Gutenberg, suitable for AI processing.

## Overview

This project downloads an ISO (DVD) file of books from the Gutenberg free library and separates
paragraphs of narrative text from the "book markup" embedded in the file: title, chapter headings,
footnotes, section breaks, and so on.

The output of the process is a large collection (over 11,000 files, 3.4GB) of narrative
text from the original books.

The following are typical narrative text paragraphs:

````
The little girls did not answer. And he went out thinking, "These
children are really wonderful! What devotion one sees! And yet the
country is not yet fully roused!"

There is no affectation about this illustrious pair, the Duke never
poses in relation to affairs of State, and the Duchess has a natural
grace all her own, to which art can add no touch of dignity.

"Arriving at Springfield, you are to deliver this envelope into the hands
of Mr. Abraham Lincoln, of the law firm of Lincoln & Herndon."
````

The following are typical of the removed text, along with the reason for removal:

````
=====Mostly UC
THE HARVARD CLASSICS EDITED BY CHARLES W. ELIOT LL.D.

=====Mostly UC
PREFACES AND PROLOGUES TO FAMOUS BOOKS

=====Indented lines
  PREFACES TO VARIOUS VOLUMES OF POEMS
                                        WILLIAM WORDSWORTH
  APPENDIX TO LYRICAL BALLADS           WILLIAM WORDSWORTH
  ESSAY SUPPLEMENTARY TO PREFACE        WILLIAM WORDSWORTH

=====Indented lines
     "I have borrowed Steve for a day or two, and guarantee
     to return him a good Republican.
                  A. LINCOLN."
=====No sentence end
                           Translated by
=====No sentence start
"/Si/," said the Italian, discreetly.
````
The system is modular and commented, feel free to modify the extraction scripts
or add your own as needed.

## System requirements

The project requires bash and perl, and so should run on any linux system. Linux
installs Perl by default.

The author has no access to a windows machine, but perl is the most portable language
so the text extraction sections of the project should run on any installed perl system
such as Strawberry Perl. The process is modular, so you can download the ISO separately
using Windows utilities and continue with the perl sections.

The maximum extraction process (extract and save all text from all files) requires about
13GB of free disk space. About 3.4GB of the maximum output is the narrative text,
the rest being temporary files (and similar) that can be discarded once the
narrative text files are complete.

Optionally, less than the maximum can be extracted.

## Installation overview

The file [INSTALL.md](file:INSTALL.md) describes the install process in detail.

### General instructions:

After cloning the repo, cd to the "bin" directory and run the scripts
found there in order:

````
> git clone git@github.com:JohnBarrabas/Gutenberg-Narrative-Text-Corpus.git
> cd bin
> ./01-GetISOs.sh             # Retrieve  ISO file parts from project gutenberg
> ./02-CombineISOs.sh         # Combine   ISO part files into ISO file
> ./03-MountISO.sh            # Mount the ISO to a local directory
> ./04-ParseIndex.pl          # Read the  ISO index file and scan books for encodings
> ./05-ExtractFiles.pl        # Extract   ISO files and remove Gutenberg headers
> ./06-ExtractText.pl         # Separate narrative text, save as separate files
````

Once all scripts have run, the subdirectory "Gutenberg-Narrative-Text-Corpus/TextData"
will contain a list of extracted narrative text files.

Additionally, the process will generate "Gutenberg-Narrative-Text-Corpus/Library.JSON",
a database of the Gutenberg book information: title, author, encoding, language,
and so on.

The Library.JSON file may be loaded by your program (perl, javascript, or python) to
facilitate further processing.

For example:

````
> chdir ../TextData
> ls
11124.txt  11721.txt  12424.txt  13057.txt  13711.txt  14369.txt  15022.txt  1566.txt	16321.txt  16986.txt
11125.txt  11722.txt  12425.txt  13058.txt  13712.txt  14371.txt  15025.txt  15670.txt	16322.txt  16987.txt
11126.txt  11723.txt  12426.txt  1305.txt   13713.txt  14373.txt  15026.txt  15671.txt	16323.txt  16991.txt
>
````

The file "11721.txt" contains extracted narrative text from the book with ETextNo: 11721 by Gutenberg's
internal numbering scheme.

Opening Library.JSON in a text editor, we see that the book with ETextNo: 11721 is:

````
"ETextNo" : "11721",
"Title"   : "O. Henry Memorial Award Prize Stories of 1920",
"Lang"    : "English",
"Author"  : "Various",
````

Opening the file "11721.txt" in a text editor shows paragraphs of narrative text, including:

````
"I think such calls as this are always very useless, but then--"

Cecil experienced a sudden impulsive warmth. "After all, what did
she or any one else know about other peoples' lives? Poor souls!
What a base thing life often was!"

"Yes, I think you would. You--I have watched you both. You don't mind,
do you? I think you're both rather great people--at least, my idea
of greatness."
````

For ease of printing and editing, the files retain their original Gutenberg
pagination. To remove the pagination and use the files in a program:

1) Load the file into a text variable
2) Split the text into paragraphs on &lt;NL&gt;&lt;NL&gt; boundaries
3) For each paragraph, replace any remaining &lt;NL&gt; chars with space

The perl to do that would be:

````perl
my $Text = eval{read_file($File)}
    or die "Cannot read file $File ($!)";

my @Paras = split /\n\n/,$Text;             # Split text block into paragraphs

@Paras = map {     length($_) } @Paras;     # Remove blank paragraphs
@Paras = map { $_ =~ s/\n/ /g } @Paras;     # Change remaining NLs to spaces

````