#!/bin/bash
#
########################################################################################################################
########################################################################################################################
##
##      Copyright (C) 2021 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      00-PerlLibs.sh
##
##  DESCRIPTION
##      Do all the CPAN installs needed for perl programs
##
##      Mostly a lot of CPAN library installs
##
##  USAGE
##      00-PerlLibs.sh
##
##  NOTES
##      Requires root access
##
##      Net access can be intermittant and slow, so this command is restartable.
##
##      The recommended procedure is to run this script over and over until the
##        all files are complete.
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

########################################################################################################################
########################################################################################################################
#
# Ensure we're being run as root
#
if [ "$EUID" -ne 0 ]; then
    echo
    echo "Must be run as root" 
    echo
    exit 1
    fi

########################################################################################################################
########################################################################################################################
#
# Upgrade perl
#

#
# Set the CPAN defaults we need
#
# cpan> o conf prerequisites_policy 'follow'
# cpan> o conf build_requires_install_policy yes
# cpan> o conf commit
#
perl -MCPAN -e 'my $c = "CPAN::HandleConfig"; $c->load(doit => 1, autoconfig => 1); $c->edit(prerequisites_policy => "follow"); $c->edit(build_requires_install_policy => "yes"); $c->commit'

export PERL_CANARY_STABILITY_NOPROMPT=1

cpan Carp
cpan File::Basename
cpan File::Slurp
cpan FindBin
cpan List::Util
cpan File::Path
cpan IO::Uncompress::Unzip
cpan Getopt::Long
cpan JSON::PP
cpan HTML::TreeBuilder

########################################################################################################################
#
# All done - Tell the user to reboot
#
echo "========================="
echo
echo "Done with installation."
echo
