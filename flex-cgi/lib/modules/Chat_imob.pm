package Chat_imob;
use strict;
# Assign global variables.
use vars qw(
    %user_action $dbh %cfg %user_data $query
    %err %usr
    );
use exporter;

# Define possible user actions.
%user_action = (
 b_help => 1,
 b_cmd => 1,
 b_add => 1,
 b_add2 => 1
 );

# inputs
my $message = $query->param('message');
my $regex = $query->param('regex');
my $id = $query->param('id'); # allow numbers

sub admin_menu {
    if($user_data{sec_level} eq $usr{admin}) {
    print <<HTML;
<table width="95%" border="1" cellspacing="0" cellpadding="4">
  <tr align="center">
    <td valign="top"><b>Admin Menu</b></td>
    <td valign="top">&nbsp;</td>
  </tr>
  <tr>
    <td valign="top"><a href="$cfg{pageurl}/index.$cfg{ext}?op=b_add;module=Chat_imob">Add Imob Regex</a><br>
    <a href="$cfg{pageurl}/index.$cfg{ext}?op=b_cmd;module=Chat_imob">CMD Imob Messages</a><br>
    <a href="$cfg{pageurl}/index.$cfg{ext}?op=b_help;module=Chat_imob">Imob Help</a><br></td>
    <td valign="top">&nbsp;</td>
  </tr>
</table>
HTML
    }
}

sub b_help {
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "IMOB - Help");
        admin_menu();
        print <<HTML;
IMOB - Help Page<br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=b_cmd;module=Chat_imob">CMD Imob Messages</a>
<table width="100%" border="0" cellspacing="2" cellpadding="4" class="navtable">
<tr>
<td>
<blockquote>
IMOB stands for <b>"Intelligent Message output bot"</b><br>
A Highly Customizable Chat Bot made for help & support.<br>
This Bots backend can be added to if you have admin status.
</blockquote>
</td>
</tr>
</table>
HTML
        theme::print_html($user_data{theme}, "IMOB - Help", 1);
}

sub b_cmd {
 my $sth = "SELECT * FROM chat_bot_imob";
$sth = $dbh->prepare($sth);
$sth->execute;
my $talk = '<br>';
my $start = '';
while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
       $start = $row[2];
       #$start =~ s/\^//;
      $talk .= <<HTML;
<a href="$cfg{pageurl}/index.$cfg{ext}?op=b_add;module=Chat_imob;id=$row[0]">ID $row[0]</a> - <b>$start</b> - $row[1]<hr>
HTML
      }
}
$sth->finish;
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "IMOB - CMD");
        admin_menu();
        print $talk;
        theme::print_html($user_data{theme}, "IMOB - CMD", 1);
}
sub b_add {
if($user_data{sec_level} eq $usr{admin}) {

my ($rex, $msg) = ('','');
if ($id) {
 my $sth = "SELECT * FROM chat_bot_imob WHERE id='$id'";
$sth = $dbh->prepare($sth);
$sth->execute;

while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
       $rex = $row[2];
       $id = $row[0];
       $msg = $row[1];
      }
}
$sth->finish;
}
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "IMOB - Add");
        admin_menu();
    print <<HTML;
<form name="form2" method="post" action="$cfg{pageurl}/index.$cfg{ext}">
  <table width="48%" border="1" cellspacing="0" cellpadding="0" align="center">
    <tr>
      <td width="18%">&nbsp;&nbsp;Regex:</td>
    <td width="82%">
        <input type="text" name="regex" size="60" value="$rex">
    </td>
  </tr>
  <tr>
    <td width="18%">&nbsp;&nbsp;Message: </td>
    <td width="82%">
        <textarea name="message" cols="60" rows="10">$msg</textarea>
    </td>
  </tr>
  <tr>
    <td width="18%">&nbsp;</td>
    <td width="82%">
        <input type="hidden" name="op" value="b_add2">
        <input type="hidden" name="module" value="Chat_imob">
        <input type="hidden" name="id" value="$id">
        <input type="submit" name="Submit" value="Add IMOB Message">
    </td>
  </tr>
</table>
</form>
HTML
theme::print_html($user_data{theme}, "IMOB - Add", 1);
}
 else {
       print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=b_cmd;module=Chat_imob');
 }
}

sub b_add2 {
    if($user_data{sec_level} eq $usr{admin}) {
    if ($id) {
             require SQLEdit;
             $message =~ s{'}{&#39;}gso;
             $message =~ s{\\}{\\\\}gso;
             $regex =~ s{'}{&#39;}gso;
             $regex =~ s{\\}{\\\\}gso;
             $message = qq(UPDATE `chat_bot_imob` SET `message` = '$message',
`regex` = '$regex',
`sec_level` = NULL,
`active` = '1' WHERE `id` = '$id' LIMIT 1 ;);
             SQLEdit::SQLAddEditDelete($message);
    }
     else {
             require SQLEdit;
             $message =~ s{'}{&#39;}gso;
             $message =~ s{\\}{\\\\}gso;
             $regex =~ s{'}{&#39;}gso;
             $regex =~ s{\\}{\\\\}gso;
             $message = qq(INSERT INTO `chat_bot_imob` ( `id` , `message` , `regex` , `sec_level` , `active` )
VALUES (
NULL , '$message', '$regex', NULL , '1'
););
             SQLEdit::SQLAddEditDelete($message);
 }
             print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=b_cmd;module=Chat_imob');
 }
 else {
       print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=b_cmd;module=Chat_imob');
 }
}
1;