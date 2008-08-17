package Wiki;
# Flex-WPS Wiki Module
# v0.99 alpha 3 - 12/24/2007 10:32:51 By: N.K.A.
# - Fixed the admin edit link
#
#
# - v0.99 alpha 2 - 10/24/2007 10:04:28
# - Added User areas and Publisher(this is not done)
# - Still needs more testing & works
#
# - v0.99 alpha 1 - 10/20/2007 08:41:34
# - Fixxed regex Bug build links are now in /lib
# - Added Wiki Search bar
#
# - v0.85 beta - 10/19/2007 07:49:32
# has a regex bug in sub build_links
#
use strict;
use vars qw(
    %user_action $dbh %cfg %user_data
    %nav $query %err %usr $AUBBC_mod
    );
use exporter;
#
# wiki_site table
# id, name, desc, lastdate, lastauther, also_see
#
# wiki_journal table
# id, was_id, name, desc, lastdate, lastauther, also_see
#
#
# wiki_user table
# id, uid, name, desc, also_see, active, votes
#
# Define possible user actions.
%user_action = (
                view  => 1,
                view_old => 1,
                admin => 1,
                wiki_edit => 1,
                user_view => 1,
                user => 1,
                wiki_useredit => 1,
                publisher => 1,
                publish => 1,
                vote_publish => 1,
                admin_replace => 1,
                view_old2 => 1,
                ); # admin_publish => 1,

sub wiki_search {
print <<HTML;
<table class="navtable" width="100%" border="0" cellspacing="0" cellpadding="0"><tr>
<form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="sbox" onSubmit="if (document.sbox.query.value=='') return false">
<td align="center">
<input type="text" name="query" size="15" class="text">
<input type="hidden" name="what" value="wiki">
<input type="hidden" name="op" value="search">
&nbsp;&nbsp;<input type="submit" value="Wiki $msg{search}">
</td>
</form></tr></table><hr>
HTML
}

