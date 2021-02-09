# Gutenberg Corpus: Installation

Extract a large corpus (3.4GB) of narrative text from Project Gutenberg, suitable for AI processing.

## Overview

* ***Get the ISO file from the Project Gutenberg website***
* Mount the ISO and scan the contained books for suitability
* Select and uncompress book files from the ISO image
* Extract narrative text from the uncompressed book files

Some steps have options. For example, the "select books" step allows the user to
specify whether to include Olde English books.

All steps should be executed from the command line, in the "bin" project subdirectory.

### 1) Download the ISO part files from the Project Gutenberg website

The Gutenberg ISO is split into many (more than 300) sub-files which must be downloaded
and stitched together into the complete ISO.

The first script **01-GetISOs.sh** wraps the wget command to manage the download operation.

The script is **restartable**, so if the process is interrupted simply
rerun the script to continue from where it left off.

This may take a long time, depending on the speed of your internet connection.

````bash
> cd bin                        # All steps happen in the bin subdirectory
> ./01-GetISOs.sh               # Retrieve ISO part files from project gutenberg website
````

When complete, the directory www.gutenberg.org/files/19159/parts will contain the
files needed to recreate the original ISO.

### 2) Create the ISO from the downloaded parts files

The next script **02-CombineISOs.sh** will combine the parts downloaded in the previous step
into the original Gutenberg ISO file. If the resultant ISO md5sum is correct, the program
will prompt the user to remove the (no longer needed) parts files.

````bash
> ./02-CombineISOs.sh           # Combine parts into single ISO file. Optionally delete original parts files
````

When complete, the Gutenberg ISO file "pgdvd072006.iso" will be in the project top-level directory.

### 3) Mount the ISO to a local directory

The next script **03-MountISO.sh** will mount the ISO file to a local directory, for
normal filesystem access.

This step requires **root** authorization, you will be prompted for your user password.

````bash
> ./03-MountISO.sh              # Mount ISO into local file
````

When complete, the Gutenberg ISO file is mounted on the directory "ISO" in the project top-level
directory. Inside this directory are the various Gutenberg books and other media, including an
index file "index.htm".
