package smilies;

# =====================================================================
# YaWPS - Yet another Web Portal System
#
# Copyright (C) 2001 by Adrian Heiszler (d3m1g0d@users.sourceforge.net)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the
# Free Software Foundation, Inc.,
# 59 Temple Place - Suite 330,
# Boston, MA  02111-1307, USA.
#
#
# $Id: smilies.cgi,v 1.13 2004/02/17 12:20:38 d3m1g0d Exp $
# =====================================================================
#
# New Smilies By: www.shakaflex.com
#  10-13-2006 - Works for Flex WPS SQL
#  2-26-2006 - Added more smilies and changed the ubbc style
#

# Load necessary modules.
use strict;

# Assign global variables.
use vars qw(
    %nav %cfg $VERSION $query
    );

use exporter;

# inputs
my $js = $query->param('js') || '';

if ($js) {
  $js = qq(opener.document.send_win.chat_message.value+=anystr;);
}
 else {
  $js = qq(insertAtCursor(opener.document.creator.message, anystr););
 }
 
 my $row_color = qq( class="tbl_row_dark");
 my $smileys_html = '';
my $query1 = "SELECT * FROM smilies;";
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
# Alternate the row colors.
$row_color =
  ($row_color eq qq( class="tbl_row_dark"))
  ? qq( class="tbl_row_light")
  : qq( class="tbl_row_dark");
  $smileys_html .= qq(<tr$row_color>
<td valign="top" width="50%">[$row[1]]</td>
<td valign="top" width="50%"><a href="javascript:addCode('[$row[1]]')"><img src="$cfg{imagesurl}/smilies/$row[2]" border="0" alt=""></a></td>
</tr>);
        #$smileys{$row[1]} = $row[2];
}
$sth->finish;
 
sub print_smilies {
print "Content-type: text/html\n\n";
print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta name="Generator" content="Flex $VERSION">
<title>$cfg{pagetitle}</title>
<link rel="stylesheet" href="$cfg{themesurl}/standard/style.css" type="text/css">
<script type="text/javascript" src="$cfg{non_cgi_url}/themes/ubbc.js"></script>
<script language="javascript" type="text/javascript">
<!--
function addCode(anystr) {
$js
}
// -->
</script>
</head>

<body bgcolor="#C5D0DC" text="#000000">
<table align="left" border="0" cellspacing="1" cellpadding="0" width="260">
<tr>
<td>
<table align="left" border="0" cellspacing="1" cellpadding="2" width="260">
<tr class="tbl_header">
<td valign="top" width="50%"><b>Code</b></td>
<td valign="top" width="50%"><b>Smilie</b></td>
</tr>
$smileys_html
</table>
</td>
</tr>
</table><div style="clear: left"> </div>
<br>
<div align="left" class="textsmall">[<a href="javascript:window.close();">$nav{close_window}</a>]</div>
<br>
</body>
</html>
HTML

exit;
}
1;