sub view {
my $id = $query->param('id') || '';

if ($id) {
# View Wiki
if ($id !~ m!^([0-9]+)$!i) {
     require error;
     error::user_error($err{bad_input});
     }
$id = $dbh->quote($id);

#require UBBC;
require DATE_TIME;
#require HTML_TEXT;
# Print start page.
require theme;
theme::print_header();

my $sth = "SELECT * FROM wiki_site WHERE id=$id LIMIT 1;";
$sth = $dbh->prepare($sth);
$sth->execute;
my $also_see = '';
my $wiki_name = '';
my $wiki = '';
my @row = ();
while(@row = $sth->fetchrow)  {
if ($row[0]) { @row = @row; last; }
}
$sth->finish;
      if (!$row[1]) {
             require error;
             error::user_error($err{bad_input});
             }
$sth = "SELECT * FROM `wiki_journal` WHERE `was_id` = $row[0] LIMIT 1 ;";
$sth = $dbh->prepare($sth);
$sth->execute;
my $old_wiki = '';
while(my @rows = $sth->fetchrow)  {
       $old_wiki = qq( - <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_old;module=Wiki;id=$row[0]">Wiki History</a>) if $rows[0];
}
$sth->finish;
$wiki_name = $row[1];
# id, name, desc, lastdate, lastauther, also_see
#$row[1] = UBBC::do_ubbc($row[1]); # not used anymore
my $descpt = $row[2];
$AUBBC_mod->settings( script_escape => 0, );
$descpt =~ s{\[code\](?s)(.+?)\[/code\]} {
        my $ret = '[code]' . $AUBBC_mod->script_escape($1) . '[/code]';
        $ret ? $ret : $1;
        }exigso;
$descpt =~ s{\[code=(.+?)\](?s)(.+?)\[/code\]} {
        my $ret = "[code=$1]" . $AUBBC_mod->script_escape($2) . '[/code]';
        $ret ? $ret : $2;
        }exigso;
$descpt =~ s{\[c\](?s)(.+?)\[\/c\]} {
        my $ret = '[c]' . $AUBBC_mod->script_escape($1) . '[/c]';
        $ret ? $ret : $1;
        }exigso;
$descpt =~ s{\[cd\](?s)(.+?)\[/cd\]} {
        my $ret = '[cd]' . $AUBBC_mod->script_escape($1) . '[/cd]';
        $ret ? $ret : $1;
        }exigso;
$descpt =~ s{\[c=(.+?)\](?s)(.+?)\[\/c\]} {
        my $ret = "[c=$1\]" . $AUBBC_mod->script_escape($2) . '[/c]';
        $ret ? $ret : $2;
        }exigso;
$descpt =~ s{\[encode\]}{}gso;
$descpt =~ s{\[/encode\]}{}gso;
#$descpt = UBBC::do_ubbc($descpt); # not used anymore
#$descpt = UBBC::do_smileys($descpt); # not used anymore
$descpt = $AUBBC_mod->do_all_ubbc($descpt);
$descpt = theme::eval_theme_tags($descpt);
$row[3] = DATE_TIME::format_date($row[3],11);
if ($row[5]) {
$also_see = $row[5];
$also_see =~ s{\[encode\]}{}gso;
$also_see =~ s{\[/encode\]}{}gso;
#$also_see = UBBC::do_ubbc($row[5]); # not used anymore
#$also_see = UBBC::do_smileys($also_see); # not used anymore
$also_see = $AUBBC_mod->do_all_ubbc($also_see);
$also_see = theme::eval_theme_tags($also_see);
$also_see = qq(<div style="padding: 3px 5px 3px 5px;" class="navtable"><b>Also See</b><br>$also_see</div><hr width="95%">);
}
my $adminht = '';
if ($user_data{sec_level} eq $usr{admin}) {
$adminht= <<HTML;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=admin;module=Wiki;id=$row[0]">Edit This Wiki</a> | <a href="$cfg{pageurl}/index.$cfg{ext}?op=admin;module=Wiki">Add New Wiki</a>
HTML
}
$wiki .= <<HTML;
<div style="padding: 3px 5px 3px 5px;" class="navtable"><b>$row[1]</b>$old_wiki<hr>
$descpt</div><hr width="95%">
$also_see
<div class="navtable"><center>$adminht Last Update: $row[3] By: <a href="$cfg{pageurl}/index.$cfg{ext}?op=op;view_profile;username=$row[4]">$row[4]</a></center></div>
HTML

theme::print_html($user_data{theme}, $wiki_name);
wiki_search();
print $wiki;
theme::print_html($user_data{theme}, $wiki_name, 1);
}
 else {
# Main Wiki Page
require DATE_TIME;
my $sth = qq(SELECT id, name, lastdate, lastauther FROM wiki_site ORDER BY RAND(NOW()) LIMIT 5;);
$sth = $dbh->prepare($sth);
$sth->execute;
my $ran_links = '';
while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
           $row[2] = DATE_TIME::format_date($row[2],11);
           $ran_links .= qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=view;module=Wiki;id=$row[0]" target="_parent">$row[1]</a><br>\n
<small><font color=DarkRed>Last Auther: <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$row[3]">$row[3]</a> - Date: $row[2]</font></small><hr>\n);
           }
}
$sth->finish;

$sth = qq(SELECT id, name, lastdate, lastauther FROM wiki_site ORDER BY lastdate DESC LIMIT 5;);
$sth = $dbh->prepare($sth);
$sth->execute;
my $new_links = '';
while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
           $row[2] = DATE_TIME::format_date($row[2],11);
           $new_links .= qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=view;module=Wiki;id=$row[0]" target="_parent">$row[1]</a><br>\n
<small><font color=DarkRed>Last Auther: <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$row[3]">$row[3]</a> - Date: $row[2]</font></small><hr>\n);
           }
}
$sth->finish;

