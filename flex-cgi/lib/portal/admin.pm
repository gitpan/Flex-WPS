package admin;
#
# Admin area security system - not made yet
#
# 01/01/2008 - 12:49:15
# v0.70% alpha - Theme and Optimize updates
#
# v0.65% alpha -10/18/2007 08:29:33- inputs secured, some admin areas not added

# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    $query
    %user_data %err $dbh %cfg %usr %nav
    );
use exporter;

# Check admin's
if($user_data{sec_level} ne $usr{admin}) {
require error;
error::user_error($err{auth_failure});
exit(0);
}

my $id = $query->param('id') || '';
my $title = $query->param('title') || '';
my $message = $query->param('message') || '';
my $html = $query->param('html') || 2;

my $image = $query->param('image') || '';
my $image2 = $query->param('image2') || '';
my $loc = $query->param('loc') || '';
my $inputer = $query->param('inputcrap') || '';

my $add = $query->param('add') || '';
my $f_mode = $query->param('mode') || '';

sub admin {

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
        print <<HTML;
<table width="95%" border="1" cellspacing="5" cellpadding="4" align="center" class="navtable">
  <tr align="center">
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=awelcome"><img src="$cfg{imagesurl}/admin/welcome.png" border="0"><br><b>Welcome Message</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=main_menu"><img src="$cfg{imagesurl}/admin/menu.png" border="0"><br><b>Main Menu</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=user_menu"><img src="$cfg{imagesurl}/admin/menu.png" border="0"><br><b>User Menu</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=user_ranks"><img src="$cfg{imagesurl}/admin/rank.png" border="0"><br><b>XP Ranks</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=user_actions"><img src="$cfg{imagesurl}/admin/action.png" border="0"><br><b>Portal Actions</b></a></td>
  </tr>
  <tr align="center">
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=flush_mem"><img src="$cfg{imagesurl}/admin/mem.png" border="0"><br><b>Flush Memoize</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=subs_load"><img src="$cfg{imagesurl}/admin/subs.png" border="0"><br><b>Sub(s) Load</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=admin_config"><img src="$cfg{imagesurl}/admin/config.png" border="0"><br><b>Portal Config</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=site_ban"><img src="$cfg{imagesurl}/admin/ban.png" border="0"><br><b>IP Ban</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=modules"><img src="$cfg{imagesurl}/admin/mod.png" border="0"><br><b>Portal Modules</b></a></td>
  </tr>
  <tr align="center">
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=theme"><img src="$cfg{imagesurl}/admin/theme.png" border="0"><br><b>Portal Themes</b></a></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=modules"><img src="$cfg{imagesurl}/admin/blocks.png" border="0"><br><b>Menu Blocks</b></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=modules"><img src="$cfg{imagesurl}/admin/flags.png" border="0"><br><b>Country Flags</b></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=modules"><img src="$cfg{imagesurl}/admin/avatars.png" border="0"><br><b>User Avatars</b></td>
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=meta_tags"><img src="$cfg{imagesurl}/admin/meta.png" border="0"><br><b>Meta Tags</b></td>
  </tr>
  <tr align="center">
    <td><a href="$cfg{pageurl}/index.$cfg{ext}?op=optimize"><img src="$cfg{imagesurl}/admin/optimize.png" border="0"><br><b>Optimize Tables</b></a></td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr align="center">
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
HTML
        theme::print_html($user_data{theme}, $nav{view_profile}, 1);
}
sub awelcome {
my $form = '';
my $sth = "SELECT * FROM welcome WHERE id='1'";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
my $tlt = $row[2] || '';
my $msg = $row[3] || '';
 $form .= qq(<div align="left"><form name="form1" method="post" action="$cfg{pageurl}/index.$cfg{ext}?op=awelcome2">
<input type="hidden" name="op" value="awelcome2"><br>
<b>Title:</b> <input type="text" name="title" size="45" value="$tlt">
<br><br><b>Message:</b><br>
<textarea name="message" rows="8" cols="45">$msg</textarea><br>
<input type="radio" name="html" value="1" checked>
<b>Allow HTML</b><br>
<input type="radio" name="html" value="2">
<b>Use UBBC</b><br>
<input type="radio" name="html" value="3">
<b>Use Text Only</b><br><input type="submit" name="Submit" value="Submit">
</form></div>);
 }
 $sth->finish();

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
        print $form;
        theme::print_html($user_data{theme}, $nav{view_profile}, 1);
}
sub awelcome2 {

# if ($html eq '1') {
# require UBBC;
# $title = UBBC::do_ubbc($title);
# $message = UBBC::do_ubbc($message);
# }
# els
# if($html eq '3') {
# require HTML_TEXT;
# $title = HTML_TEXT::html_escape($title);
# $message = HTML_TEXT::html_escape($message);
# }
# elsif ($html eq '2') {
# require HTML_TEXT;
# $title = HTML_TEXT::html_escape($title);
# $message = HTML_TEXT::html_escape($message);
# }
$message = $dbh->quote($message);
$title = $dbh->quote($title);
my $sql = qq(UPDATE `welcome` SET `title` = $title,
`text` = $message WHERE `id` ='1' LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
                # Redirect to the welcome page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=awelcome'
                    );
}

