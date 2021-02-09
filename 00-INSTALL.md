# Gutenberg Corpus: Installation

Extract a large corpus (3.4GB) of narrative text from Project Gutenberg, suitable for AI processing.

## Preliminary step

The script "00-PerlLibs.sh" installs extra perl libraries needed for the project.

All steps should be executed from the command line, in the "bin" project subdirectory.

The script is restartable, so if the process is interrupted simply
rerun the script to continue from where it left off.

This may take a long time, depending on the speed of your internet connection.

````bash
> cd bin                        # All steps happen in the bin subdirectory
> ./00-PerlLibs.sh              # Install extra perl libs, if needed
````

On first run, the script will generate a torrent of incomprehensible text.
The recommended procedure is to run this script twice: once to load and install
the libraries, and a second time to verify that the libraries were installed correctly.

On the second run, if everything installed correctly the user should see a list of
"up to date" messages for each package.

Something like this:

````
Reading '/root/.cpan/Metadata'
  Database was generated on Mon, 08 Feb 2021 16:41:03 GMT
CPAN: Module::CoreList loaded ok (v5.20170922_26)
Carp is up to date (1.50).
Reading '/root/.cpan/Metadata'
  Database was generated on Mon, 08 Feb 2021 16:41:03 GMT
CPAN: Module::CoreList loaded ok (v5.20170922_26)
File::Basename is up to date (2.85).
Reading '/root/.cpan/Metadata'
  Database was generated on Mon, 08 Feb 2021 16:41:03 GMT
CPAN: Module::CoreList loaded ok (v5.20170922_26)
File::Slurp is up to date (9999.32).
Reading '/root/.cpan/Metadata'
  Database was generated on Mon, 08 Feb 2021 16:41:03 GMT
CPAN: Module::CoreList loaded ok (v5.20170922_26)
FindBin is up to date (1.52).
Reading '/root/.cpan/Metadata'
  Database was generated on Mon, 08 Feb 2021 16:41:03 GMT
CPAN: Module::CoreList loaded ok (v5.20170922_26)
List::Util is up to date (1.55).
Reading '/root/.cpan/Metadata'
  Database was generated on Mon, 08 Feb 2021 16:41:03 GMT
CPAN: Module::CoreList loaded ok (v5.20170922_26)
File::Path is up to date (2.18).
Reading '/root/.cpan/Metadata'
  Database was generated on Mon, 08 Feb 2021 16:41:03 GMT
CPAN: Module::CoreList loaded ok (v5.20170922_26)
IO::Uncompress::Unzip is up to date (2.100).
Reading '/root/.cpan/Metadata'
  Database was generated on Mon, 08 Feb 2021 16:41:03 GMT
CPAN: Module::CoreList loaded ok (v5.20170922_26)
Getopt::Long is up to date (2.52).
Reading '/root/.cpan/Metadata'
  Database was generated on Mon, 08 Feb 2021 16:41:03 GMT
CPAN: Module::CoreList loaded ok (v5.20170922_26)
JSON::PP is up to date (4.06).
Reading '/root/.cpan/Metadata'
  Database was generated on Mon, 08 Feb 2021 16:41:03 GMT
CPAN: Module::CoreList loaded ok (v5.20170922_26)
HTML::TreeBuilder is up to date (5.07).
````

