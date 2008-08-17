package Chat;
# Advanced Perl & Javascript Chat By: N.K.A.
# last edits: 01-11-2008
# - Now using Time::HiRes perl module to reduce message size.
# - javascript edited to reflect Time::HiRes function
#
# Note: Needs more testing and security checks.
# Need IM window UBBC tags and more design
#
# 10/27/2007
# - Added a CSS file
# - Fix IE refresh and IM window pop-up
#
# 10/26/2007 - New Edits fixxed a JS bug in the log-off button
# and cleaned up a lot of the code making it smaller, faster
# get_member_room is now the main check to see if member is
# in a chat room, old sub check_member is nolonger used.
#
# Member count is not made yet but there is a collum in the chat rooms table
# Or it can count members from the chatroom member list
use strict;
use vars qw(
    %user_action $dbh %cfg
    %user_data %usr
    $query %btn %msg
    $VERSION %err $AUBBC_mod
    );
use exporter;
# Starting to use use Time::HiRes qw( gettimeofday ); to get milliseconds
# so the chat can be better
use Time::HiRes qw( gettimeofday );
# ($date, $microseconds) = gettimeofday;
my ($date, $microseconds) = ( 0 , 0 );

# Define possible user actions.
%user_action = (
 enter_chat  => 1,
 chat_frame  => 1,
 ctmsg       => 1,
 send_win    => 1,
 refresh_win => 1,
 im_frame    => 1,
 chat_im     => 1,
 send_im     => 1,
 command_win => 1,
 flashwin    => 1,
 flashmem    => 1,
 ); # Add in Commands for andmin and user. Like IRC chat Commands

BEGIN {
       if ($user_data{uid} eq $usr{anonuser}) {
       # Redirect to the register page.
       print $query->redirect(-location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=register');
       exit;
       }
}

# Chat Settings - Need to add in DB
$AUBBC_mod->settings( href_target => 1, script_escape => 0, );
#$cfg{hreftarget} = 1;
#$cfg{icon_image} = 1;
my $refresh_time = 8;
my $message_time = 2000;
my $frame_check = <<"JS";
function FrameRedirect() { top.NoLocation="$cfg{pageurl}/index.$cfg{ext}?op=enter_chat;module=Chat"; }
if (top.frames.length==0){ FrameRedirect(); }
JS

my $room   = $query->param('room');
#my $time   = $query->param('time');
my $message   = $query->param('message');
$message = $AUBBC_mod->script_escape($message);

my $username   = $query->param('username');
#my $chat_message = $query->param('chat_message');

require filters;
require error;
if ($room) {
     $room = filters::untaint2($room);
     error::user_error($err{bad_input}) if(!$room);
}
if ($username) {
     $username = filters::untaint2($username);
     error::user_error($err{bad_input}) if(!$username);
}

# ---------------------------------------------------------------------
# Display chat login page.
# ---------------------------------------------------------------------
sub enter_chat {
# Get all available channels.
my $channels = qq(<select name="room" size="1">\n);
my($query1) = "SELECT `room_name`, `usr_count` FROM `chat_rooms` WHERE `active` = '1'";
my $sth = $dbh->prepare($query1);
$sth->execute;
my $i = 0;
while(my @row = $sth->fetchrow)  {
if($row[0]){
if (!$row[1]) { $row[1] = 0; }
if (!$i) { $channels .= qq(<option selected value="$row[0]">$row[0] ($row[1])</option>\n); }
elsif ($row[0] ne 'IM') { $channels .= qq(<option value="$row[0]">$row[0] ($row[1])</option>\n); }
$i = 1;
}

}
$sth->finish;
$channels .= "</select>";

        #print $query->header();
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, "Chat");

        print <<HTML;
<table>
<td>
<script language="javascript" type="text/javascript">
<!--
function LogIn() {
var MyWindow;
var MyUrl;
MyUrl = '$cfg{pageurl}/index.$cfg{ext}?op=chat_frame;module=Chat;room=' + escape(document.login.room.value);
MyWindow = window.open(MyUrl, '$cfg{pagename}', 'width=700,height=600,status=no,toolbar=no,menubar=no,location=no');
}
// -->
</script>
<form onsubmit="javascript:{return false;}" name="login">
You are going to enter the Chat with the following nickname:<br>
<input type="hidden" name="uid" value="$user_data{uid}">
<input type="text" size="20" value="$user_data{uid}" disabled><br>
$channels
<br>
<input type="button" value="$btn{login}" onclick="javascript:LogIn();"><br>
<a href="$cfg{imagesurl}/chat.swf" target="_blank">Flash Chat of Lobby</a>
</center>
</form>
</td>
</tr>
</table>
HTML

        theme::print_html($user_data{theme}, "Chat", 1);
}
# ---------------------------------------------------------------------
# Generate the frameset.
# ---------------------------------------------------------------------
sub chat_frame {
# Get the current date.
#require DATE_TIME;
#my $date = DATE_TIME::get_date();
($date, $microseconds) = gettimeofday;
# Login user here add login checks for the other sub's
if (!$room) {
    enter_chat();
    exit;
    }
else {
my $add = 1;
my $change_room = '';
my $in_room = '';

# check room
my $ok = check_rooms($room);
if (!$ok) {
    enter_chat();
    exit;
    }

# Get member room
$in_room = get_member_room($user_data{uid});

if ($in_room) {
 if ($in_room ne $room) {
  $change_room = $in_room;
  $in_room = '';
  $add = 0;
 }
  else {
   $add = 0;
  }
}

# load sql editer
require SQLEdit;  # $date, $microseconds
# In Room
if ($in_room && !$add) {
SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$in_room', '[message]', '$date', '$ENV{'REMOTE_ADDR'}', '$user_data{uid} - You are in this room.', '$microseconds');");
} elsif ($change_room && !$add) {
SQLEdit::SQLAddEditDelete("UPDATE `chat_mem_lists` SET `room_name` = '$room', `date` = '$date:$microseconds' WHERE `uid` ='$user_data{uid}' LIMIT 1 ;");
SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$change_room', '[message2]', '$date', '$ENV{'REMOTE_ADDR'}', 'Member $user_data{uid} has just left this room', '$microseconds');");
SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '[message2]', '$date', '$ENV{'REMOTE_ADDR'}', 'Member $user_data{uid} joins this room', '$microseconds');");
} elsif ($add == 1) {
SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '[message2]', '$date', '$ENV{'REMOTE_ADDR'}', 'Member $user_data{uid} joins this room', '$microseconds');");
SQLEdit::SQLAddEditDelete("INSERT INTO `chat_mem_lists` VALUES (NULL , '$room', '$user_data{uid}', '$date:$microseconds');");
}

        print $query->header();
        print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN">