$sth = qq(SELECT `id` , `uid` , `name` , `votes` FROM `wiki_user` WHERE `active` = '1' ;);
$sth = $dbh->prepare($sth);
$sth->execute;
my $user_publish = '';
while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
       my $admin_publish = '';
       $admin_publish = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=admin_replace;module=Wiki;id=$row[0]" onclick="javascript:return confirm('By Clicking ok. This article will replace and back-up the old article or Add the New Article. Please look over the Source Code so you know its secure.')">Admin Update Article</a> | ) if $user_data{sec_level} eq $usr{admin};
           $user_publish .= qq(Votes: $row[3] <a href="$cfg{pageurl}/index.$cfg{ext}?op=publish;module=Wiki;id=$row[0]" target="_parent">$row[2]</a><br>\n
<small><font color=DarkRed>$admin_publish Auther: <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$row[1]">$row[1]</a></font></small><hr>\n);
           }
}
$sth->finish;

 require theme;
 theme::print_header();
 theme::print_html($user_data{theme}, 'Wiki');
 wiki_search();
 print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" align="center" width="100%" class="navtable">
<tr valign="top">
<td width="50%" align="center"><b>Random Article</b><br>
<div style="padding: 3px 5px 3px 5px;" class="navtable"><div align="left">$ran_links</div></div></td>
<td width="50%" align="center"><b>New/Updated Article</b><br>
<div style="padding: 3px 5px 3px 5px;" class="navtable"><div align="left">$new_links</div></div></td>
</tr>
</table><br>
<table border="0" cellpadding="4" cellspacing="0" align="center" width="100%" class="navtable">
<tr valign="top">
<td width="50%" align="center"><b>Vote to Publish Article(s)</b><br>
<div style="padding: 3px 5px 3px 5px;" class="navtable"><div align="left">$user_publish</div></div></td>
<td width="50%" align="center">&nbsp;</td>
</tr>
</table>
HTML
my $admin = '';
if ($user_data{sec_level} eq $usr{admin}) {
     $admin = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=admin;module=Wiki">Add New Wiki</a> | );
}
if ($user_data{sec_level} ne $usr{anonuser}) {
print <<HTML;
<br><div style="padding: 3px 5px 3px 5px;" class="navtable">
<center>$admin<a href="$cfg{pageurl}/index.$cfg{ext}?op=user_view;module=Wiki">Your Wiki</a>
</center></div>
HTML
}
    theme::print_html($user_data{theme}, 'Wiki', 1);
 }
}

