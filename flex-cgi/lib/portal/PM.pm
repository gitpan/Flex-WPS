package PM;
# =====================================================================
# Flex - WPS mySQL
# Private Messaging version 1 beta 6 Ajax - non Aspell version
#
# Copyright (C) 2006 by N. K. A. (shakainc@tampabay.rr.com)
#
#
# To Do List:
# 1) Check security - found a hole in beta 3
#
# v1.0 beta 4 - 10/22/2007 13:15:28
# v1.0 beta 3 - 10/02/2007 11:07:15
# v1.0 beta 2 - 06/19/2006 21:34:28
#
# Date: 11/10/2007 08:03:10
# =====================================================================
# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    $query
    %user_data $dbh
    %nav %msg %cfg %usr %err %btn
    %sub_action $AUBBC_mod
    );
use exporter;

%sub_action = (pm_alert => 1);

# Need to check filters! FOR ALL inputs!
my $subject = $query->param('subject') || '';
my $message = $query->param('message') || '';
my $quote = $query->param('quote') || '';
my $to = $query->param('to') || '';
my $id = $query->param('id') || '';

# need config for this and add code to check it
# put count in profile for speed
my $max_messages = 50;
my $max_stmessages = 51;

if ($user_data{uid} eq $usr{anonuser}) {
# Redirect to the register page.
  print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=register');
  exit(0);
}
sub view_pm {
# Need Errors to be imported in there
# Check if user is logged in.
if ($user_data{uid} eq $usr{anonuser}) {
require error; error::user_error($err{auth_failure}, $user_data{theme});
}

my $buddycount = 0;

# get buddys count
if($user_data{buddys}) {
my (@iid) = split (/\,/, $user_data{buddys});
foreach my $crap (@iid) {
$buddycount++;
}
}
# Get private messages for user
my $boxlinks;
$boxlinks = qq(<table width="100%" border="0" cellspacing="0" cellpadding="2">
  <tr>
    <td width="50%"><div id="inoutMenu"> </div></td>
    <td width="25%"><table class="tablebox" width="100%">
<tr><td><a href="#message" onClick="javascript:changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm');"><img src="$cfg{imagesurl}/PM/send.png" border="0"></a></td>
<td>&nbsp;<a href="#message" onClick="javascript:changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm');"><b>Send PM</b></a>
</td></tr>
</table></td>
    <td width="25%"><table class="tablebox" width="100%">
<tr><td><a href="#veiw" onClick="javascript:getbuddysBox();"><img src="$cfg{imagesurl}/PM/buddys.png" border="0"></b></td>
<td><a href="#veiw" onClick="javascript:getbuddysBox();"><b>Buddys</b></a> $buddycount
</td></tr>
</table></td>
  </tr>
</table>);

require theme;
theme::print_header();
theme::print_html($user_data{theme}, $nav{im_index}, '', 'PM_box');
require get_user;
get_user::box_script();
print <<HTML;
<a name="veiw"></a>
<script type="text/javascript" language="JavaScript">
<!--
iframe1 = "<IFRAME width=100% height=520 SRC=";
iframe2 = " marginwidth=1 marginheight=1 border=1 frameborder=1></IFRAME>"
function changemessage(msg){
message.innerHTML=""+iframe1+""+msg+""+iframe2+"";
}
// -->
</script>
<table align="center" class="navtable" width="100%" border="0" cellspacing="0" cellpadding="3">
<tr valign="top">
<td>$boxlinks
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr valign="top">
<td width="100%">
<div name="message" id="message">
HTML

if ($message eq 'send'){
 send_pm();
}
elsif ($message eq 'buddys') {
 buddys();
}
#  else {
#  print "<div name=\"message\" id=\"message\"> </div></td>";
#  }

print <<HTML;
 </div>
<div id="inoutBox"> </div></td>
</tr>
</table>
</td>
</tr>
</table>
HTML

theme::print_html($user_data{theme}, $nav{im_index}, 1);
}
sub get_percentpix {
my ($total_size, $max_messages) = @_;
my ($percent, $pixel, $a, $b);
   if ($total_size != 0)
   {
   $pixel = int((($total_size / $max_messages) * 100) / 2);

   $percent = ($total_size / $max_messages) * 100;

   my $c = int(10 * ($percent * 10 - int($percent * 10)));

   $b = int(10 * ($percent - int($percent)));
   $a = int($percent);

   if ($c >= 5) { $b++; }
   }
   else { $a = 0; $b = 0; }

   $percent = $a . "." . $b;
   if (!$pixel) { $pixel = 0; }

   return ($pixel, $percent);
}
sub row_color {
my $row_color = shift;
  $row_color =
($row_color eq qq( class="tbl_row_dark"))
? qq( class="tbl_row_light")
: qq( class="tbl_row_dark");
return $row_color;
}
sub in_out_boxs {
my $messages = '';
my $boxsubj = '';
my $row_color = qq( class="tbl_row_dark");
# Get private messages for user
if(!$quote) {
$boxsubj = 1;
my (@pmin);
my $sth = qq(SELECT * FROM pmin WHERE memberid='$user_data{id}' ORDER BY date DESC);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
# build message
if ($row[0]) {

        push (
                @pmin,
                join (
                        "|",   $row[0], $row[3], $row[4], $row[5], $row[2], $row[6]
                )
            );
 }
}
$sth->finish();

for (my $i = 0; $i <= $#pmin; $i++) {
 #foreach (@pmin) {
 my @row = split(/\|/, $pmin[$i]);
 if (!$row[5]) { $row[5] = ''; }
 $messages .= message_build("$row_color", "$row[0]", "$row[1]", "$row[2]", "$row[3]", "$row[4]", "$row[5]");
 # Alternate the row colors.
 $row_color = row_color($row_color);
 }
}
# Get Sent private messages for user
if($quote) {
$boxsubj = 2;
my (@pmout);
my $sth = qq(SELECT * FROM pmout WHERE memberid='$user_data{id}' ORDER BY date DESC);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
      if($row[0]) {
# build message
if ($row[0]) {
        push (
                @pmout,
                join (
                        "|",   $row[0], $row[3], $row[4], $row[5], $row[2]
                )
            );
            }
      }
}
$sth->finish();