<html>

<head>

<meta http-equiv="Content-Type" content="text/html; charset=$cfg{codepage}">
<meta name="Generator" content="Flex $VERSION">
<title>$cfg{pagename} Chat</title>

</head>

<frameset rows="*,180">
<frameset cols="*,120">
<frame name="chatwin" scrolling="auto" noresize src="$cfg{pageurl}/index.$cfg{ext}?op=ctmsg;module=Chat#bottum">
<frame name="members" scrolling="yes" noresize src="">
</frameset>
<frameset rows="*,1" frameborder="NO" border="0" framespacing="0" cols="*">
<frame name="sendwin" target="bottomFrame" scrolling="no" noresize src="$cfg{pageurl}/index.$cfg{ext}?op=send_win;module=Chat;room=$room" marginwidth="5" marginheight="5">
<frame name="bottomFrame" scrolling="NO" noresize src="$cfg{pageurl}/index.$cfg{ext}?op=refresh_win;module=Chat;room=$room;time=$date#bottum">
</frameset>
<noframes>
<body>
<p>This page uses frames, but your browser doesn't support them.
</body>
</noframes>
</frameset>
HTML
        print $query->end_html();
        $dbh->disconnect();
        exit;
        }
}
sub ctmsg {
print "Content-type: text/html\n\n";

        print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Chat Message</title>
<script language="JavaScript1.2">
var currentpos=0,activescroll=1;
var theloopper = setInterval("scrollwindow()",10);

function scrollwindow(){
if (document.all)
currentpos=document.body.scrollTop+5;
else
currentpos=window.pageYOffset+5;
window.scroll(0,currentpos);
}
function startit(){
theloopper;
}

window.onload=startit;

function MoveHandler() {
        if(activescroll==1) {
                activescroll=2;
                clearInterval(theloopper);
                } else {
                        activescroll=1;
                        theloopper = setInterval("scrollwindow()",100);
                        }
}

</script>
</head>
<body>
<div id="msg" name="msg"> </div>
<a name="bottum"></a>
</body>
</html>
HTML
        $dbh->disconnect();
        exit;
}
# ---------------------------------------------------------------------
# Print the chat main window.
# ---------------------------------------------------------------------
sub chat_win {
#if ($user_data{uid} eq $usr{anonuser}) { return; }
my $command_load = '';

# Fail safe
my $ok = '';
if ($message !~ m/^\A(\.just logged off\.|\/logout|\/exit)$/i) {
$ok = get_member_room($user_data{uid});  # $room,
if (!$ok) { return 2; }
$ok = check_rooms($ok);
if (!$ok) { return 1; }
}
my $old_date = get_member_room($user_data{uid}, 1) || '';
        my ($output, $good) = ('','');

# Get the current date.
#require DATE_TIME;
#my $date = DATE_TIME::get_date();
($date, $microseconds) = gettimeofday;
require SQLEdit;

        if ($room && $message) {
        # This is so members cant spoof a /msg Name [room] message
        # althoug everyone would see the spoof
        $message =~ s{\*}{\[star\]}gso;
       # $message =~ s{\*}{\*}gso; # &#42;

        # commands
         if ($message =~ m/\A\/kick\s(.*?)\s(.*?)\z/i && $user_data{sec_level} eq $usr{admin}) { require SQLEdit; SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$2', '[message2]', '$date', '$ENV{'REMOTE_ADDR'}', 'Member $1 was Kicked By: $user_data{uid}', '$microseconds');"); logoff($2, $1); }
         elsif ($message =~ m/\A\/help\z/i) { $command_load = 'h'; }
         elsif ($message =~ m/\A\/im\s(.+?)\z/i) {
         $message =~ s/\A\/im\s//g;
         my $tell_user = '';
         $tell_user = get_member_room($message);
          if (!$tell_user) {
          SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '[message]', '$date', '$ENV{'REMOTE_ADDR'}', '$user_data{uid} - Misspelled word or Member is not in Chat Room.', '$microseconds');");
          }
          else {
          my $text = qq(window.open('$cfg{pageurl}/index.$cfg{ext}?op=im_frame;module=Chat;username=$user_data{uid}', 'IM$user_data{uid}', 'height=350,width=350,status=yes,toolbar=no,menubar=no,location=no'););
          $text =~ s{'}{&#39;}gso;
          #require SQLEdit;
          SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$tell_user', '[message]', '$date', '$ENV{'REMOTE_ADDR'}', '$message - Member $user_data{uid} in Room $room Requests You to join an Instant Message Session <a href=\"javascript:void(0)\" Onclick=\"javascript: $text\">Click Here</a>.', '$microseconds');");
          $command_load = 'm';
          }
         }
         elsif ($message =~ m/\A\/msg\s(.*?)\s\[(.*?)\]\s(.*?)\z/i) {
         #require SQLEdit;
         my $mem_room = $2;
         my $mem_tocheck = $1;
         my $ok2 = get_member_room($mem_tocheck); #$2
         if (!$ok2 || $ok2 ne $mem_room) {
             SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '[message]', '$date', '$ENV{'REMOTE_ADDR'}', '$user_data{uid} - Misspelled word or Member is not in Chat Room.', '$microseconds');");
         }
         else {
         #require UBBC;
         #require HTML_TEXT;
         #my $msg = &HTML_TEXT::html_escape($3);
         #$msg = UBBC::do_ubbc($msg);
         #$msg = UBBC::do_smileys($msg);
         my $msg = $AUBBC_mod->do_all_ubbc($3);
         SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$mem_room', '$mem_tocheck', '$date', '$ENV{'REMOTE_ADDR'}', '*$user_data{uid}: $msg', '$microseconds');");
         }

         }
         elsif ($message =~ m/\A\/join\s(.*?)$/i) {
         $ok = check_rooms($1);
         #require SQLEdit;
         if ($room eq $1) {
         SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '[message]', '$date', '$ENV{'REMOTE_ADDR'}', '$user_data{uid} - You are in this room.', '$microseconds');");
         }
         elsif (!$ok) {
         SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '[message]', '$date', '$ENV{'REMOTE_ADDR'}', '$user_data{uid} - There is no Room of that Name.', '$microseconds');");
         }
         else {
         my $change_room = $room; $room = $1;
         SQLEdit::SQLAddEditDelete("UPDATE `chat_mem_lists` SET `room_name` = '$room' WHERE `uid` ='$user_data{uid}' LIMIT 1 ;");
         SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$change_room', '[message2]', '$date', '$ENV{'REMOTE_ADDR'}', 'Member $user_data{uid} has just left this room', '$microseconds');");
         SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '[message2]', '$date', '$ENV{'REMOTE_ADDR'}', 'Member $user_data{uid} joins this room', '$microseconds');");
          }
         }
         elsif ($message =~ m/^\A(\.just logged off\.|\/logout|\/exit)$/i) {
         $refresh_time = 0;
         $command_load = 'l';
         #require SQLEdit;
         SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '$user_data{uid}', '$date', '$ENV{'REMOTE_ADDR'}', '.just logged off.', '$microseconds');");
         logoff($room, $user_data{uid});
         }
         else { login($room, $user_data{uid});

         #require UBBC;
         #require HTML_TEXT;
         #$message = HTML_TEXT::html_escape($message);
         #$message = UBBC::do_ubbc($message);
         #$message = UBBC::do_smileys($message);
         $message = $AUBBC_mod->do_all_ubbc($message);
         $output = "<b>&lt;" . $user_data{uid} . "&gt;</b> " . $message . "<br>\n";
         #require SQLEdit;
         SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '$user_data{uid}', '$date', '$ENV{'REMOTE_ADDR'}', '$message', '$microseconds');");
         }

        # Bots
        # God Bot
        require "$cfg{modulesdir}/Chat/bot__God.pm";
        my $talk_text = bot__God::speack($message);
        if ($talk_text) {
             #require SQLEdit;
             #require UBBC;
             #require HTML_TEXT;
             #$talk_text = HTML_TEXT::html_escape($talk_text);
             #$talk_text = UBBC::do_ubbc($talk_text);
             #$talk_text = UBBC::do_smileys($talk_text);
             $talk_text = $AUBBC_mod->do_all_ubbc($talk_text);
             SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '[God]', '$date', '$ENV{'REMOTE_ADDR'}', '$talk_text', '$microseconds');");
        }
        $talk_text = ''; # clear it for next bot
        # Intelligent Message output bot
        require "$cfg{modulesdir}/Chat/bot_imob.pm";
        $talk_text = bot_imob::speack($message);
        if ($talk_text) {
             #require SQLEdit;
             #require UBBC;
             #require HTML_TEXT;
             #$talk_text = HTML_TEXT::html_escape($talk_text);
             #$talk_text = UBBC::do_ubbc($talk_text);
             #$talk_text = UBBC::do_smileys($talk_text);
             $talk_text = $AUBBC_mod->do_all_ubbc($talk_text);
             SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$room', '[imob]', '$date', '$ENV{'REMOTE_ADDR'}', '$talk_text', '$microseconds');");
        }
        }