sub view_old {

my $id = $query->param('id') || '';

if ($id !~ m!^(\d+)$!i) {
     require error;
     error::user_error("$err{bad_input} - id");
     exit;
     }
$id = $dbh->quote($id);
require DATE_TIME;
my $sth = "SELECT * FROM `wiki_journal` WHERE `was_id` = $id ORDER BY `lastdate` DESC;";
$sth = $dbh->prepare($sth);
$sth->execute;
my $old_wiki = '';
while(my @row = $sth->fetchrow)  {
       $row[4] = DATE_TIME::format_date($row[4], 11);
       $old_wiki .= qq(<b>Date:</b> $row[4]<br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=view_old2;module=Wiki;id=$row[0]">$row[2]</a><hr>) if $row[0];
}
$sth->finish;

 require theme;
 theme::print_header();
 theme::print_html($user_data{theme}, 'Wiki History');
 wiki_search();
 print $old_wiki;
 theme::print_html($user_data{theme}, 'Wiki History', 1);
}

sub view_old2 {

my $id = $query->param('id') || '';

if ($id !~ m!^(\d+)$!i) {
     require error;
     error::user_error("$err{bad_input} - id");
     exit;
     }
$id = $dbh->quote($id);
#require UBBC;
require theme;
require DATE_TIME;
my $sth = "SELECT * FROM `wiki_journal` WHERE `id` = $id ORDER BY `lastdate` DESC;";
$sth = $dbh->prepare($sth);
$sth->execute;
my $wiki = '';
while(my @row = $sth->fetchrow)  {

# id, name, desc, lastdate, lastauther, also_see
#$row[1] = UBBC::do_ubbc($row[1]);
my $descpt = $row[3];
$descpt =~ s{\[code\](?s)(.+?)\[/code\]} {
        my $ret = '[code]' . $AUBBC_mod->script_escape($1) . '[/code]';
        $ret ? $ret : $1;
        }exigso;
$descpt =~ s{\[code=(.+?)\](?s)(.+?)\[/code\]} {
        my $ret = "[code=$1]" . $AUBBC_mod->script_escape($2) . '[/code]';
        $ret ? $ret : $2;
        }exigso;
$descpt =~ s{\[c\](?s)(.+?)\[\/c\]} {
        my $ret = '[c\]' . $AUBBC_mod->script_escape($1) . '[/c]';
        $ret ? $ret : $1;
        }exigso;
$descpt =~ s{\[cd\](?s)(.+?)\[/cd\]} {
        my $ret = '[cd]' . $AUBBC_mod->script_escape($1) . '[/cd]';
        $ret ? $ret : $1;
        }exigso;
$descpt =~ s{\[c=(.+?)\](?s)(.+?)\[\/c\]} {
        my $ret = "[c=$1\]" . $AUBBC_mod->script_escape($2) . '[/c]';
        $ret ? $ret : $2;
        }exigso;
$descpt =~ s{\[encode\]}{}gso;
$descpt =~ s{\[/encode\]}{}gso;
#$descpt = UBBC::do_ubbc($descpt);
#$descpt = UBBC::do_smileys($descpt);
$descpt = $AUBBC_mod->do_all_ubbc($descpt);
$descpt = theme::eval_theme_tags($descpt);
$row[4] = DATE_TIME::format_date($row[4],11);
my $also_see = $row[6];
if ($also_see) {
#$also_see = UBBC::do_ubbc($also_see);
#$also_see = UBBC::do_smileys($also_see);
$also_see =~ s{\[encode\]}{}gso;
$also_see =~ s{\[/encode\]}{}gso;
$also_see = $AUBBC_mod->do_all_ubbc($also_see);
$also_see = theme::eval_theme_tags($also_see);
$also_see = qq(<div style="padding: 3px 5px 3px 5px;" class="navtable"><b>Also See</b><br>$also_see</div><hr width="95%">);
}
my $adminht = '';
if ($user_data{sec_level} eq $usr{admin}) {
$adminht = <<HTML;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=admin;module=Wiki">Add New Wiki</a>
HTML
}
$row[2] = "[wiki://$row[2]]";
#$row[2] = UBBC::do_ubbc($row[2]);
$row[2] = $AUBBC_mod->do_all_ubbc($row[2]);
$wiki .= <<HTML;
<div style="padding: 3px 5px 3px 5px;" class="navtable"><b>$row[2] <- Click for New Version</b><hr>
$descpt</div><hr width="95%">
$also_see
<div class="navtable"><center>$adminht Old date: $row[4] By: <a href="$cfg{pageurl}/index.$cfg{ext}?op=op;view_profile;username=$row[5]">$row[5]</a></center></div>
HTML
}
$sth->finish;

 theme::print_header();
 theme::print_html($user_data{theme}, 'Wiki History');
 wiki_search();
 print $wiki;
 theme::print_html($user_data{theme}, 'Wiki History', 1);
}

sub admin {
# Check admin's
if($user_data{sec_level} ne $usr{admin}) {
require error;
error::user_error($err{auth_failure});
}
my $id = $query->param('id') || '';
my ($lid, $name, $info, $a_see) = ('','','','');
if ($id) {
$id = $dbh->quote($id);
my $sth = "SELECT * FROM wiki_site WHERE id=$id LIMIT 1;";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
 $lid = $row[0];
 $name = $row[1];
 $info = $row[2];
 $a_see = $row[5];
}
$sth->finish;
}

require theme;
theme::print_header();
theme::print_html($user_data{theme}, $nav{home});
my $wiki = '';
 if ($user_data{sec_level} eq $usr{admin}) {
$wiki .= <<HTML;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=admin;module=Wiki;id=$id">Edit This Wiki</a> | <a href="$cfg{pageurl}/index.$cfg{ext}?op=admin;module=Wiki">Add New Wiki</a><hr>
HTML
}
wiki_search();
 print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Wiki Edit</p>
.....<br>
$wiki
</td>
</tr></table>
<form method="post" action="">
  <input type="hidden" name="id" value="$lid">
  <input type="hidden" name="op" value="wiki_edit">
  <input type="hidden" name="module" value="Wiki">
  <table width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Name</b> Only allowed a-z A-Z 0-9 : -  _<br>
<input type="text" name="name" value="$name">
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td> &nbsp;<b>Information</b> Only allowed HTML & UBBC<br>
<textarea name="info" cols="55" rows="10">$info</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Also See</b> Only allowed HTML & UBBC<br>
<textarea name="also_see" cols="55" rows="10">$a_see</textarea>
      </td>
    </tr>
  </table>
  <input type="submit" name="Submit" value="Submit">
</form>
HTML
theme::print_html($user_data{theme}, $nav{home}, 1);
}