sub user_actions {
my $html = '';  #
my $sth = qq(SELECT * FROM useractions);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
my $select = ' selected';
my $select2 = ' selected';
$select2 = '' if $row[3];
$select = '' if !$row[3];
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="user_actions2">
<input type="hidden" name="id" value="$row[0]">
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')">
    </td>
    <td width="26%">
        <input type="text" name="title" value="$row[1]">
      </td>
    <td width="26%">
        <input type="text" name="message" value="$row[2]">
      </td>
    <td width="17%">
        <select name="html">
          <option value="1"$select>Yes</option>
          <option value=""$select2>No</option>
        </select>
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=user_actions2;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();


        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
        print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Portal Actions Edit</p>
These are the most commen actions the portal can do from the /portal folder.<br>
Changing Active to "No" will disable that action for all user groups.<br>
The main_page/Home page of the portal can not be disabled.</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="user_actions2">
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New">
      </td>
      <td width="32%">
        <input type="text" name="title">
      </td>
      <td width="33%">
        <input type="text" name="message">
      </td>
      <td width="20%">
        <select name="html">
          <option value="1" selected>Yes</option>
          <option value="">No</option>
        </select>
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>PM Name</b></td>
    <td width="26%"><b>Sub Name</b></td>
    <td width="17%"><b>Active</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr>
HTML
        theme::print_html($user_data{theme}, $nav{view_profile}, 1);

}

