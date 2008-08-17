package page;
# =====================================================================
# Flex - WPS SQL
#
# Copyright (C) 2006 by N. K. A. (shakainc@tampabay.rr.com)
#
# This program is NOT free software; you can NOT redistribute it and/or
# modify it!
#
# Name: Page View.
# Version: 1.1 final
# Notes: v1.1 new smiley sub
# Final version has been tested for security and accesses the security
# level by mySQL Query. Admin areas are added.
#
# v1.0 beta - 09/24/2007 07:54:23
# - Test The special text converter s{&#39;}{'}gso; and s{'}{&#39;}gso;
# The ' is for javascripts and the converter of the character is to make it safe
# For a mySQL Query, only the Administrator has access to add to the pages
#
# v1.0 final - 09/21/2007 11:50:16
# v1.0 alpha 1 - 06/19/2006 21:34:28
#
# Date: 10/22/2007 13:17:52
# =====================================================================
use strict;
use vars qw(
    %err $query %cfg $dbh
    %usr %user_data $AUBBC_mod
    );
use exporter;
require error;

my $id  = $query->param('id') || '';

if ($id && $id !~ m!^([0-9]+)$!i) {
error::user_error($err{bad_input});
}

# Main Page View
sub page {
# This script needs $id
if (!$id) {
error::user_error($err{bad_input});
}
my ($text, $title) = ('', '');

# Get the active page
my $sth = "SELECT title, pagetext FROM pages WHERE pageid='$id' AND active='1' AND sec_level='$usr{anonuser}'";
if ($user_data{sec_level} eq $usr{admin}) {
     $sth = "SELECT title, pagetext FROM pages WHERE pageid='$id'";
       }
        elsif ($user_data{sec_level} eq $usr{mod}) {
                $sth = "SELECT title, pagetext FROM pages WHERE pageid='$id' AND active='1' AND sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})'";
        }
         elsif ($user_data{sec_level} eq $usr{user}) {
                $sth = "SELECT title, pagetext FROM pages WHERE pageid='$id' AND active='1' AND sec_level REGEXP '($usr{anonuser}|$usr{user})'";
         }
$sth = $dbh->prepare($sth);
$sth->execute;

require theme;
while(my @row = $sth->fetchrow)  {
$title = theme::eval_theme_tags($row[0]);
$text = theme::eval_theme_tags($row[1]);
}
$sth->finish;

error::user_error($err{bad_input}) unless($text);
#require UBBC;
#$text = UBBC::do_ubbc($text);
#$text = UBBC::do_smileys($text);
$text = $AUBBC_mod->do_all_ubbc($text);

my $admin_link = '';
$admin_link = "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=page_edit;id=$id\" target=\"_blank\">Admin Edit</a><hr>" if ($user_data{sec_level} eq $usr{admin});

#theme::print_header();
#theme::print_html($user_data{theme}, $title);
print "Content-type: text/html\n\n";
# print <<HTML;
# <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
#
# <html>
# <head>
# <title>$cfg{pagetitle}</title>
# <meta http-equiv="Content-Type" content="text/html; charset=$cfg{codepage}">
# <meta name="Generator" content="Message">
# </head>
# <body bgcolor="#C5D0DC" text="#000000">
# <style type="text/css">
#  <!--
# .navtable {
#  background-color : #ebebeb;
#  border-right : 1px solid gray;
#  border-top : 1px solid gray;
#  border-left : 1px solid gray;
#  border-bottom : 1px solid gray;
# }
# -->
# </style>
print <<HTML;
$admin_link
<table width="100%" border="0" cellspacing="0" cellpadding="4" class="navtable">
<tr>
<td>$text</td>
</tr>
</table>
HTML

# </body>
# </html>
$dbh->disconnect();
exit();
#theme::print_html($user_data{theme}, $title, 1);
}

# Page Admin
sub page_admin {

# Check admin's
if($user_data{sec_level} ne $usr{admin}) {
error::user_error($err{auth_failure});
}

my $page_html = <<HTML;
<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=page_edit">Add New Page</a>
<table width="655" border="0" cellspacing="2" cellpadding="4">
  <tr valign="top" align="center" bgcolor="#FFCC00">
    <td width="371"><b>Page Title/Edit</b></td>
    <td width="165"><b>Security Level</b></td>
    <td width="87"><b>Active</b></td>
  </tr>
</table>
HTML

my $sth = "SELECT * FROM pages";
$sth = $dbh->prepare($sth);
$sth->execute;

require theme;
while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
             my $active = 'Yes';
             my $title = theme::eval_theme_tags($row[2]);
             $title =~ s{&#39;}{'}gso;
             $active = 'No' if !$row[1];
             $page_html .= <<HTML;
<table width="655" border="0" cellspacing="2" cellpadding="4">
  <tr valign="top" bgcolor="#CCFFFF">
    <td width="371"><a href="$cfg{pageurl}/index.$cfg{ext}?op=delete_page;id=$row[0]" onclick="javascript:return confirm('Are you sure you want to Delete this item?')">Delete</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b><a href="$cfg{pageurl}/index.$cfg{ext}?op=page_edit;id=$row[0]">$title</a></b></td>
    <td width="165"><b>$row[4]</b></td>
    <td width="87"><b>$active</b></td>
  </tr>
</table>
HTML
      }

}
$sth->finish;

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, 'Page Admin');
        print $page_html;
        theme::print_html($user_data{theme}, 'Page Admin', 1);
}

