package FAQ_Admin;
# Simple FAQ with user status, but not used at this time
use strict;
use vars qw(%user_action $dbh %cfg %user_data %usr $query %err %faq_lg);
use exporter;
# Define possible user actions.
%user_action = (
 faq => 1,
 faq_edit => 1,
 faq_edit2 => 1,
 faq_delete => 1,
 add_form => 1,
 add_faq => 1
 );

# Check admin's
if($user_data{sec_level} ne $usr{admin}) {
require error;
error::user_error($err{auth_failure});
}

my $title = $query->param('title');
my $message = $query->param('message');
my $html = $query->param('html') || 2;

my $id   = $query->param('id');
if ($id && $id !~ m!^([0-9]+)$!i) {
require error;
error::user_error($err{bad_input});
}

# Load FAQ lang. file
require "$cfg{modulesdir}/FAQ/lang.pl";

my $faq_add = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=add_form;module=FAQ_Admin">$faq_lg{add}</a>);
sub faq {
# table has user status
my $data;
my($query1) = "SELECT * FROM faq";
my $sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't connect to database!\n");
while(my @row = $sth->fetchrow)  {
      if($row[0]){
      $data .= qq($faq_lg{q} <a href="$cfg{pageurl}/index.$cfg{ext}?op=faq_edit;module=FAQ_Admin;id=$row[0]">$row[1]</a><br>);
      }
}
$sth->finish;

if (!$data) {
require error;
error::user_error($err{bad_input});
}

require theme;
theme::print_header();
theme::print_html($user_data{theme}, $faq_lg{admin});
print <<HTML;
$faq_add
<br>
<table class="bg5" border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td width="100%" class="cathdl">&nbsp;$faq_lg{admin}</td>
</tr>
</table>
<table class="menuback" border="0" cellpadding="1" cellspacing="0" width="100%">
<tr>
<td><table border="0" cellpadding="3" cellspacing="0">
$data
</table></td>
</tr>
</table><br>
HTML
theme::print_html($user_data{theme}, $faq_lg{admin}, 1);
}
sub faq_edit {
my $data;
my($query1) = "SELECT * FROM faq WHERE id='$id'";
my $sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't connect to database!\n");
while(my @row = $sth->fetchrow)  {
if($row[0]){
$data = qq(<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=faq_delete;module=FAQ_Admin;id=$row[0]" onclick="javascript:return confirm('$faq_lg{del2}')">$faq_lg{del}</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;$faq_add</center>
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="faq_edit2">
<input type="hidden" name="module" value="FAQ_Admin">
<input type="hidden" name="id" value="$id">
<p>$faq_lg{q2}
<input type="text" name="title" size="50" value="$row[1]">
<br>$faq_lg{a2}<br>
<textarea name="message" cols="60" rows="20">$row[2]</textarea>
</p>
<input type="radio" name="html" value="1" checked>
<b>Allow HTML</b><br>
<input type="radio" name="html" value="2">
<b>Use UBBC</b><br>
<input type="radio" name="html" value="3">
<b>Use Text Only</b>
<p>
<input type="submit" name="Submit" value="$faq_lg{save}">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="reset" name="Reset" value="$faq_lg{reset}">
</p>
</form>);
}

}
$sth->finish;
my $data2;
$query1 = "SELECT * FROM faq";
$sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't connect to database!\n");
while(my @row = $sth->fetchrow)  {
if($row[0]){
$data2 .= qq($faq_lg{q} <a href="$cfg{pageurl}/index.$cfg{ext}?op=faq_edit;module=FAQ_Admin;id=$row[0]">$row[1]</a><br>);
}

}
$sth->finish;
require theme;
theme::print_header();
theme::print_html($user_data{theme}, $faq_lg{admin2});
print <<HTML;
<table width="100%" border="0" cellspacing="0" cellpadding="4" class="navtable">
<tr>
<td>$data</td>
</tr>
</table><br>
<table class="bg5" border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td width="100%" class="cathdl">&nbsp;$faq_lg{admin2}</td>
</tr>
</table>
<table class="menuback" border="0" cellpadding="1" cellspacing="0" width="100%">
<tr>
<td><table border="0" cellpadding="3" cellspacing="0">
$data2
</table></td>
</tr>
</table><br>
HTML
theme::print_html($user_data{theme}, $faq_lg{admin2}, 1);
}