for (my $i = 0; $i <= $#pmout; $i++) {
# foreach (@pmout) {
 my @row = split(/\|/, $pmout[$i]);
 $messages .= message_build($row_color, $row[0], $row[1], $row[2], $row[3], $row[4], '');
 # Alternate the row colors.
 $row_color = row_color($row_color);
 }
}
print "Content-type: text/html\n\n";
if ($messages) {
$boxsubj = $nav{im_index} if $boxsubj == 1;
$boxsubj = $nav{im_sent} if $boxsubj == 2;
print qq(<script language="javascript" type="text/javascript">
<!--
function checkAll(val) { al=document.item_list; len=al.elements.length; var i=0;
for (i=0; i<len; i++) { if (al.elements[i].name=='id') { al.elements[i].checked=val; } } }
//-->
</script>
<form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="item_list"
onSubmit="if (!(item_list.op[0].checked || item_list.op[1].checked)) return false">
<input type="submit" value="Delete Unchecked" onclick="javascript:return confirm('Are you sure you want to Delete Unchecked item?')">&nbsp;&nbsp;<small><a href="javascript:checkAll(1)">Check All</a> - <a href="javascript:checkAll(0)">Clear All</a></small>
<table width="100%" border="0" cellspacing="1" cellpadding="2">
<tr class="tbl_header">
<td><b>$msg{authorC}</b></td>
<td><b>$boxsubj - $msg{subjectC}</b></td>
</tr>
$messages
</table>
<input type="hidden" name="op" value="delete_pm">
<input type="hidden" name="quote" value="$quote">
<input type="submit" value="Delete Unchecked" onclick="javascript:return confirm('Are you sure you want to Delete Unchecked item?')">&nbsp;&nbsp;
<small><a href="javascript:checkAll(1)">Check All</a> - <a href="javascript:checkAll(0)">Clear All</a></small>
</form>);
} else { print qq(No Messages); }

 $dbh->disconnect();
 exit();
}
sub menu_out_in {
# Get private messages for user
my $total_size = 0;
my $menu_box = '';
#if ($quote eq 2) {
    my $sth = qq(SELECT `date` FROM `pmin` WHERE `memberid` = '$user_data{id}' ORDER BY `date` DESC);
    $sth = $dbh->prepare($sth);
    $sth->execute || die("Couldn't exec sth!");
    while(my @row = $sth->fetchrow) {
    # build message
    $total_size++ if $row[0];
    }
    $sth->finish();
    my ($pixel1, $percent1) = get_percentpix($total_size, $max_messages);
    my $barhtml = qq(<img src="$cfg{imagesurl}/leftbar.gif" width="7" height="14" alt=""><img src="$cfg{imagesurl}/mainbar.gif" width="$pixel1" height="14" alt=""><img src="$cfg{imagesurl}/rightbar.gif" width="7" height="14" alt="">);
    $menu_box = qq(<table class="tablebox" align="left" width="50%">
<tr><td><a href="#veiw" onClick="javascript: getinoutBox('','');"><img src="$cfg{imagesurl}/PM/inbox.png" border="0"></a></td>
<td>
&nbsp;<a href="#veiw" onClick="javascript: getinoutBox('','');"><b>$nav{im_index}:</b></a>&nbsp;$total_size / $max_messages<br>&nbsp;$barhtml $percent1
</td></tr>
</table>);
#}
 #elsif ($quote eq 1) {
         $total_size = 0;
         $sth = qq(SELECT `date` FROM `pmout` WHERE `memberid` ='$user_data{id}' ORDER BY `date` DESC); #SELECT * FROM pmout WHERE memberid='$user_data{id}'";
         $sth = $dbh->prepare($sth);
         $sth->execute || die("Couldn't exec sth!");
         while(my @row = $sth->fetchrow) {
               $total_size++ if ($row[0]);
         }
         $sth->finish();
         my ($pixel2, $percent2) = get_percentpix($total_size, $max_stmessages);
         $barhtml = qq(<img src="$cfg{imagesurl}/leftbar.gif" width="7" height="14" alt=""><img src="$cfg{imagesurl}/mainbar.gif" width="$pixel2" height="14" alt=""><img src="$cfg{imagesurl}/rightbar.gif" width="7" height="14" alt="">);
    $menu_box .= qq(<table class="tablebox" align="left" width="50%">
<tr><td><a href="#veiw" onClick="javascript: getinoutBox(1,'');"><img src="$cfg{imagesurl}/PM/outbox.png" border="0"></a></td>
<td>&nbsp;<a href="#veiw" onClick="javascript: getinoutBox(1,'');"><b>$nav{im_sent}:</b></a>&nbsp;$total_size / $max_stmessages<br>&nbsp;$barhtml $percent2
</td></tr>
</table>);
       #  }
print "Content-type: text/html\n\n";
print $menu_box;
 $dbh->disconnect();
 exit();
}
sub message_build {
# Need to add user info
my ($row_color, $iid, $date, $subject, $message, $user, $unread) = @_;
 # Text and word Wrap, default Perl Module!
 use Text::Wrap;
 $Text::Wrap::columns = 60; # Wrap at 60 characters
    $subject = wrap('', '', $subject);
    $message = wrap('', '', $message);
# require text_wrap;
#         $subject = text_wrap::wrap(60, $subject);
#         $message = text_wrap::wrap(60, $message);
my $edit_link;
if ($unread) {
$unread = qq(<img src="$cfg{imagesurl}/forum/new.gif" alt="New Message" border="0"> );
}
else {
$unread = qq(<img src="$cfg{imagesurl}/forum/xx.gif" alt="Read Message" border="0"> );
}

if ($user !~ m!^([0-9]+)$!i) {
$edit_link = qq(<a href="#veiw" onClick="javascript:getdeleteBox($iid, '');"><img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0"></a>&nbsp;&nbsp;);
}
elsif ($quote) {
$edit_link = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=add_buddy;to=$user" target="_parent"><img src="$cfg{imagesurl}/add_remove_buddy.gif" alt="Add Buddy" border="0"></a>
&nbsp;&nbsp;<a href="#message" onClick="javascript:changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm;id=$iid;quote=1;to=$user;subject=sent');"><img src="$cfg{imagesurl}/forum/quote.gif" alt="$msg{quote}" border="0"></a>&nbsp;&nbsp;<a href="#veiw" onClick="javascript:getdeleteBox($iid, 1);"><img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0"></a>&nbsp;&nbsp;);
 }
 else {
$edit_link = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=add_buddy;to=$user" target="_parent"><img src="$cfg{imagesurl}/add_remove_buddy.gif" alt="Add Buddy" border="0"></a>
&nbsp;&nbsp;<a href="#message" onClick="javascript:changemessage('$cfg{pageurl}/index.$cfg{ext}?op=send_pm;id=$iid;quote=1;to=$user');"><img src="$cfg{imagesurl}/forum/quote.gif" alt="$msg{quote}" border="0"></a>&nbsp;&nbsp;<a href="#veiw" onClick="javascript:getdeleteBox($iid, '');"><img src="$cfg{imagesurl}/button_cance.png" alt="$msg{delete}" border="0"></a>&nbsp;&nbsp;);
}

require DATE_TIME;
$date = DATE_TIME::format_date($date, 5);
my $buddyhtml = '';

require get_user;
#if($user_data{buddys}) {
my $lid = $user_data{buddys};
#chomp(@lid);
#foreach my $crap (@lid) {
if($user =~ m!^([0-9]+)$!i && $lid =~ s/(\,|)$user(|\,)//) {
my $crap = $user;
#if($crap eq $user) {
$buddyhtml .= qq(<td align="left">);
$buddyhtml .= get_user::mouse_boxtop();
my $filx = get_user::profile($crap) || '';
my $name = '';
my $stuff = '';
if ($filx =~ s/(.+?)\]\[\]\[//) {
$name = $1;
$stuff = $filx;
$stuff = get_user::mouse_box("$stuff");
}
$buddyhtml .= qq(<img src="$cfg{imagesurl}/PM/buddys_s.png" style="border: none;" alt="$name">
$stuff</td>
<td width="100%"><b>$name</b></td>);
#}
}
else {
my $filx = get_user::profile($user) || '';
my $name = '';
    if (!$filx && $user) {
    #$name = $user;
    $buddyhtml = qq(<td><img src="$cfg{imagesurl}/sticky.gif" style="border: none;" alt="none"></td>
    <td width="100%">System-Alert</td>);
    }
    else {
    $filx =~ s/(.+?)\]\[\]\[//;
    $name = $1;
    $buddyhtml = qq(<td><img src="$cfg{imagesurl}/sticky.gif" style="border: none;" alt="none"></td>
    <td width="100%"><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$user">$name</a></td>);
    }
}
#}
#}

#require UBBC;
#$subject = UBBC::do_smileys($subject);
$AUBBC_mod->settings( for_links => 1 );
$subject = $AUBBC_mod->do_all_ubbc($subject);
$AUBBC_mod->settings( for_links => 0 );
my $table = <<HTML;
<tr$row_color>
<td width="140" valign="top" rowspan="1">
<table border="0" width="100%" cellpadding="0" cellspacing="1">
<tr>
<td width="30"><input type="checkbox" name="id" value="$iid" checked></td>
$buddyhtml
</tr>
</table>
</td>
<td valign="top" width="100%">
<table border="0" width="100%" cellpadding="0" cellspacing="1">
<tr>
<td width="100%">&nbsp;$unread<a href="#message" onClick="javascript:changemessage('$cfg{pageurl}/index.$cfg{ext}?op=message2;id=$iid;quote=$quote');"><b>$subject</b></a></td>
<td align="right" nowrap><small>$date</small>&nbsp;&nbsp;$edit_link</td>
</tr>
</table></td>
</tr>
HTML

return $table;
}
sub message2 {
# Check if user is logged in.
if ($user_data{uid} eq $usr{anonuser}) {
require error;
error::user_error($err{auth_failure}, $user_data{theme});
}
my $readcheck = 0;
my $message = '';
my $subject = '';
my $buddyin = '';
my $query1;

 # Text and word Wrap, default Perl Module!
 use Text::Wrap;
 $Text::Wrap::columns = 60; # Wrap at 60 characters

if (!$quote) {
# Get private messages for user
$query1 = "SELECT * FROM pmin WHERE id='$id' AND memberid='$user_data{id}'";
} else {
# Get private messages for user
$query1 = "SELECT * FROM pmout WHERE id='$id' AND memberid='$user_data{id}'";
}
my $sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
# build message
if ($row[6]) { $readcheck = 1; }
$buddyin = $row[2];
$subject = $row[4];
$message = $row[5];
}
$sth->finish();

require get_user;
#require UBBC;
#$message = UBBC::do_ubbc($message);
#$message = UBBC::do_smileys($message);
#$subject = UBBC::do_smileys($subject);
$message = $AUBBC_mod->do_all_ubbc($message);
$AUBBC_mod->settings( for_links => 1 );
$subject = $AUBBC_mod->do_all_ubbc($subject);
$AUBBC_mod->settings( for_links => 0 );
    $subject = wrap('', '', $subject);
   # $message = wrap('', '', $message);
my $filx = get_user::profile("$buddyin") || '';
my $name = '';
my $stuff = '';
$filx =~ s/(.+?)\]\[\]\[//;
$name = $1;
my $buddyhtml = qq(<td><img src="$cfg{imagesurl}/sticky.gif" style="border: none;" alt="none"></td>
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$buddyin" target="_parent">$name</a></td>);
if ($readcheck){ require SQLEdit; SQLEdit::SQLAddEditDelete("UPDATE pmin SET new='0' WHERE id='$id' LIMIT 1 ;");}
print "Content-type: text/html\n\n";
print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>$cfg{pagetitle}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$cfg{codepage}">
<meta name="Generator" content="Message">
<link rel="stylesheet" href="$cfg{themesurl}/standard/style.css" type="text/css">
</head>
<body bgcolor="#FFFFFF" text="#000000">
HTML
get_user::box_script();
print <<HTML;
<table width="100%" border="0" cellspacing="0" cellpadding="3" bgcolor="#FFFFFF" valign="top">
<tr>
$buddyhtml
<td width="100%"><b>$subject</b></td>
</tr>
<tr>
<td colspan="3">$message</td>
</tr>
</table>
</body>
</html>
HTML
$dbh->disconnect();
exit;
}
sub buddys {
# Check if user is logged in.
#if ($user_data{uid} eq $usr{anonuser}) { require error; &error::user_error($err{auth_failure}, $user_data{theme}); }
my $buddycount = 0;
my $buddyhtml = '';
my $row_color = qq( class="tbl_row_dark");

require get_user;
if($user_data{buddys}) {
my (@iid) = split (/\,/, $user_data{buddys});
foreach my $crap (@iid) {
$buddycount++;
$buddyhtml .= qq(<tr$row_color>
<td width="5%" align="center" valign="baseline">);
$row_color = row_color($row_color);
$buddyhtml .= get_user::mouse_boxtop();
my $filx = get_user::profile("$crap") || '';
my $name = '';
my $stuff = '';
if ($filx =~ s/(.+?)\]\[\]\[//) {
$name = $1;
$stuff = $filx;
$stuff = get_user::mouse_box("$stuff");
}
$buddyhtml .= qq(<img src="$cfg{imagesurl}/icon7.gif" style="border: none;" alt="$name">
$stuff</td>
<td>&nbsp;&nbsp;<b>$name</b></td>
</tr>);

}
# <img src="$cfg{imagesurl}/icon7.gif" style="border: none;" alt="$msg{bugbadge} $msg{expert}">
} else { $buddyhtml = <<HTML;
<tr>
<td class="tbl_row_light"><b>No Buddys Added</b> $buddycount<td>
</tr>
HTML
 }
#  <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_pm"><b>$nav{im_index}:</b></a>
# &nbsp;|&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=view_pm;quote=1"><b>$nav{im_sent}:</b></a>
#require theme;
#theme::print_header();
#theme::print_html($user_data{theme}, $nav{im_index});
print "Content-type: text/html\n\n";
get_user::box_script();
print <<HTML;
<table border="0" cellspacing="2" width="65%" cellpadding="3">
<tr class="bg3">
<td colspan="2">
<b>Buddys Count:</b> $buddycount</td>
</tr>
$buddyhtml
</table>
HTML
 $dbh->disconnect();
 exit();
#theme::print_html($user_data{theme}, $nav{im_index}, 1);
}
sub add_buddy {
# Check if user is logged in.
if ($user_data{uid} eq $usr{anonuser}) { require error; error::user_error($err{auth_failure}, $user_data{theme}); }
if (!$to) { require error; error::user_error($err{user_no_exist}, $user_data{theme}); }
require get_user;
my $check_user = get_user::check_user($to, '1');
if (!$check_user) { require error; error::user_error($err{user_no_exist}, $user_data{theme}); }
# Check if current member has buddy in profile.
#if ($user_data{buddys} =~ m!^(|(.+?)\,)$to(|\,(.+?))$!i) {
if ($user_data{buddys} =~ s/$to\,//
|| $user_data{buddys} =~ s/\,$to//
|| $user_data{buddys} =~ s/$to//) {
#require error; &error::user_error($user_data{buddys}, $user_data{theme});
require SQLEdit;
SQLEdit::SQLAddEditDelete("UPDATE members SET rib='$user_data{buddys}' WHERE memberid='$user_data{id}' LIMIT 1 ;");
} else {
# add it
if ($user_data{buddys}) { $user_data{buddys} .= ',' . $check_user; }
else { $user_data{buddys} = $check_user; }
require SQLEdit;
SQLEdit::SQLAddEditDelete("UPDATE members SET rib='$user_data{buddys}' WHERE memberid='$user_data{id}' LIMIT 1 ;");
}
$dbh->disconnect();
# redirect to buddys
print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view_pm;message=buddys');
}
# Send PM
sub send_pm {
# Check if user is logged in.
#if ($user_data{uid} eq $usr{anonuser}) { require error; error::user_error($err{auth_failure}, $user_data{theme}); }
# Needs a max mesages check
my $temp_message = '';
my $temp_subject = '';
if ($quote) {
my $query1;
if (!$subject) { $query1= "SELECT * FROM pmin WHERE id='$id' AND (memberid='$user_data{id}' OR posterid ='$user_data{id}')"; }
else { $query1= "SELECT * FROM pmout WHERE id='$id' AND (memberid='$user_data{id}' OR posterid ='$user_data{id}')"; }
my $sth = $dbh->prepare($query1);
$sth->execute;
#require HTML_TEXT;
while(my @row = $sth->fetchrow) {
$temp_subject = 'Re: ' . $row[4];
$temp_message = $row[5];
# using to fix PM print out bug. # this is a bug
# if($temp_message =~ s/\[quote\](\S+?)\[\/quote\]/$1/isg) {
#     $temp_message = $1;
#     }
#$temp_message =~ s/\[(\S+?)\]//isg;
$temp_message = "[quote\]" . $temp_message . "\[/quote\]";
#require HTML_TEXT;
#$temp_message = HTML_TEXT::html_to_text($temp_message);
$temp_message = $AUBBC_mod->html_to_text($temp_message);
}
$sth->finish();
}
# Print list of available users.
my $selected = '';
# my $members = '<select name="to">';
#
# my $query1 = "SELECT * FROM members WHERE approved='1'";
# my $sth = $dbh->prepare($query1);
# $sth->execute || die("Couldn't exec sth!");
# while(my @user_data = $sth->fetchrow)  {
# $selected = ($to eq $user_data[0]) ? " selected" : '';
# $members .= qq(<option value="$user_data[0]"$selected>$user_data[2]/($user_data[3])</option>\n);
# }
# $sth->finish();
# $members .= qq(</select>);
my $members = '<select name="to">';
require get_user;
if($user_data{buddys} && !$to) {
my (@iid) = split (/\,/, $user_data{buddys});
if (@iid) {
foreach my $crap (@iid) {
         my $user_id = get_user::check_user($crap);
        $members .= qq(<option value="$crap"$selected>$user_id</option>\n) if $user_id;
        }
        $members .= qq(</select>);
   }
}
 elsif (!$to) {
   $members = '<input type="text" name="to" value="" size="40" maxlength="50">';
 }
  elsif ($to) {
  my $user_id = get_user::check_user($to);
  $members .= qq(<option value="$to"$selected>$user_id</option>\n) if $user_id;
  $members .= qq(</select>);
  }

        # Generate the UBBC panel.
        require UBBC;
        my $ubbc_panel = UBBC::print_ubbc_panel();
my $sent_msg = '';
if ($message == 1) {
 $sent_msg = '<big><b>Message Was Sent</b></big>';
}
#require theme;
#theme::print_header();
#theme::print_html($user_data{theme}, $nav{send_im});
print "Content-type: text/html\n\n" if $message ne 'send';
print <<HTML if $message ne 'send';
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<title>$cfg{pagetitle}</title>
<meta http-equiv="Content-Type" content="text/html; charset=$cfg{codepage}">
<meta name="Generator" content="Message">
<script type="text/javascript" src="$cfg{non_cgi_url}/themes/ubbc.js"></script>
</head>
<body bgcolor="#C5D0DC" text="#000000">
$sent_msg
HTML

print <<HTML;
<table width="100%" border="0" cellspacing="0" cellpadding="1">
<tr>
<td><form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="creator">
<table border="0" align="center">
<tr>
<td><font size="2"><b>$msg{to_userC}</b></font></td>
<td>
$members
</td>
</tr>
<tr>
<td><font size="2"><b>$msg{subjectC}</b></font></td>
<td><input type="text" name="subject" value="$temp_subject" size="40" maxlength="50"></td>
</tr>
<tr>
<td valign="top"><font size="2"><b>$msg{textC}</b></font></td>
<td><script language="javascript" type="text/javascript">
<!--
function addCode(anystr) {
insertAtCursor(document.creator.message, anystr);
}

function showColor(color) {
var colortag = "[color="+color+"][/color]";
insertAtCursor(document.creator.message, colortag);
}
// --></script>

<textarea id="edit" name="message" style="width: 599px; height: 293px;">$temp_message</textarea></td>

</tr>
<tr>
<td valign="top"><font size="2"><b>$msg{ubbc_tagsC}</b></font></td>
<td valign="top"><font size="2">$ubbc_panel</font></td>
</tr>
<tr>
<td colspan="2"><input type="hidden" name="op" value="save_pm">
<input type="submit" value="$btn{send_message}">
<input type="reset" value="$btn{reset}"></td>
</tr>
</table></form>
</td>
</tr>
</table>
HTML
print <<HTML if $message ne 'send';
</body>
</html>
HTML

#theme::print_html($user_data{theme}, $nav{send_im}, 1);
}
# Print New PM Alert
sub pm_alert {
my $pmlist = '';
my $printlist = '';
my $incount = 0;

if ($user_data{uid} ne $usr{anonuser}) {
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
#
# Check Max messages
#
sub check_messages {
my ($from, $other) = @_;
my $outcount = 0;
my $incount = 0;
# Get private messages for user
my $query1 = "SELECT * FROM pmout WHERE memberid='$from'";
my $sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
# build message
if ($row[0]) { $outcount++; }
}
$sth->finish();
if ($outcount >= $max_stmessages) { require error; error::user_error('You Need to Delete Messages From Your Sent PM\'s', $user_data{theme}); }
$query1 = "SELECT * FROM pmin WHERE memberid='$other'";
$sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
# build message
if ($row[0]) { $incount++; }
}
$sth->finish();
if ($incount >= $max_messages) { require error; error::user_error('Members Inbox is Full, Try Their Email.', $user_data{theme}); }
}
#
# Save Pivate Message
#
sub save_pm
{
# Check if user is logged in.
if ($user_data{uid} eq $usr{anonuser}) { require error; error::user_error($err{auth_failure}, $user_data{theme}); }
if (!$to) { require error; error::user_error($err{user_no_exist}, $user_data{theme}); }
if (!$subject) { require error; error::user_error($err{enter_subject}, $user_data{theme}); }
if (!$message) { require error; error::user_error($err{enter_text},    $user_data{theme}); }

require get_user;
my $selected = get_user::check_user($to) || '';
if(!$selected) { require error; error::user_error($err{user_no_exist}, $user_data{theme}); }
# Check Max messages
check_messages($user_data{id}, $to);
# Format the input.
#require HTML_TEXT;
#$subject = HTML_TEXT::html_escape($subject);
#$message = HTML_TEXT::html_escape($message);
$subject = $AUBBC_mod->script_escape($subject);
$message = $AUBBC_mod->script_escape($message);
$subject = $dbh->quote($subject);
$message = $dbh->quote($message);
# Get the current date.
require DATE_TIME;
my $date = DATE_TIME::get_date();
require SQLEdit;
SQLEdit::SQLAddEditDelete("INSERT INTO pmin VALUES (NULL,'$to','$user_data{id}','$date',$subject,$message,'1');");
SQLEdit::SQLAddEditDelete("INSERT INTO pmout VALUES (NULL,'$user_data{id}','$to','$date',$subject,$message);");
$dbh->disconnect();
print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=send_pm;message=1');
}
sub delete_pm {
# Get private messages for user
# Check if user is logged in.
if ($user_data{uid} eq $usr{anonuser}) { require error; error::user_error($err{auth_failure}, $user_data{theme}); }
my $query1;
my @checked = ();
if (!$quote) { $query1 = "SELECT * FROM pmin WHERE memberid='$user_data{id}'"; }
else {$query1 = "SELECT * FROM pmout WHERE memberid='$user_data{id}'"; }
my $sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
      if (!(grep { $row[0] eq $_ } $query->param('id')))
      {
       if (@checked) { @checked = (@checked,"$row[0]"); }
       else {@checked = ("$row[0]"); }

      }
}
$sth->finish();

foreach (@checked) {
my ($lid) = split (/\|/, $_);
require SQLEdit;
if (!$quote) {
SQLEdit::SQLAddEditDelete("DELETE FROM pmin WHERE id='$lid' AND memberid='$user_data{id}'"); }
else { SQLEdit::SQLAddEditDelete("DELETE FROM pmout WHERE id='$lid' AND memberid='$user_data{id}'"); }

}
$dbh->disconnect();
print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view_pm;quote=' . $quote);
}
# delete 2
sub delete_pm2 {
# Check if user is logged in.
if ($user_data{uid} eq $usr{anonuser}) { require error; error::user_error($err{auth_failure}, $user_data{theme}); }
if (!$id) { require error; error::user_error($err{bad_input}, $user_data{theme}); }
require SQLEdit;
if (!$quote) {
SQLEdit::SQLAddEditDelete("DELETE FROM pmin WHERE id='$id' AND memberid='$user_data{id}'"); }
else { SQLEdit::SQLAddEditDelete("DELETE FROM pmout WHERE id='$id' AND memberid='$user_data{id}'"); }
$dbh->disconnect();
print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=in_out_boxs;quote=' . $quote);
}
1;