# Add/Edit Page
sub page_edit {

# Check admin's
if($user_data{sec_level} ne $usr{admin}) {
error::user_error($err{auth_failure});
}

my ($text, $title, $act, $lvl) = ('', '', '', '');
my $page = '';
if ($id) {
   $page = $AUBBC_mod->do_all_ubbc("[page://$id]");
   $page = <<HTML;
 <a href="javascript:doGETRequest('$cfg{pageurl}/index.$cfg{ext}?op=page;id=$id', processReqChangeMany, 'controle', '');">Current Link</a> : javascript:doGETRequest('%pageurl%/index.%ext%?op=page;id=$id', processReqChangeMany, 'controle', '');
<br><b>OR</b><br> $page = [page://$id]
HTML
my $sth = "SELECT * FROM pages WHERE pageid='$id'";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
$title = $row[2];
$text = $row[3];
$act = $row[1];
$lvl = $row[4];
}
$sth->finish;
$text =~ s{&#39;}{'}gso;
$title =~ s{&#39;}{'}gso;
}
 my $seclvl = '';
    foreach (sort keys %usr) {
            my $bs = '';
            $bs = ' selected' if $lvl && $usr{$_} eq $lvl;
            $bs = ' selected' if !$id && $usr{$_} eq $usr{anonuser};
            $seclvl .= "<option value=\"$usr{$_}\"$bs>$usr{$_}</option>\n";
            }
    my $yes = ' selected';
    $yes = '' if !$act;
    my $no = ' selected';
    $no = '' if $act && $id || !$id;

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, 'Page Admin');
print <<HTML;
<br>
$page
<br>
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="page_edit2">
<input type="hidden" name="id" value="$id">
  Title:
  <input type="title" name="title" size="45" value="$title">
  <br><br>
  Text/HTML<br>
  <textarea name="text" cols="65" rows="15">$text</textarea>
  <br>
  Security Level:
  <select name="sec_lvl">
  $seclvl
  </select><br>
  Active:
  <select name="active">
  <option value="1"$yes>Yes</option>
  <option value="0"$no>No</option>
  </select><br><br>
  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="submit" name="Submit" value="Submit">
</form>
HTML
theme::print_html($user_data{theme}, 'Page Admin', 1);
}

sub page_edit2 {
# Check admin's
if($user_data{sec_level} ne $usr{admin}) {
error::user_error($err{auth_failure});
}
# Param
# these 2 are secured
my $active  = $query->param('active')  || 0;
my $sec_lvl  = $query->param('sec_lvl')  || '';

# Test The special text converter for these 2
my $text  = $query->param('text')  || '';
my $title  = $query->param('title')  || '';
# $text =~ s{'}{&#39;}gso;
# $title =~ s{'}{&#39;}gso;
$text = $dbh->quote($text);
$title = $dbh->quote($title);
if ($active && $active !~ m!^([0-9]+)$!i) {
error::user_error($err{bad_input});
}
if ($sec_lvl && $sec_lvl !~ m!^([a-zA-Z]+)$!i) {
error::user_error($err{bad_input});
}
if (!$id) {
    require SQLEdit;
    SQLEdit::SQLAddEditDelete("INSERT INTO pages VALUES (NULL,'$active',$title,$text,'$sec_lvl');");
    }
     elsif ($id) {
$id = $dbh->quote($id);
my $sql = qq(UPDATE `pages` SET `active` = '$active',
`title` = $title,
`pagetext` = $text,
`sec_level` = '$sec_lvl' WHERE `pageid` =$id LIMIT 1 ;);
             require SQLEdit;
             SQLEdit::SQLAddEditDelete($sql);
     }
        $dbh->disconnect();
        # Redirect to page_admin.
        print $query->redirect(
                -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=page_admin'
            );
}
# Delete pages
sub delete_page {

# Check admin's
if($user_data{sec_level} ne $usr{admin}) {
error::user_error($err{auth_failure});
}
if ($id) {
# Add page
$id = $dbh->quote($id);
require SQLEdit;
SQLEdit::SQLAddEditDelete("DELETE FROM pages WHERE pageid=$id");
}
        $dbh->disconnect();
        # Redirect to page_admin.
        print $query->redirect(
                -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=page_admin'
            );
}
1;