my $messages_print = '';
# Damb IE bugs
#qq(<script language="javascript" type="text/javascript">
#if (navigator.appName=="Microsoft Internet Explorer") {
#document.location="#bottum";
#}
#</script>);
my (@sorted_messages);
my ($t_date, $t_sec) = split(/\:/, $old_date);  # room_name='$room'
my($query1) = qq(SELECT * FROM chat_messages WHERE date >= $t_date AND room_name='$room' ORDER BY date, microseconds;); #  DESC

SQLEdit::SQLAddEditDelete("UPDATE `chat_mem_lists` SET `date` = '$date:$microseconds' WHERE `uid` ='$user_data{uid}' LIMIT 1 ;");
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
#if ((time - $row[3]) <= $message_time)
if ($t_date == $row[3] && $row[6] > $t_sec || $t_date < $row[3])
{
        push (
                @sorted_messages,
                join (
                        "|",     $row[3],
                        $row[2], $row[5], $row[6]
                )
            );
 }    # $row[3] $row[6]
}
$sth->finish;

foreach (@sorted_messages) {
   my ($sorted_date,  $name, $message, $micsec) = split (/\|/, $_);
   $message =~ s{&#39;}{'}gso;
   if ($name eq '[message]' && $message =~ m/\A$user_data{uid}\s\-\s(\S+?)/i) {
   $messages_print .= $message . '<br>';
   }
   elsif ($name eq '[message2]') {
   $messages_print .= $message . '<br>';
   }
   elsif ($name eq $user_data{uid} && $message =~ m/\A\*(\S+?)\:\s(\S+?)/i) {
   $messages_print .= '<b>' . $message . '</b><br>';
   }
   elsif ($name ne $user_data{uid} && $message =~ m/\A\*$user_data{uid}\:\s(\S+?)/i) {
   $messages_print .= '<b>' . $message . '</b><br>';
   }
   elsif ($name ne '[message]' && $name ne '[message2]' && $message !~ m/\A\*(\S+?)/i) {
   #$messages_print .= '<b>' . $name . ':</b> ' . $message . "<br>\n\n";
   $messages_print .= qq(<b>$name:</b> $message<br>);
   }
        }

if ($command_load eq 'h') {
$messages_print .= qq(<b>To Veiw The Chat Help Page <a href="javascript:void(0)" Onclick="javascript: window.open('$cfg{pageurl}/index.$cfg{ext}?op=command_win;module=Chat', 'Help', 'height=350,width=800,status=yes,toolbar=no,menubar=no,location=no');">Click Here</a></b><br>)
#qq(<script language="javascript">
#top.window.open('$cfg{pageurl}/index.$cfg{ext}?op=command_win;module=Chat', 'Help', 'height=350,width=650,status=yes,toolbar=no,menubar=no,location=no');
#</script>);
}
 elsif ($command_load eq 'm') {
$messages_print .= qq(<b>Join The Instant Message Session <a href="javascript:void(0)" Onclick="javascript: window.open('$cfg{pageurl}/index.$cfg{ext}?op=im_frame;module=Chat;username=$message', 'IM', 'height=350,width=350,status=yes,toolbar=no,menubar=no,location=no');">Click Here</a></b><br>);
#qq(<script language="javascript">
#var rwindow = parent.window.open('$cfg{pageurl}/index.$cfg{ext}?op=im_frame;module=Chat;username=$message', 'IM', 'height=350,width=350,status=yes,toolbar=no,menubar=no,location=no');
#rwindow;
#</script>);
}
 elsif ($command_load eq 'l') {
$messages_print .= qq(<center><a href="javascript:parent.window.close();">Close Window</a></center>);
#<script language="javascript">
#clearInterval(theloopper)
#setTimeout('parent.window.close();',3000);
#</script>
}
#$messages_print .= '<A NAME="bottum" ID="bottum"> </A>';
return $messages_print;
}
sub send_win {
# was a bug in Log-off javascript, it effected IE & Mozilla

# Get the current date.
#require DATE_TIME;
#my $date = DATE_TIME::get_date();
$room = get_member_room($user_data{uid});
# Get all available channels.
my $channels = qq(<select name="room" size="1" onchange="javascript:ChangeChannel();">\n);
my($query1) = "SELECT * FROM `chat_rooms` WHERE `active` = '1' ;";
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
if($row[0]){
if (!$row[4]) { $row[4] = 0; }
if ($row[1] eq $room) { $channels .= qq(<option selected value="$row[1]">$row[1] ($row[4])</option>\n); }
elsif ($row[1] ne 'IM') { $channels .= qq(<option value="$row[1]">$row[1] ($row[4])</option>\n); }
}

}
$sth->finish;
$channels .= "</select>";
# <script type="text/javascript" src="$cfg{non_cgi_url}/themes/main.js"></script>
print $query->header(), $query->start_html(-meta=>{'Generator"'=>'Flex-WPS ' . $VERSION}, -title=>'Flex-WPS ' . $VERSION . ' Chat', -script=>[$frame_check, {-type=>'text/javascript', -src=>$cfg{non_cgi_url} . '/themes/main.js'}]);
        # Print the UBBC image selector.
        require UBBC;
        my $ubbc_panel = UBBC::print_ubbc_panel(1);

        print <<HTML;