sub wiki_edit {
if($user_data{sec_level} ne $usr{admin}) {
require error;
error::user_error($err{auth_failure});
exit(0);
}
my $id = $query->param('id') || '';
my $name = $query->param('name') || '';
my $info = $query->param('info') || '';
my $also_see = $query->param('also_see') || '';
if ($id && $id !~ m!^([0-9]+)$!i) {
     require error;
     error::user_error($err{bad_input});
     }
if ($name !~ m!^([a-zA-Z0-9\:\-\s\_]+)$!i) {
     require error;
     error::user_error($err{bad_input});
     }
#$id = $dbh->quote($id);
$name = $dbh->quote($name);
$info = $dbh->quote($info);
$also_see = $dbh->quote($also_see);
my $date = time;
require SQLEdit;
$info =~ s{\[encode\](?s)(.+?)\[\/encode\]} {
        my $ret = '[encode]' . $AUBBC_mod->script_escape($1) . '[/encode]';
        $ret ? $ret : $1;
        }exigso;
$also_see =~ s{\[encode\](?s)(.+?)\[\/encode\]} {
        my $ret = '[encode\]' . $AUBBC_mod->script_escape($1) . '[/encode]';
        $ret ? $ret : $1;
        }exigso;
if ($id) {

my $sth = "SELECT * FROM wiki_site WHERE id='$id' LIMIT 1;";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
if ($row[0]) {
         $row[1] = $dbh->quote($row[1]);
         $row[2] = $dbh->quote($row[2]);
         $row[5] = $dbh->quote($row[5]);
           my $string = qq(INSERT INTO `wiki_journal` VALUES ( NULL , '$row[0]' , $row[1] , $row[2] , '$row[3]', '$row[4]' , $row[5] ););

           SQLEdit::SQLAddEditDelete($string);
           }
}
$sth->finish;
     # id, name, desc, lastdate, lastauther, also_see
           my $string = qq(UPDATE `wiki_site` SET `name` = $name,
`desc` = $info, `lastdate` = '$date', `lastauther` = '$user_data{uid}',
`also_see` = $also_see WHERE `id` = '$id' LIMIT 1 ;);

           SQLEdit::SQLAddEditDelete($string);

}
 else {
           my $string = qq(INSERT INTO `wiki_site` VALUES ( NULL , $name , $info , '$date', '$user_data{uid}' , $also_see ););

           SQLEdit::SQLAddEditDelete($string);
 }
            $dbh->disconnect();
                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin;module=Wiki;id=' . $id
                    );

}
sub user_view {
if($user_data{sec_level} eq $usr{anonuser}) {
require error;
error::user_error($err{auth_failure});
exit;
}
#my $id = $query->param('id') || '';
my $info = '';
#if ($id) {
#$id = $dbh->quote($id);
my $sth = "SELECT `id`, `name` FROM `wiki_user` WHERE `uid` = '$user_data{uid}' AND `active` = '0'";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
 $info .= qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=user;module=Wiki;id=$row[0]">$row[1]</a> | <a href="$cfg{pageurl}/index.$cfg{ext}?op=publisher;module=Wiki;id=$row[0]" onclick="javascript:return confirm('You will no longer have control over this article so it can be voted on as a future article.')">Publish Now</a><hr>);
}
$sth->finish;
#}

