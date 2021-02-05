#!/dev/null
#
##########################################################################################
##########################################################################################
##
##      Copyright (C) 2010 Rajstennaj Barrabas, Milford, NH 03055
##      All Rights Reserved under the MIT license as outlined below.
##
##  FILE
##      Time.pm
##
##  DESCRIPTION
##      Simple functions for dealing with program execution elapsed time
##
##      StartTime()         Start the timing mechanism
##      ElapsedTime()       Return time string in the form HH:MM:SS
##      DateFilename()      Return date string, suitable as a filename
##      DateTimeFilename()  Return date/time string, suitable as a filename
##      DayFilename()       Return day of week, suitable as a filename
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
##########################################################################################
##########################################################################################

package Site::Time;
    use base "Exporter";

use strict;
use warnings;
use Carp;

use POSIX qw(strftime);

our @EXPORT = qw(&StartTime    &ElapsedTime
                 &DateFilename &DateTimeFilename
                 &DayFilename);                         # Export by default

##########################################################################################
##########################################################################################
##
## Data declarations
##
##########################################################################################
##########################################################################################

our($StartTime);

##########################################################################################
##########################################################################################
#
# StartTime - Start execution timing
#
# Inputs:   None.
#
# Outputs:  None.
#
sub StartTime {

    $StartTime = time();
    }

##########################################################################################
##########################################################################################
#
# ElapsedTime - Calculate and return the elapsed time
#
# Inputs:   None.
#
# Outputs:  String indicating elapsed time from StartTime
#               ex: "01:20:20"
#
sub ElapsedTime {
    my($TotalTime);

    $TotalTime = time() - $StartTime;
    my($Seconds) = $TotalTime % 60;
    $TotalTime  /= 60;
    my($Minutes) = $TotalTime % 60;
    $TotalTime  /= 60;
    my($Hours)   = $TotalTime;

    return(sprintf("%02d:%02d:%02d",$Hours,$Minutes,$Seconds));
    }


##########################################################################################
##########################################################################################
#
# DateFilename - Filename based on the date
#
# Inputs:   None.
#
# Outputs:  String indicating date and time
#               ex: "2011-01-01"
#
sub DateFilename {

    my ($CurrentSecond,  $CurrentMinute,    $CurrentHour, 
        $CurrentDay,     $CurrentMonth,     $CurrentYear, 
        $CurrentWeekDay, $CurrentDayOfYear, $CurrentIsDST) = localtime(time);

    #
    # Create a filename which sorts correctly and is specific to the current time
    #
    return sprintf "%04d-%02d-%02d",$CurrentYear+1900,$CurrentMonth+1,$CurrentDay;
    }


##########################################################################################
##########################################################################################
#
# DateTimeFilename - Filename based on the date and time
#
# Inputs:   None.
#
# Outputs:  String indicating date and time
#               ex: "2011-01-01.01:20:20"
#
sub DateTimeFilename {

    my ($CurrentSecond,  $CurrentMinute,    $CurrentHour, 
        $CurrentDay,     $CurrentMonth,     $CurrentYear, 
        $CurrentWeekDay, $CurrentDayOfYear, $CurrentIsDST) = localtime(time);

    #
    # Create a filename which sorts correctly and is specific to the current time
    #
    return sprintf "%04d-%02d-%02d.%02d:%02d:%02d",
                    $CurrentYear+1900,
                    $CurrentMonth+1,
                    $CurrentDay,
                    $CurrentHour,
                    $CurrentMinute,
                    $CurrentSecond;
    }

##########################################################################################
##########################################################################################
#
# DayFilename - Filename based on the current day of the week
#
# Inputs:   None.
#
# Outputs:  String indicating day
#               ex: "Mon"
#
sub DayFilename {
    my @WeekDay = ("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");

    my ($CurrentSecond,  $CurrentMinute,    $CurrentHour, 
        $CurrentDay,     $CurrentMonth,     $CurrentYear, 
        $CurrentWeekDay, $CurrentDayOfYear, $CurrentIsDST) = localtime(time);

    #
    # Create a filename which sorts correctly and is specific to the current time
    #
    return $WeekDay[$CurrentWeekDay];
    }

#
# Perl requires that a package file return a TRUE as a final value.
#
1;
