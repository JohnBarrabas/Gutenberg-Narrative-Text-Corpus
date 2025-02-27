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
##      Site::JSONStorable.pm
##
##  DESCRIPTION
##
##       Encapsulation of FREEZE/THAW to make objects JSON storable 
##
##  DATA
##
##      None.
##
##  FUNCTIONS
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

package Site::JSONStorable;

use strict;
use warnings;
use Carp;

use JSON::PP;

########################################################################################################################
########################################################################################################################
#
# FREEZE - Serialization for Load/Save
#
# Inputs:   Object to serialize
#
# Outputs:  New Library object, from elements
#
sub FREEZE {
    my ($self, $serialiser) = @_;

    return JSON::PP->new->pretty->allow_tags->encode({%{$self}});
    }


########################################################################################################################
########################################################################################################################
#
# THAW - Serialization for Load/Save
#
# Inputs:   List of elements to make object from
#
# Outputs:  New Library object, from elements
#
sub THAW {
    my $class      = shift;
    my $serialiser = shift;

    return bless shift,$class;
    }


#
# Perl requires that a package file return a TRUE as a final value.
#
1;
