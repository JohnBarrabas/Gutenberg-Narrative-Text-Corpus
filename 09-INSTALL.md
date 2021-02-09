# Gutenberg Corpus: Installation

Extract a large corpus (3.4GB) of narrative text from Project Gutenberg, suitable for AI processing.

## Overview

* Download the ISO file from the Project Gutenberg website
* Mount the ISO and scan the contained books for suitability
* Select and uncompress book files from the ISO image
* Extract narrative text from the uncompressed book files

Some steps have options. For example, the "select books" step allows the user to
specify whether to include Olde English books.

All steps should be executed from the command line, in the "bin" project subdirectory.

### [Optional] Create an ISO file with the library listing and text files

The script **09-MakeISO.sh** will create a new ISO file containing the library file and the
narrative text files, which is easily copied, sent, stored offline, or mounted as needed.

This step is optional and only needed to save disk space, or
to more easily move files to a different computer.

````bash
> cd bin
> ./09-MakeISO.sh             # Create NarrativeText.iso from Listing and narrative text files
````