sub user_actions2 {
# secure $id
$html = '' if $html eq 2;

# Will need to only use a-z0-9_ for the 2 param's
# $title =~ s{'}{&#39;}gso; # SQL Safer
# $title =~ s{\\}{&#92;}gso; # need this!
# $message =~ s{'}{&#39;}gso; # SQL Safer
# $message =~ s{\\}{&#92;}gso; # need this!

if ($id && !$title && !$message) { # Delete
 my $sql = qq(DELETE FROM useractions WHERE id='$id');
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();

}
 elsif ($id && $message) { # Edit
$title = $dbh->quote($title);
$message = $dbh->quote($message);
$html = $dbh->quote($html);
 my $sql = qq(UPDATE `useractions` SET `pmname` = $title,
`subname` = $message, `active` = $html WHERE `id` = '$id' LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
 }
  elsif (!$id && $message) { # Add
$title = $dbh->quote($title);
$message = $dbh->quote($message);
$html = $dbh->quote($html);
  #INSERT INTO useractions VALUES (NULL,'$title','$message','$html');
   my $sql = qq(INSERT INTO useractions VALUES (NULL,$title,$message,$html););
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=user_actions'
                    );
}

sub main_menu {
my $html = '';  #
my $sth = qq(SELECT * FROM mainmenu);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
my $select = ' selected';
my $select2 = ' selected';
$select2 = '' if $row[5];
$select = '' if !$row[5];
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="main_menu2">
<input type="hidden" name="id" value="$row[0]">
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')">
    </td>
    <td width="26%">
        <select name="html">
          <option value="1"$select>Yes</option>
          <option value=""$select2>No</option>
        </select> <input type="text" name="title" value="$row[1]">
      </td>
    <td width="26%">
        <input type="text" name="message" value="$row[2]">
      </td>
    <td width="17%">
        <input type="text" name="image" value="$row[3]" size="14"> <input type="text" name="image2" value="$row[4]" size="14">
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=main_menu2;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();


        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
        print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Main Menu Edit</p>
These are the Link(s) in the Main Menu and any user group can view an active link.<br>
The Theme Tag converter is used, so you can easly point to the main page like this.<br>
%pageurl%/index.%ext% = $cfg{pageurl}/index.$cfg{ext}</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="main_menu2">
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New">
      </td>
      <td width="32%">
          <select name="html">
          <option value="1" selected>Yes</option>
          <option value="">No</option>
        </select> <input type="text" name="title">
      </td>
      <td width="33%">
        <input type="text" name="message">
      </td>
      <td width="20%">
         <input type="text" name="image" value="" size="14"> <input type="text" name="image2" value="" size="14">
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Active/Title</b></td>
    <td width="26%"><b>Link</b></td>
    <td width="17%"><b>Image(s)</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr>
HTML
        theme::print_html($user_data{theme}, $nav{view_profile}, 1);

}

sub main_menu2 {

$html = '' if $html eq 2;

# Will need to only use a-zA-Z0-9 _ for $title
#$title =~ s{'}{&#39;}gso; # SQL Safer
#$title =~ s{\\}{&#92;}gso; # need this!

# This is the link a-z0-9A-Z/_ %?;.-&  - this is an admin area.
# So the most troubled characters are filtered
#$message =~ s{'}{&#39;}gso; # SQL Safer
#$message =~ s{\\}{&#92;}gso; # need this!

if ($id && !$title && !$message) { # Delete
 my $sql = qq(DELETE FROM mainmenu WHERE id='$id');
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();

}
 elsif ($id && $message) { # Edit
 $title = $dbh->quote($title);
 $message = $dbh->quote($message);
 $image = $dbh->quote($image);
 $image2 = $dbh->quote($image2);
 $html = $dbh->quote($html);
 my $sql = qq(UPDATE `mainmenu` SET `title` = $title, `link` = $message,
 `image` = $image,
 `image2` = $image2,
 `active` = $html WHERE `id` = '$id' LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
 }
  elsif (!$id && $message) { # Add
 $title = $dbh->quote($title);
 $message = $dbh->quote($message);
 $image = $dbh->quote($image);
 $image2 = $dbh->quote($image2);
 $html = $dbh->quote($html);
   my $sql = qq(INSERT INTO mainmenu VALUES (NULL,$title,$message,$image,$image2,$html););
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=main_menu'
                    );
}

sub user_menu {
my $html = '';  #
my $sth = qq(SELECT * FROM usermenu);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
 my $seclvl = '';
    foreach (sort keys %usr) {
            my $bs = '';
            $bs = ' selected' if $row[5] && $usr{$_} eq $row[5];
            #$bs = ' selected' if !$id && $usr{$_} eq $usr{anonuser};
            $seclvl .= "<option value=\"$usr{$_}\"$bs>$usr{$_}</option>\n";
            }
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="user_menu2">
<input type="hidden" name="id" value="$row[0]">
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')">
    </td>
    <td width="26%">
        <select name="html">
          $seclvl
        </select> <input type="text" name="title" value="$row[1]">
      </td>
    <td width="26%">
        <input type="text" name="message" value="$row[2]">
      </td>
    <td width="17%">
        <input type="text" name="image" value="$row[3]" size="14"> <input type="text" name="image2" value="$row[4]" size="14">
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=user_menu2;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();

 my $seclvl2 = '';
    foreach (sort keys %usr) {
            my $bs = '';
            #$bs = ' selected' if $row[5] && $usr{$_} eq $row[5];
            $bs = ' selected' if $usr{$_} eq $usr{anonuser};
            $seclvl2 .= "<option value=\"$usr{$_}\"$bs>$usr{$_}</option>\n";
            }
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
        print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">User Menu Edit</p>
These are the Link(s) in the User Menu, you can controle what user groups can see the links.<br>
$usr{admin} = See's all, $usr{mod} = See's all but $usr{admin} links, $usr{user} = See's $usr{user} & $usr{anonuser} Links.<br>
The Theme Tag converter is used, so you can easly point to the main page like this.<br>
%pageurl%/index.%ext% = $cfg{pageurl}/index.$cfg{ext}</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="user_menu2">
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New">
      </td>
      <td width="32%">
          <select name="html">
          $seclvl2
        </select> <input type="text" name="title">
      </td>
      <td width="33%">
        <input type="text" name="message">
      </td>
      <td width="20%">
         <input type="text" name="image" value="" size="14"> <input type="text" name="image2" value="" size="14">
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>Security Level/Title</b></td>
    <td width="26%"><b>Link</b></td>
    <td width="17%"><b>Image(s)</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr>
HTML
        theme::print_html($user_data{theme}, $nav{view_profile}, 1);

}

sub user_menu2 {

$html = '' if $html eq 2;

# Will need to only use a-zA-Z0-9 _ for $title
# $title =~ s{'}{&#39;}gso; # SQL Safer
# $title =~ s{\\}{&#92;}gso; # need this!

# This is the link a-z0-9A-Z/_ %?;.-&  - this is an admin area.
# So the most troubled characters are filtered
# $message =~ s{'}{&#39;}gso; # SQL Safer
# $message =~ s{\\}{&#92;}gso; # need this!

if ($id && !$title && !$message) { # Delete
 my $sql = qq(DELETE FROM usermenu WHERE id='$id');
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();

}
 elsif ($id && $message) { # Edit
 $title = $dbh->quote($title);
 $message = $dbh->quote($message);
 $image = $dbh->quote($image);
 $image2 = $dbh->quote($image2);
 $html = $dbh->quote($html);
 my $sql = qq(UPDATE `usermenu` SET `title` = $title, `link` = $message,
`image` = $image, `image2` = $image2, `seclevel` = $html WHERE `id` = '$id' LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
 }
  elsif (!$id && $message) { # Add
 $title = $dbh->quote($title);
 $message = $dbh->quote($message);
 $image = $dbh->quote($image);
 $image2 = $dbh->quote($image2);
 $html = $dbh->quote($html);
   my $sql = qq(INSERT INTO usermenu VALUES (NULL,$title,$message,$image,$image2,$html,''););
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=user_menu'
                    );
}
sub user_ranks {
my $html = '';  #
my $sth = qq(SELECT * FROM rank);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="user_ranks2">
<input type="hidden" name="id" value="$row[0]">
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')">
    </td>
    <td width="26%">
        <input type="text" name="title" value="$row[1]">
      </td>
    <td width="26%">
        <input type="text" name="message" value="$row[2]">
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=user_ranks2;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();


        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
        print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Rank Edit</p>
<b>XP</b> The amout of Experience Required for that Rank<br>
The Rank Name in also linked to the rank image "Rank Name.gif"<br>
</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="user_ranks2">
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New">
      </td>
      <td width="32%">
        <input type="text" name="title">
      </td>
      <td width="33%">
        <input type="text" name="message">
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>XP</b></td>
    <td width="26%"><b>Rank Name</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr>
HTML
        theme::print_html($user_data{theme}, $nav{view_profile}, 1);

}

sub user_ranks2 {

#$html = '' if $html eq 2;

# Will need to only use a-z0-9_ for the 2 param's
# $title =~ s{'}{&#39;}gso; # SQL Safer
# $title =~ s{\\}{&#92;}gso; # need this!
# $message =~ s{'}{&#39;}gso; # SQL Safer
# $message =~ s{\\}{&#92;}gso; # need this!

if ($id && !$title && !$message) { # Delete
 my $sql = qq(DELETE FROM rank WHERE rankid='$id' LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();

}
 elsif ($id && $message) { # Edit
 $title = $dbh->quote($title);
 $message = $dbh->quote($message);
 my $sql = qq(UPDATE `rank` SET `ranknumber` = $title,
`rankname` = $message WHERE `rankid` = '$id' LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
 }
  elsif (!$id && $message) { # Add
 $title = $dbh->quote($title);
 $message = $dbh->quote($message);
  #INSERT INTO useractions VALUES (NULL,'$title','$message','$html');
   my $sql = qq(INSERT INTO rank VALUES (NULL,$title,$message););
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=user_ranks'
                    );
}
sub admin_config {
my %cp = ();

my $sth = 'SELECT * FROM portalconfigs WHERE configid=1';
#$sth = filters::untaint2($sth, '0-9a-zA-Z\=\*\s');
#die("Couldn't exec sth! at Get Portal Config a2") if !$sth;
$sth = $dbh->prepare($sth) or die $DBI::errstr;
$sth->execute || die("Couldn't exec sth! at Get Portal Config b2");

while(my @row = $sth->fetchrow)  {
# Have to clean and setup the config with better stuff!!!
# little cleaner
# not using ip_time, enable_approvals, date_format?,
#
%cp = (
 'a.configid' => $row[0],
 'ab.pagename' => $row[1],
 'ac.pagetitle' => $row[2],
 'ad.cgi_bin_dir' => $row[3],
 'ae.non_cgi_dir' => $row[4],
 'af.cgi_bin_url' => $row[5],
 'ag.non_cgi_url' => $row[6],
 'ah.lang' => $row[7],
 'ai.codepage' => $row[8],
 'aj.ip_time' => $row[9],
 'ak.enable_approvals' => $row[10],
 'al.webmaster_email' => $row[11],
 'am.mail_type' => $row[12],
 'an.mail_program' => $row[13],
 'ao.smtp_server' => $row[14],
 'ap.time_offset' => $row[15],
 'aq.date_format' => $row[16],
 'ar.cookie_expire' => $row[17],
 'as.max_items_per_page' => $row[18],
 'at.max_upload_size' => $row[19],
 'au.picture_height' => $row[20],
 'av.picture_width' => $row[21],
 'aw.ext' => $row[22]
 );
 }
 $sth->finish();

my $stuff = '';
                    foreach (sort keys %cp) {
                    my $key_n = $_;
                    $key_n =~ s/\A\w+\.//g;
                    $stuff .= qq(<tr><td>$key_n =></td><td> <input type="text" name="id" value="$cp{$_}"></td></tr>);
                   }

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, 'Config');
        print <<HTML;
<form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="item_list">
<input type="submit" value="Edit Config" onclick="javascript:return confirm('This Will Update the Settings to the Site.')">
<table>
$stuff
</table>
<input type="hidden" name="op" value="admin_config2">
<input type="submit" value="Edit Config" onclick="javascript:return confirm('This Will Update the Settings to the Site.')">
</form>
HTML

theme::print_html($user_data{theme}, 'Config', 1);
}
sub admin_config2 {

      my @row = grep { !// } $query->param('id');
      my @new_row = ();
      foreach (@row) {
              $_ = $dbh->quote($_);
              push ( @new_row, $_  );
              }
              @row = @new_row;
# foreach my $set (@stuff) {
#  $stuff .= $set . '<br>';
# }   $dbh->quote($message);
my $stuff = qq(UPDATE `portalconfigs` SET `pagename` = $row[1],
`pagetitle` = $row[2],
`cgi_bin_dir` = $row[3],
`non_cgi_dir` = $row[4],
`cgi_bin_url` = $row[5],
`non_cgi_url` = $row[6],
`lang` = $row[7],
`codepage` = $row[8],
`ip_time` = $row[9],
`enable_approvals` = $row[10],
`webmaster_email` = $row[11],
`mail_type` = $row[12],
`mail_program` = $row[13],
`smtp_server` = $row[14],
`time_offset` = $row[15],
`date_format` = $row[16],
`cookie_expire` = $row[17],
`max_items_per_page` = $row[18],
`max_upload_size` = $row[19],
`picture_height` = $row[20],
`picture_width` = $row[21],
`ext` = $row[22] WHERE `configid` =$row[0] LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($stuff);
#         require theme;
#         theme::print_header();
#         theme::print_html($user_data{theme}, 'Config');
#         print <<HTML;
# Some Stuff<br>
# $stuff
# HTML
#
# theme::print_html($user_data{theme}, 'Config', 1);
                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin_config'
                    );
}
sub flush_mem {

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
        print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Flush Memoize</p>
Memoize is only used on these functions.<br>
SQLsubs::SQLConnect, SQLsubs::SQLConfig, SQLsubs::SQLUserAction<br>
There is an Auto Flush function for Memoize that will flush the chache every 1 day.(soon!!)</td>
</tr></table>
<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=flush_mem2">Flush Memoize?</a></center>
<hr>
HTML
        theme::print_html($user_data{theme}, $nav{view_profile}, 1);

}

sub flush_mem2 {
use Memoize;
#Memoize::flush_cache('');
Memoize::flush_cache('SQLsubs::SQLConnect');
Memoize::flush_cache('SQLsubs::SQLConfig');
#Memoize::flush_cache('SQLsubs::SQL_Auth_Session');
#Memoize::flush_cache('SQLSubLoad::SQLSubLoad'); # may take out
Memoize::flush_cache('SQLsubs::SQLUserAction');
#Memoize::flush_cache('GD::SecurityImage::new');

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=flush_mem'
                    );
}
sub subs_load {
my $html = '';  #
my $sth = qq(SELECT * FROM subload);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
# my $select = ' selected';
# my $select2 = ' selected';
# $select2 = '' if $row[5];
# $select = '' if !$row[5];
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="subs_load2">
<input type="hidden" name="id" value="$row[0]">
  <tr>
    <td width="12%">
        <input type="submit" name="Edit" value="Edit" onclick="javascript:return confirm('Are you sure you want to Edit this item?')">
    </td>
    <td width="26%">
    <input type="text" name="title" value="$row[1]" size="5">
    <input type="text" name="message" value="$row[2]" size="5">
      </td>
    <td width="26%">
        <input type="text" name="image" value="$row[3]" size="14"> <input type="text" name="image2" value="$row[4]" size="14">
      </td>
    <td width="17%">
        <input type="text" name="loc" value="$row[5]" size="5">
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=subs_load2;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
 </form>
</table>
HTML

}
$sth->finish();


        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
        print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Sub(s) Load Edit</p>
These are the Perl Subroutines that can be loaded.<br>
<b>For the "lib/module" these are the patters for calling scripts in the folders:</b><br>
1 & 0 = /lib, 0 & 0 = /lib/portal, 0 & 1 = /lib/module<br>
<b>Locations:</b> 1 is for subs that do background tasks befor the theme, 2-6 can be used to print html/text in the theme,<br>
'home' can be used to print html/text under the welcome message of the Home Page.</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="subs_load2">
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New">
      </td>
      <td width="32%">
      <input type="text" name="title" value="" size="5">
    <input type="text" name="message" value="" size="5">
      </td>
      <td width="33%">
        <input type="text" name="image" value="" size="14"> <input type="text" name="image2" value="" size="14">
      </td>
      <td width="20%">
         <input type="text" name="loc" value="" size="5">
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%"><b>Edit</b></td>
    <td width="26%"><b>lib/module</b></td>
    <td width="26%"><b>PM/Sub Name</b></td>
    <td width="17%"><b>Location</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr>
HTML
        theme::print_html($user_data{theme}, $nav{view_profile}, 1);

}

sub subs_load2 {

$html = '' if $html eq 2;

# Will need to only use a-zA-Z0-9 _ for $title
#$title =~ s{'}{&#39;}gso; # SQL Safer
#$title =~ s{\\}{&#92;}gso; # need this!

# This is the link a-z0-9A-Z/_ %?;.-&  - this is an admin area.
# So the most troubled characters are filtered
#$message =~ s{'}{&#39;}gso; # SQL Safer
#$message =~ s{\\}{&#92;}gso; # need this!

if ($id && !$image && !$image2) { # Delete
 my $sql = qq(DELETE FROM subload WHERE id='$id');
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();

}
 elsif ($id && $image && $image2) { # Edit
 $title = $dbh->quote($title);
 $message = $dbh->quote($message);
 $image = $dbh->quote($image);
 $image2 = $dbh->quote($image2);
 $loc = $dbh->quote($loc);
 $id = $dbh->quote($id);
 my $sql = qq(UPDATE `subload` SET `lib` = $title, `module` = $message,
`pmname` = $image, `subname` = $image2, `location` = $loc WHERE `id` = $id LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
 }
  elsif (!$id && $image && $image2) { # Add
  $title = $dbh->quote($title);
 $message = $dbh->quote($message);
 $image = $dbh->quote($image);
 $image2 = $dbh->quote($image2);
 $loc = $dbh->quote($loc);
   my $sql = qq(INSERT INTO subload VALUES (NULL,$title,$message,$image,$image2,$loc););
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=subs_load'
                    );
}
sub site_ban {
my $html = '';
require DATE_TIME;
my $sth = qq(SELECT * FROM ban);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
$row[1] = DATE_TIME::format_date($row[1], 5);
$row[3] = DATE_TIME::format_date($row[3], 5);
$html .= <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
  <tr>
    <td width="12%">&nbsp;</td>
    <td width="26%">
        $row[0]
      </td>
    <td width="26%">
        $row[2]
      </td>
    <td width="17%">
        $row[1]<br>$row[3]
      </td>
      <td width="19%" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=site_ban2;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a></td>
  </tr>
</table>
HTML

}
$sth->finish();

         my $ip_ban = '<font color=DarkRed><b>Site Ban Did Not Load</b></font><br>';
         $ip_ban = '<font color=Green><b>Site Ban is Working</b></font><br>' if $cfg{check_ban};
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
        print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Site Ban Edit</p>
$ip_ban
Here you can mannage what IP's or Domain names you would like to Block from your site.<br>
</td>
</tr></table>
  <table width="76%" border="1" cellspacing="0" cellpadding="4">
<form method="post" action="">
<input type="hidden" name="op" value="site_ban2">
    <tr>
      <td width="12%">
        <input type="submit" name="Submit" value="Add New">
      </td>
      <td width="32%">
        <input type="text" name="message">
      </td>
      <td width="33%">
      </td>
      <td width="20%">
      </td>
    </tr>
    </form>
  </table>
<table width="95%" border="1" cellspacing="0" cellpadding="4" bgcolor="#CCFF00">
  <tr align="center">
    <td width="12%">&nbsp;</td>
    <td width="26%"><b>IP</b></td>
    <td width="26%"><b>Ban Count</b></td>
    <td width="17%"><b>First & Last Date</b></td>
    <td width="19%"><b>Delete</b></td>
  </tr>
</table>
$html
<hr>
HTML
        theme::print_html($user_data{theme}, $nav{view_profile}, 1);

}

sub site_ban2 {

#$html = '' if $html eq 2;

# Will need to only use a-zA-Z0-9 _ for $title
#$message =~ s{'}{&#39;}gso; # SQL Safer
#$message =~ s{\\}{&#92;}gso; # need this!

# This is the link a-z0-9A-Z/_ %?;.-&  - this is an admin area.
# So the most troubled characters are filtered
#$message =~ s{'}{&#39;}gso; # SQL Safer
#$message =~ s{\\}{&#92;}gso; # need this!

if ($id) { # Delete
 $id = $dbh->quote($id);
 my $sql = qq(DELETE FROM ban WHERE id=$id);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();

}
 elsif ($message) { # Add

my $add = 1;
 $message = $dbh->quote($message);
my $sth = qq(SELECT banid FROM ban WHERE banid=$message);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {
      if ($row[0]) {
       $add = 0;
       last;
      }

}
$sth->finish();
      if ($add) {
           my $DATE = time || 'DATE';
           my $string = qq(INSERT INTO `ban` VALUES ( $message , '$DATE' , '0', '$DATE' ););
           require SQLEdit;
           SQLEdit::SQLAddEditDelete($string);
           $dbh->disconnect();
           }
  }

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=site_ban'
                    );
}
sub theme {
$id = $dbh->quote($id) if $id;
$add = '' if $add ne 'add';
my $sth = '';
my @row = ();

if (!$add) {
$sth = qq(SELECT * FROM themes WHERE themeid =$id LIMIT 1;);
$sth = qq(SELECT * FROM themes WHERE active ='1' LIMIT 1;) if !$id;
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @theme_info = $sth->fetchrow) {
 push (@row, @theme_info);
}
$sth->finish();
 }
 
$sth = qq(SELECT * FROM themes);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
my $theme_form = qq(<form method="post" action="">
<input type="hidden" name="op" value="theme">
<b>Select a Theme:</b> active = 1 Default Theme | <a href="$cfg{pageurl}/index.$cfg{ext}?op=theme;add=add">Add New Theme</a><br>
<select name="id">);
while(my @theme_info = $sth->fetchrow) {
 $theme_form .= qq(<option value="$theme_info[0]">$theme_info[2] - $theme_info[1]</option>\n);
}
$sth->finish();
$theme_form .= qq(</select>
<input type="image" src="$cfg{imagesurl}/forum/move.png" Border="0" name="submit">
</form>);

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
 print <<HTML;
 $theme_form
<form method="post" action="">
  <input type="hidden" name="id" value="$row[0]">
  <input type="hidden" name="add" value="$add">
  <input type="hidden" name="op" value="theme2">
  <table width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Active</b><br>
<input type="text" name="title" value="$row[1]"> <a href="$cfg{pageurl}/index.$cfg{ext}?op=theme2;add=1;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this Theme?')">Delete Theme</a>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td> &nbsp;<b>Theme Name</b><br>
<input type="text" name="html" value="$row[2]">
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Theme Top</b><br>
<textarea name="image" cols="50" rows="10">$row[3]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Theme 1</b><br>
<textarea name="image2" cols="50" rows="10">$row[4]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Theme 2</b><br>
<textarea name="loc" cols="50" rows="10">$row[5]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Theme 3</b><br>
<textarea name="message" cols="50" rows="10">$row[6]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Theme Bottom</b><br>
<textarea name="inputcrap" cols="50" rows="10">$row[7]</textarea>
      </td>
    </tr>
  </table>
  <input type="submit" name="Submit" value="Submit">&nbsp;&nbsp;&nbsp;<input type="submit" name="mode" value="Duplicate">
</form>
HTML

theme::print_html($user_data{theme}, $nav{view_profile}, 1);

}

sub theme2 {
 my $url_link = $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=theme;id=' . $id;
 $title = $dbh->quote($title);
 $message = $dbh->quote($message);
 $image = $dbh->quote($image);
 $image2 = $dbh->quote($image2);
 $loc = $dbh->quote($loc);
 $html = $dbh->quote($html);
 $id = $dbh->quote($id);
 $inputer = $dbh->quote($inputer);
 #$add = '' if $add ne 'add';
        my $string = '';
        if ($f_mode eq 'Duplicate' && $html) {
                $string = qq(INSERT INTO `themes` VALUES (NULL,$title,$html,$image,$image2,$loc,$message,$inputer););
          }
            elsif (!$add && $id && $html) {
                $string = qq(UPDATE `themes` SET `active` = $title,
`themename` = $html, `theme_top` = $image, `theme_1` = $image2,
`theme_2` = $loc, `theme_3` = $message, `theme_4` = $inputer WHERE `themeid` = $id LIMIT 1 ;);
            }
             elsif ($add eq '1' &&  $id) {
                $string = qq(DELETE FROM `themes` WHERE `themeid` = $id LIMIT 1 ;);
             }
              elsif ($add eq 'add' && $html) {
                $string = qq(INSERT INTO `themes` VALUES (NULL,$title,$html,$image,$image2,$loc,$message,$inputer););
              }
             
           require SQLEdit;
           SQLEdit::SQLAddEditDelete($string) if $string;
           $dbh->disconnect();

                # Redirect to user_actions page.
                print $query->redirect( -location => $url_link );
}

sub meta_tags {
my $sth = qq(SELECT * FROM meta_tags);
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow) {

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});
 print <<HTML;