sub faq_edit2 {
if ($title && $message) {
if ($html eq '1') {
# should check how safe it realy is, but this is an admin area anyway.
$title =~ s{'}{&#39;}gso; # SQL Safer
$title =~ s{\\}{&#92;}gso; # need this!
$message =~ s{'}{&#39;}gso; # SQL Safer
$message =~ s{\\}{&#92;}gso; # need this!
}
elsif($html eq '3') {
require HTML_TEXT;
$title = HTML_TEXT::html_escape($title);
$message = HTML_TEXT::html_escape($message);
}
else {
require HTML_TEXT;
$title = HTML_TEXT::html_escape($title);
$message = HTML_TEXT::html_escape($message);
require UBBC;
$title = UBBC::do_ubbc($title);
$message = UBBC::do_ubbc($message);
}
my $sql = qq(UPDATE `faq` SET `question` = '$title',
`answer` = '$message',
`sec_level` = NULL WHERE `id` =$id LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
}
$dbh->disconnect();
                # Redirect to the welcome page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=faq;module=FAQ_Admin'
                    );
                    exit;
}

sub faq_delete {

my $sql = qq(DELETE FROM `faq` WHERE `id` = $id LIMIT 1;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
$dbh->disconnect();
                # Redirect to the welcome page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=faq;module=FAQ_Admin'
                    );
                    exit;
}
sub add_form {
require theme;
theme::print_header();
theme::print_html($user_data{theme}, $faq_lg{admin});
print <<HTML;
<div align="left">
<form name="form1" method="post" action="">
<input type="hidden" name="op" value="add_faq">
<input type="hidden" name="module" value="FAQ_Admin">
<p>$faq_lg{q2}
<input type="text" name="title" size="50" value="">
<br>$faq_lg{a2}<br>
<textarea name="message" cols="48" rows="20"></textarea>
</p>
<input type="radio" name="html" value="1" checked>
<b>Allow \HTML</b><br>
<input type="radio" name="html" value="2">
<b>Use UBBC</b><br>
<input type="radio" name="html" value="3">
<b>Use Text Only</b>
<p>
<input type="submit" name="Submit" value="$faq_lg{add}">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<input type="reset" name="Reset" value="$faq_lg{reset}">
</p>
</form></div>
HTML

theme::print_html($user_data{theme}, $faq_lg{admin}, 1);

}
sub add_faq {
if ($title && $message) {
if ($html eq '1') {
# should check how safe it realy is, but this is an admin area anyway.
$title =~ s{'}{&#39;}gso; # SQL Safer
$title =~ s{\\}{&#92;}gso; # need this!
$message =~ s{'}{&#39;}gso; # SQL Safer
$message =~ s{\\}{&#92;}gso; # need this!
}
elsif($html eq '3') {
require HTML_TEXT;
$title = HTML_TEXT::html_escape($title);
$message = HTML_TEXT::html_escape($message);
}
else {
require HTML_TEXT;
$title = HTML_TEXT::html_escape($title);
$message = HTML_TEXT::html_escape($message);
require UBBC;
$title = UBBC::do_ubbc($title);
$message = UBBC::do_ubbc($message);
}
my $sql = qq(INSERT INTO `faq` ( `id` , `question` , `answer` , `sec_level` )
VALUES (
NULL , '$title', '$message', NULL
););
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
}
$dbh->disconnect();
                # Redirect to the welcome page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=faq;module=FAQ_Admin'
                    );
                    exit;
}
1;