$info = 'No Articles' if $info eq '';
require theme;
theme::print_header();
theme::print_html($user_data{theme}, 'User Wiki');

wiki_search();

 print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Users Wiki <a href="$cfg{pageurl}/index.$cfg{ext}?op=user;module=Wiki">Develop an Article</a></p>
$info
</td>
</tr></table>
HTML

theme::print_html($user_data{theme}, 'User Wiki', 1);

}
sub user {
if($user_data{sec_level} eq $usr{anonuser}) {
require error;
error::user_error($err{auth_failure});
exit;
}
my $id = $query->param('id') || '';
my ($lid, $name, $info, $a_see) = ('','','','');
if ($id) {
if ($id !~ m!^(\d+)$!i) {
     require error;
     error::user_error("$err{bad_input} - id");
     exit;
     }
$id = $dbh->quote($id);
my $sth = "SELECT `id`, `name`, `desc`, `also_see` FROM `wiki_user` WHERE `id` = $id AND `uid` = '$user_data{uid}' AND `active` = '0' LIMIT 1;";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
 $lid = $row[0];
 $name = $row[1];
 $info = $row[2];
 $a_see = $row[3];
}
$sth->finish;
}

require theme;
theme::print_header();
theme::print_html($user_data{theme}, $nav{home});

wiki_search();
 print <<HTML;
<table border="0" cellpadding="4" cellspacing="0" width="95%" class="navtable">
<tr>
<td><p class="texttitle">Users Wiki Edit</p>
Design your own Article, After your doen you can Publish it.<br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=user_view;module=Wiki">View Your Wiki</a> | <a href="$cfg{pageurl}/index.$cfg{ext}?op=user;module=Wiki">Add New User Wiki</a><hr>
</td>
</tr></table>
<form method="post" action="">
  <input type="hidden" name="id" value="$lid">
  <input type="hidden" name="op" value="wiki_useredit">
  <input type="hidden" name="module" value="Wiki">
  <table width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Name</b> Only allowed a-z A-Z 0-9 : -  _<br>
<input type="text" name="name" value="$name">
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td> &nbsp;<b>Information</b> Only allowed HTML & UBBC<br>
<textarea name="info" cols="55" rows="10">$info</textarea>
      </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp; <b>Also See</b> Only allowed HTML & UBBC<br>
<textarea name="also_see" cols="55" rows="10">$a_see</textarea>
      </td>
    </tr>
  </table>
  <input type="submit" name="Submit" value="Submit">
</form>
HTML
theme::print_html($user_data{theme}, $nav{home}, 1);
}

sub wiki_useredit {
if($user_data{sec_level} eq $usr{anonuser}) {
require error;
error::user_error($err{auth_failure});
exit;
}
my $id = $query->param('id') || '';
my $name = $query->param('name') || '';
my $info = $query->param('info') || '';
my $also_see = $query->param('also_see') || '';
if ($id && $id !~ m!^([0-9]+)$!i) {
     require error;
     error::user_error($err{bad_input});
     }
if ($name !~ m!^([a-zA-Z0-9\:\-\s\_]+)$!i) {
     require error;
     error::user_error("$err{bad_input} - name");
     }
#$id = $dbh->quote($id);
$name = $dbh->quote($name);
$info = $dbh->quote($info);
$also_see = $dbh->quote($also_see);
#my $date = time;
require SQLEdit;
if ($id) {

# my $sth = "SELECT * FROM wiki_site WHERE id='$id' LIMIT 1;";
# $sth = $dbh->prepare($sth);
# $sth->execute;
# while(my @row = $sth->fetchrow)  {
# if ($row[0]) {
#          $row[1] = $dbh->quote($row[1]);
#          $row[2] = $dbh->quote($row[2]);
#          $row[5] = $dbh->quote($row[5]);
#            my $string = qq(INSERT INTO `wiki_journal` VALUES ( NULL , '$row[0]' , $row[1] , $row[2] , '$row[3]', '$row[4]' , $row[5] ););
#
#            SQLEdit::SQLAddEditDelete($string);
#            }
# }
# $sth->finish;
     # id, uid, name, desc, also_see, active, votes
           my $string = qq(UPDATE `wiki_user` SET `name` = $name,
`desc` = $info, `also_see` = $also_see WHERE `id` = '$id' AND `uid`='$user_data{uid}' AND `active` = '0' LIMIT 1 ;);

           SQLEdit::SQLAddEditDelete($string);

}
 else {
           my $string = qq(INSERT INTO `wiki_user` VALUES ( NULL , '$user_data{uid}', $name , $info , $also_see , '0' , '0'););

           SQLEdit::SQLAddEditDelete($string);
 }
            $dbh->disconnect();
                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=user_view;module=Wiki'
                    );

}