<script type="text/javascript" src="$cfg{non_cgi_url}/themes/ubbc.js"></script>
<script language="javascript" type="text/javascript">
<!--
function SubmitMyForm() {
document.send_win.message.value = document.send_win.chat_message.value;
document.send_win.chat_message.value='';
document.send_win.chat_message.focus();
return(true);
}
function ChangeChannel() {
var this_channel;
this_channel = document.change_channel.room.options[document.change_channel.room.selectedIndex].value;
parent.sendwin.document.send_win.room.value='';
parent.sendwin.document.send_win.room.value = this_channel;
parent.sendwin.document.send_win.message.value = '.just entered this room.';
parent.sendwin.document.send_win.submit();
document.send_win.chat_message.focus();

return;
}
function LogOff() {
parent.sendwin.document.send_win.message.value = '.just logged off.';
parent.sendwin.document.send_win.submit();
setTimeout('parent.window.close();',3000);
}
function addCode(anystr) {
insertAtCursor(document.send_win.chat_message, anystr);
}
function showColor(color) {
var colortag = "[color="+color+"][/color]";
insertAtCursor(document.send_win.chat_message, colortag);
}
function onEnter( evt, frm ) {
var keyCode = null;
if( evt.which ) {
keyCode = evt.which;
} else if( evt.keyCode ) {
keyCode = evt.keyCode;
}
if( 13 == keyCode ) {
imagesubmit();
return false;
}
return true;
}
function imagesubmit() {
document.send_win.message.value = document.send_win.chat_message.value;
document.send_win.submit()
document.send_win.chat_message.value='';
document.send_win.chat_message.focus();
}
//-->
</script>
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #C5D0DC;" valign="top">
<tr>
<form name="send_win" method="post" action="$cfg{pageurl}/index.$cfg{ext}#bottum" target="bottomFrame" OnSubmit="if (document.send_win.chat_message.value=='') return false; javascript:SubmitMyForm();">
<td valign="top" width="70%"><input type="hidden" name="op" value="refresh_win">
<input type="hidden" name="room" value="$room">
<input type="hidden" name="message" value="">
<input type="hidden" name="module" value="Chat">
<table border="0" cellpadding="0" cellspacing="0" width="100%" align="center">
<tr>
<td>
<textarea name="chat_message" wrap="OFF" cols="45" rows="3" maxlength="255" onkeypress="return onEnter(event,this.form);"></textarea></td>
<td align="center">
AutoScroll <input type="checkbox" onClick="top.chatwin.MoveHandler();" checked><br><br>
<a href="javascript:imagesubmit()"><img src="$cfg{imagesurl}/chat/send.gif" border="0" alt="Send"></a>
</td>
</tr>
</table>
<table valign="top" border="0" cellspacing="0" cellpadding="2" width="100%">
<tr>
<td style="background-color: #ebebeb;" valign="top" width="20%"><b>$msg{ubbc_tagsC}</b></td>
<td style="background-color: #ebebeb;" valign="top" width="59%">$ubbc_panel</td>
<td align="center">
<a href="javascript:addCode('/msg Name [Room] message...')"><img src="$cfg{imagesurl}/fluester.gif" alt="IM" border="0"></a>
<br>
<a href="javascript:void(0)" Onclick="javascript: window.open('$cfg{pageurl}/index.$cfg{ext}?op=command_win;module=Chat', 'Help', 'height=350,width=800,status=yes,toolbar=no,menubar=no,location=no');"><img src="$cfg{imagesurl}/forum/question.gif" alt="Chat Help" border="0"></a>
</td>
</tr>
</table></td></form>
<td width="30%" valign="top" style="background-color: #C5D0DC;">
<table border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #eff5fa;" valign="top">
<form name="change_channel"><tr>
<td align="center"><b>Chat Rooms</b><br>$channels<hr></td></tr></form></table>
<b>$user_data{uid}<small>/($user_data{nick})</small></b>
HTML

        if (!$user_data{pic}) { $user_data{pic} = '_nopic.gif'; }
        if ($user_data{pic} =~ /http:\/\//)
        {
                my ($width, $height);
                if ($cfg{picture_width} != 0)
                {
                        $width = "width=\"$cfg{picture_width}\"";
                }
                else { $width = ""; }

                if ($cfg{picture_height} != 0)
                {
                        $height = "height=\"$cfg{picture_height}\"";
                }
                else { $height = ""; }

                print qq(<img src="$user_data{pic}" $width $height border="0" alt="" align="left">);
        }
        else
        {
                print qq(<img src="$cfg{imagesurl}/avatars/$user_data{pic}" border="0" alt="" align="left">);
        }
print <<HTML;
<center>
<form name="log_off"><input type="image" value="Log Off" src="$cfg{imagesurl}/chat/log_off.gif" onclick="javascript: if (!(confirm('Are you sure you want to log off now?'))) { return false; } javascript:LogOff();" alt="Log Off" border="0"></form></center>
</td>
</tr>
</table>
HTML

        print $query->end_html();
        $dbh->disconnect();
        exit;
}
sub login { # better
my ($in_room, $uid) = @_;
my $add = 1;
my $change_room = '';
my $a_room = '';

my $ok = check_rooms($in_room);
if (!$ok) { &enter_chat(); exit; }

# Get member room
$a_room = get_member_room($user_data{uid});

if ($a_room) {
 if ($in_room ne $a_room) {
  $change_room = $a_room;
  $a_room = '';
  $add = 0;
 }
  else {
   $add = 0;
  }
}

# Get the current date.
#require DATE_TIME;
#my $date = DATE_TIME::get_date();
($date, $microseconds) = gettimeofday;
# load sql editer
require SQLEdit;
# In Room
if ($a_room && !$add) {
#SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$in_room', '[message]', '$date', '$ENV{'REMOTE_ADDR'}', '$user_data{uid} - You are in this room.');");
} elsif ($change_room && !$add) {
SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$change_room', '[message2]', '$date', '$ENV{'REMOTE_ADDR'}', 'Member $user_data{uid} has just left this room', '$microseconds');");
SQLEdit::SQLAddEditDelete("UPDATE `chat_mem_lists` SET `room_name` = '$in_room' WHERE `uid` ='$user_data{uid}' LIMIT 1 ;");
#SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$in_room', '[message2]', '$date', '$ENV{'REMOTE_ADDR'}', 'Member $user_data{uid} joins this room');");
} elsif ($add == 1) {
SQLEdit::SQLAddEditDelete("INSERT INTO `chat_messages` VALUES (NULL , '$in_room', '[message2]', '$date', '$ENV{'REMOTE_ADDR'}', 'Member $user_data{uid} joins this room', '$microseconds');");
SQLEdit::SQLAddEditDelete("INSERT INTO `chat_mem_lists` VALUES (NULL , '$in_room', '$user_data{uid}', '$date:$microseconds');");
}

}
# --------------------------------
# Log-off , looks good
# --------------------------------
sub logoff
{
my ($in_room, $uid) = @_;

require SQLEdit;
SQLEdit::SQLAddEditDelete("DELETE FROM `chat_mem_lists` WHERE `room_name` = '$in_room' AND `uid` = '$uid' LIMIT 1 ;");
}
#
# Check Chat room
#
sub check_rooms { # looks good
my ($in_room) = @_;

return unless $in_room;

$in_room = $dbh->quote($in_room);
my ($query1) = "SELECT `id` FROM `chat_rooms` WHERE `room_name` = $in_room AND `active` = '1' LIMIT 1 ;";
my $sth = $dbh->prepare($query1);
$sth->execute;
my $return_it = 0;
while (my @row = $sth->fetchrow)  {
$return_it = 1 if ($row[0]);
}
$sth->finish;
return $return_it;

}
sub get_member_room { # is the main user check now.
my $uid = shift;
my $option = shift;
my $in_room = '';
return unless $uid;

$uid = $dbh->quote($uid);
my($query1) = "SELECT `room_name`, `date` FROM `chat_mem_lists` WHERE `uid` = $uid LIMIT 1 ;";
my $sth = $dbh->prepare($query1);
$sth->execute;
while (my @row = $sth->fetchrow)  {
       $in_room = $row[0] if $row[0] && !$option;
       $in_room = $row[1] if $option;
}
$sth->finish;

return $in_room;
}