<form method="post" action="">
  <input type="hidden" name="op" value="meta_tags2">
   <input type="hidden" name="id" value="$row[0]">
  <table width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Description</b><br>
<textarea name="title" cols="50" rows="10">$row[0]</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td> &nbsp;<b>Keywords</b><br>
<textarea name="image" cols="50" rows="10">$row[1]</textarea>
      </td>
    </tr>
  </table>
  &nbsp;&nbsp;&nbsp;<input type="submit" name="Submit" value="Submit">
</form>
HTML
}
$sth->finish();
theme::print_html($user_data{theme}, $nav{view_profile}, 1);
}

sub meta_tags2 {
 $title = $dbh->quote($title);
 $image = $dbh->quote($image);
 $id = $dbh->quote($id);
           my $string = qq(UPDATE `meta_tags` SET `description` = $title,
`keywords` = $image WHERE `description` = $id LIMIT 1 ;);
           require SQLEdit;
           SQLEdit::SQLAddEditDelete($string);
           $dbh->disconnect();

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=meta_tags'
                    );
}
# Needs testing
sub optimize {
# Check admin's
if($user_data{sec_level} ne $usr{admin}) {
require error;
error::user_error($err{auth_failure});
}
my @info = ('ajax_scripts', 'auth_session', 'avatars', 'ban', 'blocks', 'config', 'mainmenu', 'members', 'meta_tags', 'module_settings', 'pages', 'pmin', 'pmout', 'portalconfigs', 'rank', 'search_log', 'stats_log', 'subload', 'themes', 'useractions', 'usergroups', 'usermenu', 'welcome', 'whosonline');
my (@stuff, @module_tables, @all_tables) = ( (), (), () );
my $modules_delete = '';
my $sth = "SELECT * FROM `optimize`";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
        push ( @module_tables, $row[1] );

        $modules_delete .= qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=optimize;id=$row[0];add=1" onclick="javascript:return confirm('Are you sure you want to Delete this table?')">$row[1]</a> );
}
$sth->finish;