sub publisher {
if($user_data{sec_level} eq $usr{anonuser}) {
require error;
error::user_error($err{auth_failure});
exit;
}
my $id = $query->param('id') || '';
if ($id !~ m!^(\d+)$!i) {
     require error;
     error::user_error("$err{bad_input} - id");
     exit;
     }
     $id = $dbh->quote($id);
           my $string = qq(UPDATE `wiki_user` SET `active` = '1' WHERE `id` = $id AND `uid`='$user_data{uid}' LIMIT 1 ;);

           SQLEdit::SQLAddEditDelete($string);

            $dbh->disconnect();
                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=user_view;module=Wiki'
                    );

}

sub publish {

my $id = $query->param('id') || '';
my ($lid, $name, $info, $a_see, $votes) = ('','','','');

if ($id !~ m!^(\d+)$!i) {
     require error;
     error::user_error("$err{bad_input} - id");
     exit;
     }
#$id = $dbh->quote($id);
my $sth = "SELECT `id`, `name`, `desc`, `also_see` , `votes` FROM `wiki_user` WHERE `id` = '$id' AND `active` = '1' LIMIT 1;";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
 $lid = $row[0];
 $name = $row[1];
 $info = $row[2];
 $a_see = $row[3];
 $votes = $row[4];
}
$sth->finish;
#require HTML_TEXT;
#$info = HTML_TEXT::html_escape($info);
#$a_see = HTML_TEXT::html_escape($a_see);
$info = $AUBBC_mod->script_escape($info);
$a_see = $AUBBC_mod->script_escape($a_see);

require theme;
theme::print_header();
theme::print_html($user_data{theme}, 'Published Articles');
wiki_search();
print <<HTML;
<div style="padding: 3px 5px 3px 5px;" class="navtable"><b>$name</b><br>
$info</div><hr width="95%">
<div style="padding: 3px 5px 3px 5px;" class="navtable"><b>Also See</b><br>$a_see</div><hr width="95%">
HTML

print qq(<div style="padding: 3px 5px 3px 5px;" class="navtable"><b>Add Your Vote</b> $votes - <a href="$cfg{pageurl}/index.$cfg{ext}?op=vote_publish;module=Wiki;id=$id">Looks Good</a></div><hr width="95%">) if $user_data{sec_level} ne $usr{anonuser};

theme::print_html($user_data{theme}, 'Published Articles', 1);
}

sub vote_publish {
if($user_data{sec_level} eq $usr{anonuser}) {
require error;
error::user_error($err{auth_failure});
exit;
}
my $id = $query->param('id') || '';
if ($id !~ m!^(\d+)$!i) {
     require error;
     error::user_error("$err{bad_input} - id");
     exit;
     }
     $id = $dbh->quote($id);
           my $string = qq(UPDATE `wiki_user` SET `votes` =votes + 1 WHERE `id` = $id LIMIT 1 ;);

           SQLEdit::SQLAddEditDelete($string);

            $dbh->disconnect();
                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view;module=Wiki'
                    );

}
# This is being replaced with sub admin_replace
# becase admin_replace is made to do both "update or add new"
sub admin_publish { # This is Not used
if($user_data{sec_level} ne $usr{admin}) {
require error;
error::user_error($err{auth_failure});
exit;
}
my $id = $query->param('id') || '';

if ($id !~ m!^(\d+)$!i) {
     require error;
     error::user_error("$err{bad_input} - id");
     exit;
     }
     $id = $dbh->quote($id);
my ($lid, $uid_in, $name, $info, $a_see, $votes) = ('','','','','');
my $sth = "SELECT `id`, `uid`, `name`, `desc`, `also_see` FROM `wiki_user` WHERE `id` = $id AND `active` = '1' LIMIT 1;";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
 $lid = $row[0];
 $uid_in = $row[1];
 $name = $row[2];
 $info = $row[3];
 $a_see = $row[4];
}
$sth->finish;

