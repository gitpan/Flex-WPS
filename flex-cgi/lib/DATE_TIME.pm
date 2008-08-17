package DATE_TIME;

=head1 COPYLEFT

 $Id: DATE_TIME.pm,v 1.0 5/19/2006 13:37:55 $|-|4X4_|=73}{ Exp $

 This file is part of Flex WPS - Flex Web Portal System.
 This file is to big and needs an overhall.

=cut

#use strict;

#use lib '.';
use exporter;

=head1 NAME

Package DATE_TIME

=head1 DESCRIPTION

 UBBC Panel moved here for size and speed.

=head1 SYNOPSIS

 use DATE_TIME;
 my $date = DATE_TIME::get_date();
 my $formated_date = DATE_TIME::format_date($date, $format);


=head1 FUNCTIONS

 These functions are available from this package:

=cut

=head2 get_date()

 Get Current Time and Date.

=cut

sub get_date {
        return time + 3600 * $cfg{time_offset};
}
=head2 calc_time_diff()

 Calculate difference between two dates.

=cut
# ---------------------------------------------------------------------
# Calculate difference between two dates.
# ---------------------------------------------------------------------
sub calc_time_diff {
        my ($in_date1, $in_date2, $type) = @_;
        my $result = $in_date1 - $in_date2;

        # Calculate difference in hours.
        if (!$type) { $result = int($result / 3600); }

        # Calculate difference in days.
        else { $result = int($result / (24 * 3600)); }

        return $result;
}
=head2 format_date()

 Format date output.

=cut
# ---------------------------------------------------------------------
# Format date output.
# ---------------------------------------------------------------------
sub format_date {
        my $date = shift || &get_date;
        my $type = shift || $cfg{date_format};

        # Get selected date format.
        my $sel_date_format = (exists $user_data{date_format})
            ? $user_data{date_format}
            : $cfg{date_format};
        $sel_date_format = ($type || $type ne '') ? $type : $cfg{date_format};
        $date            = ($date || $date ne '') ? $date : get_date();

        my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) =
            localtime($date + 3600 * $cfg{time_offset});
        my ($formatted_date, $cmon, $cday, $syear);

        $year += 1900;

        $cmon  = $mon + 1;
        $syear = sprintf("%02d", $year % 100);

        if ($hour < 10) { $hour = 0 . $hour; }
        if ($min < 10)  { $min  = 0 . $min; }
        if ($sec < 10)  { $sec  = 0 . $sec; }

        if ($cmon < 10) { $cmon = 0 . $cmon; }
        $cday = ($mday < 10) ? 0 . $mday : $mday;

        # Format: 01/15/00, 15:15:30
        if (!$sel_date_format || $sel_date_format == 11) {
                $formatted_date = "$cmon/$cday/$syear, $hour:$min:$sec";
        }

        # Format: 15.01.00, 15:15:30
        if ($sel_date_format == 1) {
                $formatted_date = "$cday.$cmon.$syear, $hour:$min:$sec";
        }

        # Format: 15.01.2000, 15:15:30
        if ($sel_date_format == 2) {
                $formatted_date = "$cday.$cmon.$year, $hour:$min:$sec";
        }

        # Format: Jan 15th, 2000, 3:15pm
        if ($sel_date_format == 3) {
                my $ampm = 'am';
                if ($hour > 11) { $ampm = 'pm'; }
                if ($hour > 12) { $hour = $hour - 12; }
                if ($hour == 0) { $hour = 12; }

                if ($mday > 10 && $mday < 20) { $cday = '<sup>th</sup>'; }
                elsif ($mday % 10 == 1) { $cday = '<sup>st</sup>'; }
                elsif ($mday % 10 == 2) { $cday = '<sup>nd</sup>'; }
                elsif ($mday % 10 == 3) { $cday = '<sup>rd</sup>'; }
                else { $cday = '<sup>th</sup>'; }

                $formatted_date = "$months{$mon} $mday$cday, $year, $hour:$min$ampm";
        }

        # Format: 15. Jan 2000, 15:15
        if ($sel_date_format == 4) {
                $formatted_date = "$wday. $months{$mon} $year, $hour:$min";
        }

        # Format: 01/15/00, 3:15pm
        if ($sel_date_format == 5) {
                my $ampm = 'am';
                if ($hour > 11) { $ampm = 'pm'; }
                if ($hour > 12) { $hour = $hour - 12; }
                if ($hour == 0) { $hour = 12; }

                $formatted_date = "$cmon/$cday/$syear, $hour:$min$ampm";
        }

        # Format: Sunday, 15 January, 2000
        if ($sel_date_format == 6) {
                $formatted_date = "$week_days{$wday}, $mday $months{$mon} $year";
        }
        my $new_date22 = '';
        my $new_mon = '';
        # Format: year,month,day 20000
        if ($sel_date_format == 7) {
        if($mday <= 9) { $new_date22 = "0$mday"; } else { $new_date22 = "$mday"; }
        if($mon <= 9) { $new_mon = "0$mon"; } else { $new_mon = "$mon"; }
                #$cmon = $cmon - 1;
                $formatted_date = "$year$new_mon$new_date22";
        }

        # Format: year,month,day 20000
        if ($sel_date_format == 8) {
        #if(length($wday) < 2) { $wday = "0$wday"; }

                #$cmon = $cmon - 1;
                if($mon <= 9) { $new_mon = "0$mon"; } else { $new_mon = "$mon"; }
                $formatted_date = "$year$new_mon";
        }
        # Format: 15/01/2000 - 03:15:30 (internal stats logfile format).
        if ($sel_date_format == -1) {
                $formatted_date = "$cday/$cmon/$year - $hour:$min:$sec";
        }

        return $formatted_date;
}
1;
