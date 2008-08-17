package pm_alert;
# =====================================================================
# Flex - WPS mySQL
# Private Messaging version 1 beta 3
#
# Copyright (C) 2006 by N. K. A. (shakainc@tampabay.rr.com)
#
# This program is NOT free software; you can NOT redistribute it and/or
# modify it!
#
# To Do List:
# 1) Check security
#
#
# v1.0 beta 2 - 06/19/2006 21:34:28
#
# Date: 10/02/2007 11:07:15
# =====================================================================
# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    %user_data $dbh
    %cfg %usr
    %sub_action
    );
use exporter;

%sub_action = (pm_alert => 1);


# Print New PM Alert
sub pm_alert {

if ($user_data{uid} ne $usr{anonuser}) {
my $pmlist = '';
my $printlist = '';
my $incount = 0;
require theme;
 # Text and word Wrap, default Perl Module!
 use Text::Wrap;
 $Text::Wrap::columns = 25; # Wrap at 25 characters for menu

my $query1 = "SELECT * FROM pmin WHERE memberid='$user_data{id}'";
my $sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
# build message
if ($row[6]) { $incount++;
my $subject = wrap('', '', $row[4]);
$pmlist .= theme::menu_item("$cfg{pageurl}/index.$cfg{ext}?op=view_pm", $subject, '', "forum/exclamation.gif");
 }
}
$sth->finish(); #}
if ($incount) {
$printlist = theme::box_header("$incount Private Message Alert");
$printlist .= $pmlist;
$printlist .= theme::box_footer();
print $printlist;
 }
}
}
1;