push ( @all_tables, @info );
push ( @all_tables, @module_tables ) if @module_tables;

# SHOW TABLE STATUS LIKE $table
# OPTIMIZE TABLE $table
# FLUSH TABLES WITH READ LOCK
foreach my $table (@all_tables) {
# SHOW TABLE STATUS LIKE $table
$sth = "SHOW TABLE STATUS LIKE '$table'";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {

# Note: I know the MyISAM name works for me, the php code i modeled this from used MYISAM in its code.
# So the BDB name has not been tested and could be wrong.
if ($row[9] && ($row[1] eq 'MyISAM' || $row[1] eq 'BDB')) {
                push ( @stuff, $row[0] );
#                 push (
#                 @stuff,
#                 join (
#                         "|",   'Name', $row[0], '<br>', 'Engine', $row[1], '<br>',
#                         'Version', $row[2], '<br>', 'Row_format', $row[3], '<br>',
#                         'Rows', $row[4], '<br>', 'Avg_row_length',$row[5], '<br>',
#                         'Data_length', $row[6], '<br>', 'Max_data_length', $row[7], '<br>',
#                         'Index_length', $row[8], '<br>',
#                         'Data_free',$row[9], '<br>', 'Auto_increment', $row[10], '<br>',
#                         'Create_time',$row[11], '<br>', 'Update_time', $row[12], '<br>',
#                         'Check_time',$row[13],'<br>',
#                         'Collation',$row[14], '<br>', 'Checksum',$row[15], '<br>',
#                         'Create_options',$row[16], '<br>', 'Comment',$row[17], '<hr>'
#                 )
#             );
      }
}
$sth->finish;
                  #$stuff .= "<br>";
                   }
                   my $optamize = '';
                   if (@stuff) {
                        require SQLEdit;
                          foreach my $table (@stuff) {
                                  # OPTIMIZE TABLE $table
                                  my $string = qq(OPTIMIZE TABLE $table);
                                  SQLEdit::SQLAddEditDelete($string);

                                  $optamize .= 'OPTIMIZE TABLE ' . $table . '<br><br>';
                          }
                          # FLUSH TABLES WITH READ LOCK
                          my $string = qq(FLUSH TABLES WITH READ LOCK);
                          SQLEdit::SQLAddEditDelete($string); #UNLOCK TABLES
                          $string = qq(UNLOCK TABLES);
                          SQLEdit::SQLAddEditDelete($string);
                   }
                    else {
                          $optamize = 'Nothing to Optimized';
                    }

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, 'Forum');
        print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Optimize Portal Tables</p>