if (!$lid) {
     require error;
     error::user_error("$err{bad_input} - id");
     exit;
     }

$name = $dbh->quote($name);
$info = $dbh->quote($info);
$a_see = $dbh->quote($a_see);
#$id = $dbh->quote($id);
my $date = time;
           my $string = qq(INSERT INTO `wiki_site` VALUES ( NULL , $name , $info , '$date' , '$uid_in' , $a_see ););

           SQLEdit::SQLAddEditDelete($string);

           $string = qq(DELETE FROM `wiki_user` WHERE `id` = '$lid' LIMIT 1 ;);

           SQLEdit::SQLAddEditDelete($string);

                $dbh->disconnect();
                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view;module=Wiki'
                    );

}

sub admin_replace {

if($user_data{sec_level} ne $usr{admin}) {
require error;
error::user_error($err{auth_failure});
exit;
}
my $id = $query->param('id') || '';

if ($id !~ m!^(\d+)$!i) {
     require error;
     error::user_error("$err{bad_input} - id");
     exit;
     }
     $id = $dbh->quote($id);
my ($lid, $uid_in, $name, $info, $a_see, $update_wiki, $string) = ('','','','','','','');

my $sth = "SELECT `id`, `uid`, `name`, `desc`, `also_see` FROM `wiki_user` WHERE `id` = $id AND `active` = '1' LIMIT 1;";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
 $lid = $row[0];
 $uid_in = $row[1];
 $name = $row[2];
 $info = $row[3];
 $a_see = $row[4];
}
$sth->finish;

if (!$lid) {
     require error;
     error::user_error("$err{bad_input} - id");
     exit;
     }
# Find one to update first
$sth = "SELECT * FROM `wiki_site` WHERE `name` REGEXP '^$name\$' LIMIT 1;";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
if ($row[0]) {
 $update_wiki = $row[0]; # Fag for Update
 $row[1] = $dbh->quote($row[1]);
 $row[2] = $dbh->quote($row[2]);
 $row[5] = $dbh->quote($row[5]);

 # Back-up old article
 $string = qq(INSERT INTO `wiki_journal` VALUES ( NULL , '$row[0]' , $row[1] , $row[2] , '$row[3]', '$row[4]' , $row[5] ););

            SQLEdit::SQLAddEditDelete($string);
            }
}
$sth->finish;

$name = $dbh->quote($name);
$info = $dbh->quote($info);
$a_see = $dbh->quote($a_see);
#$id = $dbh->quote($id);
my $date = time;

    # Add a New Article if there was no other found
    if (!$update_wiki) {
           $string = qq(INSERT INTO `wiki_site` VALUES ( NULL , $name , $info , '$date' , '$uid_in' , $a_see ););

           SQLEdit::SQLAddEditDelete($string);
      }
       else {
       # Update Article
       $string = qq(UPDATE `wiki_site` SET `name` = $name,
`desc` = $info, `lastdate` = '$date', `lastauther` = '$user_data{uid}',
`also_see` = $a_see WHERE `id` = '$update_wiki' LIMIT 1 ;);

           SQLEdit::SQLAddEditDelete($string);
       }
           # delete it from user table
           $string = qq(DELETE FROM `wiki_user` WHERE `id` = '$lid' LIMIT 1 ;);

           SQLEdit::SQLAddEditDelete($string);

                $dbh->disconnect();
                # Redirect to user_actions page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view;module=Wiki'
                    );

}

1;