# --------------------------------
#  Member List return to print
# --------------------------------
sub memberlist {
# small & fast
my $flash_list = shift;
my $a_room = get_member_room($user_data{uid});
if (!$a_room) { return; }

my ($usr2, $count) = ('', 0);
my($query1) = "SELECT `uid` FROM `chat_mem_lists` WHERE `room_name` = '$a_room' ;";
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
      #if ($row[0]) {
      $count++;
      $usr2 .= qq(<div onclick=\\"top.sendwin.addCode('/im $row[0]');\\"><b>$row[0]</b></div>) if !$flash_list;
      $usr2 .= '<b>' . $row[0] . '</b><br>' if $flash_list;
      #}
}
$sth->finish;

my $return_this = qq(<b><u>2 Bots</u></b><br><b>[God]</b><br><b>[imob]</b><br><br><b><u>$count Users</u></b><br>$usr2<hr>);
 return $return_this;

}

sub flashmem {
my $printmsg = memberlist(1);
print "Content-type: text/html\n\n";
print qq($printmsg);
$dbh->disconnect();
exit;
}

sub flashwin {
my $printmsg = chat_win();
#$printmsg =~ s{[\r\n]}{}gs;
$printmsg =~ s{\"}{\'}gs;
print "Content-type: text/html\n\n";
print $printmsg;
$dbh->disconnect();
exit;
}

sub refresh_win {

my $printmsg = chat_win();
my $printmlist = memberlist();
if (!$printmlist) { $printmlist = ''; }

$printmsg =~ s{\"}{\\\"}gso;
$printmsg =~ s{[\r\n|\r|\n]}{}gso;
$printmsg =~ s{\'}{\\\'}gso;
$printmsg =~ s{\)}{\\\)}gso;
$printmsg =~ s{\;}{\\\;}gso;
$printmsg =~ s{\<}{\\\<}gso;
$printmsg =~ s{\>}{\\\>}gso;

# if ($refresh_time) {
# my $url = $cfg{pageurl} . "/index." . $cfg{ext} . "?op=refresh_win;module=Chat;room=$room#bottum" ; # . "\%23\%00bottum"
# print $query->header(-Refresh=>"$refresh_time; URL='$url'", -charset=>$cfg{codepage});
# print $query->start_html(-meta=>{'Generator'=>'Flex ' . $VERSION}, -title=>'Flex ' . $VERSION . ' Chat', -script=>$frame_check,);
# }
#  else {
#   print $query->header(-charset=>$cfg{codepage}), $query->start_html(-meta=>{'Generator'=>'Flex ' . $VERSION}, -title=>'Flex ' . $VERSION . ' Chat', -style=>{'src'=>$cfg{themesurl} . '/standard/style.css'}, -script=>$frame_check);
#   }

      if ($refresh_time) {
      my $url = '';
      # Compatibility issue with IE and Mozilla - Fix
      # It seems that IE dont like #bottum in the Refresh URL(fucking assholes)
      # so like other issue fixxes i have to code some crap to support both
      if ($ENV{HTTP_USER_AGENT} =~ /MSIE (\d)/i) {
           $url = $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=refresh_win;module=Chat;room=' . $room;
      } else {
        $url = $cfg{pageurl} . '/index.' . $cfg{ext}  . '?op=refresh_win;module=Chat;room=' . $room . '#bottum';
        }
       print $query->header(-Refresh=>"$refresh_time; URL='$url'", -charset=>$cfg{codepage}), $query->start_html(-meta=>{'Generator'=>'Flex-WPS ' . $VERSION}, -title=>'Flex ' . $VERSION . ' Chat', -style=>{'src'=>$cfg{themesurl} . '/standard/style.css'}, , -script=>$frame_check);
      }
      else {
       print $query->header(-charset=>$cfg{codepage}), $query->start_html(-meta=>{'Generator'=>'Flex-WPS ' . $VERSION}, -title=>'Flex ' . $VERSION . ' Chat', -style=>{'src'=>$cfg{themesurl} . '/standard/style.css'}, -script=>$frame_check);
      }
# <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
   # <link rel=\\"stylesheet\\" href=\\"$cfg{themesurl}/chat.css\\" type=\\"text/css\\">
print <<HTML;
<script type="text/javascript">
<!--
window.onload = chat_init;
function chat_init(){
// top.chatwin.document.open()
// top.chatwin.document.write("<!DOCTYPE HTML PUBLIC \\"-//W3C//DTD HTML 4.01 Transitional//EN\\">")
// top.chatwin.document.write("<html><head><title></title><meta http-equiv=\\"Content-Type\\" content=\\"text/html; charset=iso-8859-1\\">")
// top.chatwin.document.write("<link rel=\\"stylesheet\\" href=\\"$cfg{themesurl}/chat.css\\" type=\\"text/css\\"></head><body><div class=\\"texMessages\\">")
// top.chatwin.document.write("$printmsg")
// top.chatwin.document.write("</div></body></html>")
// top.chatwin.document.close()
var string = ("$printmsg").toString();
var string2 = ("$printmlist").toString();
top.chatwin.document.getElementById('msg').innerHTML+=(string);
top.members.document.open();
top.members.document.write(string2);
top.members.document.close();
};
//-->
</script>
</body>
</html>
HTML
$dbh->disconnect();
exit;

}

# Need to check everything below this sub
sub im_frame {
        print $query->header();
        print <<HTML;
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=$cfg{codepage}">
<meta name="Generator" content="Flex $VERSION">
<title>$cfg{pagename} Chat</title>
</head>

<frameset rows="*,80" frameborder="NO" border="0" framespacing="0">
<frame name="mainFrame" src="$cfg{pageurl}/index.$cfg{ext}?op=chat_im;module=Chat;username=$username#bottum">
<frame name="bottomFrame" target="mainFrame" scrolling="NO" noresize src="$cfg{pageurl}/index.$cfg{ext}?op=send_im;module=Chat;username=$username#bottum">
</frameset>
<noframes><body bgcolor="#FFFFFF" text="#000000">
<p>This page uses frames, but your browser doesn't support them.
</body></noframes>
</html>
HTML
        print $query->end_html();
        $dbh->disconnect();
        exit;
}
#
#
sub chat_im {
my(@messages);
if (!$username) { enter_chat(); exit; }
require get_user;
my $uscheck = '';
$uscheck = get_user::check_user($username, 2);
if (!$uscheck) {
print $query->header(-charset=>$cfg{codepage}), $query->start_html(-meta=>{'Generator'=>'Flex-WPS ' . $VERSION}, -title=>'YaWPS ' . $VERSION . ' Chat', -style=>{'src'=>$cfg{themesurl} . '/standard/style.css'}, -script=>$frame_check);
        print <<HTML;
<table border="0" cellspacing="0" cellpadding="5" width="100%">
<tr>
<td valign="top">
Bad User Name.
</td>
</tr>
</table>
HTML

print $query->end_html();
$dbh->disconnect();
exit;
}
# Get the current date.
require DATE_TIME;
my $date = DATE_TIME::get_date();

         if ($message =~ m/^\A\*(.*?)\:\s(.*?)$/i) {
         require SQLEdit;
         #require UBBC;
         #require HTML_TEXT;
         #my $msg = HTML_TEXT::html_escape($2);
         #$msg = UBBC::do_ubbc($msg);
         #$msg = UBBC::do_smileys($msg);
         my $msg = $AUBBC_mod->do_all_ubbc($2);
         SQLEdit::SQLAddEditDelete("INSERT INTO `chat_im` VALUES (NULL , '1', '$date', '$ENV{'REMOTE_ADDR'}', '$user_data{uid}', '$username', '$msg');"); }

my($query1) = "SELECT * FROM chat_im WHERE `from_name` = '$username' AND `to_name` = '$user_data{uid}'";
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
if ((time - $row[2]) <= $message_time)
   {
        push (
                @messages,
                join (
                        "|",     $row[4], $row[2],
                        $row[6]
                )
            );
   }
}
$sth->finish;
$query1 = "SELECT * FROM chat_im WHERE `from_name` = '$user_data{uid}' AND `to_name` = '$username'";
$sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
if ((time - $row[2]) <= $message_time)
   {
        push (
                @messages,
                join (
                        "|",     $row[4], $row[2],
                        $row[6]
                )
            );
   }
}
$sth->finish;
my $messages_print = '';
# Sort messages.
my (@data, @sorted, @sorted_messages);
for (0 .. $#messages)
{
        my @fields = split (/\|/, $messages[$_]);
        for my $i (0 .. $#fields) { $data[$_][$i] = $fields[$i]; }
}
@sorted = sort { $a->[1] <=> $b->[1] } @data;
for (@sorted)
{
        my $sorted_row = join ("|", @$_);
        push (@sorted_messages, $sorted_row);
}
foreach (@sorted_messages) {
                my (
                        $from,  $date, $msg
                    )
                    = split (/\|/, $_);
                    if ($from) { $messages_print .= '<b>' . $from . '</b>: ' . $msg . '<br>'; }
        }
        my $url = '';
   if ($refresh_time) {
      if ($ENV{HTTP_USER_AGENT} =~ /MSIE (\d)/i) { $url = $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=chat_im;module=Chat;username=' . $username . '#bottum';
      } else { $url = $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=chat_im;module=Chat;username=' . $username . '#bottum'; }
       print $query->header(-Refresh=>"$refresh_time; URL='$url'", -charset=>$cfg{codepage}), $query->start_html(-meta=>{'Generator'=>'Flex-WPS ' . $VERSION}, -title=>'Flex-WPS ' . $VERSION . ' Chat', -style=>{'src'=>$cfg{themesurl} . '/standard/style.css'}, , -script=>$frame_check);
      } else {
       print $query->header(-charset=>$cfg{codepage}), $query->start_html(-meta=>{'Generator'=>'Flex-WPS ' . $VERSION}, -title=>'Flex-WPS ' . $VERSION . ' Chat', -style=>{'src'=>$cfg{themesurl} . '/standard/style.css'}, -script=>$frame_check);
      }
#       <script language="javascript" type="text/javascript">
# <!--
# window.onload=function() {
# if (navigator.appName=="Microsoft Internet Explorer") {
# window.self.location.href = window.self.location.href = "#bottum";
# }
# }
# //-->
# </script>
# <a id="bottum" name="bottum"></a>
# Javascript is part 2 of the Compatibility issue with IE and Mozilla - Fix
        print <<HTML;
<script language="javascript" type="text/javascript">
if (navigator.appName=="Microsoft Internet Explorer") {
document.location="#bottum";
}
</script>
<div style="padding: 3px 5px 3px 5px;">
$messages_print
</div>
<br>
<br>
<a name="bottum" id="bottum"> </a><br>
HTML

print $query->end_html();
$dbh->disconnect();
exit;
}
sub send_im {
print $query->header(), $query->start_html(-meta=>{'Generator'=>'Flex-WPS ' . $VERSION}, -title=>'YaWPS ' . $VERSION . ' Chat', -style=>{'src'=>$cfg{themesurl} . '/standard/style.css'}, -script=>$frame_check);

        print <<HTML;
<script type="text/javascript">
function SubmitMyIM() {
document.im.message.value = "*$username: "+document.im.chat_message.value+"";
document.im.chat_message.value='';
document.im.chat_message.focus();
return(true);
}
</script>
<form name="im" method="post" action="$cfg{pageurl}/index.$cfg{ext}#bottum" target="mainFrame" OnSubmit="if (document.im.chat_message.value=='') return false; javascript:SubmitMyIM();">
<input type="hidden" name="op" value="chat_im">
<input type="hidden" name="room" value="IM">
<input type="hidden" name="message" value="">
<input type="hidden" name="username" value="$username">
<input type="hidden" name="module" value="Chat">
<input type="text" name="chat_message" size="40" maxlength="255">
<input type="submit" value="Send">
</form>
HTML

print $query->end_html();
$dbh->disconnect();
exit;
}
#
#
#
sub command_win {
print $query->header(-charset=>$cfg{codepage}), $query->start_html(-meta=>{'Generator'=>'Flex ' . $VERSION}, -title=>'Flex Chat - Help ' . $VERSION . ' Chat', -style=>{'src'=>$cfg{themesurl} . '/standard/style.css'});
print <<HTML;
<br><p>&nbsp;&nbsp;<b>Member Commands </b><br>
</p>
<blockquote>
<table width="100%" border="0" cellspacing="0" cellpadding="3">
    <tr>
      <td align="center"><b>Command</b></td>
      <td align="center"><b>Action</b></td>
    </tr>
    <tr>
      <td>/help</td>
      <td>This page.</td>
    </tr>
    <tr>
      <td>/join Room_Name</td>
      <td>Change Chat Room.</td>
    </tr>
    <tr>
      <td>/im Member_Name</td>
      <td>Join a Instant Message Session with a member.</td>
    </tr>
    <tr>
      <td>/msg Member_Name [Room_Name] message...</td>
      <td>Instant Message a member in Chat.</td>
    </tr>
    <tr>
      <td>/logout or /exit</td>
      <td>Log Off Chat System.</td>
    </tr>
  </table>
 </blockquote>
HTML
if ($user_data{sec_level} eq $usr{admin}) {
print <<HTML;
<p>&nbsp;&nbsp;<b>Administrator Commands </b><br>
</p>
  <blockquote>
    <table width="90%" border="0" cellspacing="0" cellpadding="3">
      <tr>
        <td align="center"><b>Command</b></td>
        <td align="center"><b>Action</b></td>
      </tr>
      <tr>
      <td>/kick Member_Name Room</td>
      <td>Kick Member from Chat.</td>
      </tr>
      <tr>
      <td>/ban Member_Name</td>
      <td>Ban's Member from Chat.</td>
      </tr>
      <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      </tr>
      <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      </tr>
    </table>
</blockquote>
HTML
}
print $query->end_html();
$dbh->disconnect();
exit;
}
1;