This will optimize Tables for the Main Portal and Added Tables for Modules.<br>
It is Recommended to Run this Page if there has been many Inserts or Edits.<br>
The Optimizer will also check if the Table need to be Optimized.<br>
<b>Main Portal tables:</b><br>
@info<br>
<b>Module tables:</b> Click to delete.<br>
$modules_delete
</td>
</tr></table>
<form method="post" action="">
  <input type="hidden" name="op" value="optimize2">
   <input type="hidden" name="add" value="add">
  <input type="text" name="title" value="">
  &nbsp;&nbsp;&nbsp;<input type="submit" name="Submit" value="Add Table Name">
</form>
$optamize
<hr>
HTML
        theme::print_html($user_data{theme}, 'Forum', 1);
}

sub optimize2 {
 $title = $dbh->quote($title) if $title;
 $id = $dbh->quote($id) if $id;

 #$add = '' if ($add ne 'add' || $add ne '1');
        my $string = '';
        if (!$add && $title && $id) {
                $string = qq(UPDATE `optimize` SET `table_name` = $title WHERE `id` = $id LIMIT 1 ;);
           }
            elsif ($add eq 'add' && $title) {
                $string = qq(INSERT INTO `optimize` VALUES (NULL,$title););
            }
             elsif ($add eq '1' && $id) {
                $string = qq(DELETE FROM `optimize` WHERE `id` = $id LIMIT 1 ;);
             }
           require SQLEdit;
           SQLEdit::SQLAddEditDelete($string) if $string;
           $dbh->disconnect();

                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=optimize'
                    );
}

1;
