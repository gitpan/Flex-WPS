package register;


#  register.pm
#  v2.0 11/08/2007 By:  N.K.A.
#  added ajax for user name register
#  This file is part of Flex WPS.
#  v1.0 - 85% complete 10/25/2007

# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    $query
    $username $email
    %user_data
    %user_action %err %usr %cfg %nav %msg %btn
    $dbh %inf
    );
use exporter;

# Get the input.
$username = $query->param('username');
$email    = $query->param('email');

my $date_captcha = $query->param('date_captcha');
my $security_key = $query->param('security_key');

    # XSS Holes - found By: M4K3 http://www.pldsoft.de/ | fixed by: S_Flex
     if ($date_captcha && $date_captcha !~ /^[0-9a-z]+$/) { require error; error::user_error($err{bad_input}); }
     if ($security_key && $security_key !~ /^[A-Za-z]+$/) { require error; error::user_error($err{bad_input}); }
     #if ($op && $op !~ /^[1-2a-z]+$/) { require error; error::user_error($err{bad_input}); }

# ---------------------------------------------------------------------
# Display formula to register users.
# ---------------------------------------------------------------------
sub register {
        # Check if user is already logged in.
        if ($user_data{uid} ne $usr{anonuser}) {
          require error; error::user_error($err{bad_input}, $user_data{theme});
        }
my $failed = shift || 0;
   my $retry_msg =
            ($failed
            ? qq(<tr height="30"><td colspan="2">$failed</td></tr>)
            : '');
        # Captcha
#         $cfg{captchadbdir} = $cfg{modulesdir} . "/Captcha";
         #use lib './lib/modules';
         #require Captcha;
         #my $Imagehtml = Captcha::get_image();
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{new_user}, '', 'register_name');

        print <<HTML;
<table width="100%" border="0" cellspacing="5" cellpadding="5">
<tr>
<td width="50%">
<table border="0" cellpadding="5" cellspacing="1" align="center" class="navtable">
$retry_msg
<tr>
<td><div id="CheckOK"> </div>
<p>Not a Member yet? You can be one for free. As a registered user you have some advantages like downloads, profile configuration, post threads with your name and more.
</p>
<form method="post" action="$cfg{pageurl}/index.$cfg{ext}" name="regform">
<table border="0" cellspacing="1">
<tr>
<td><b>$msg{usernameC}</b></td>
<td><input type="text" name="username" size="20"> <a href="#top" onclick="checkName(document.regform.username.value,'')">Check UserName</a></td>
</tr>
<tr>
<td><b>$msg{emailC}</b></td>
<td><input type="text" name="email" size="20" maxlength="100"></td>
</tr>
<tr>
<td colspan="2"><input type="hidden" name="op" value="register2"><div id="captimer"> </div><div id="captcha"> </div><input type="submit" value="$btn{register}">
<script>
 var milisec=0
 var seconds=300
 var seconds2=seconds
function display(){
if (countNow == 1) {
if (seconds == seconds2) {
       document.getElementById('captimer').innerHTML="<b>Captcha Expires</b> "+seconds;
}
 if (milisec == 0){
    milisec=10
    seconds-=1
 }
    milisec-=1
        document.getElementById('captimer').innerHTML="<b>Captcha Expires</b> "+seconds+"."+milisec
    if (seconds == 0 && milisec == 0) {
    url  =
      '$cfg{pageurl}/index.$cfg{ext}?op=ajax_get\\;module=Captcha';
      seconds=seconds2
      countNow = '';
      doGETRequest(url, processReqChangeMany, 'captcha', countdownStart);
    }
 } else {
   document.getElementById('captimer').innerHTML="<b>Loading Captcha....</b>";
   }
  setTimeout("display()",100)
}
display();
</script>
</td>
</tr>
</table>
</form>
</td>
</tr>
</table></td>
<td width="50%">
<table width="50%" border="0" cellspacing="0" cellpadding="0" align="center" class="navtable">
<tr>
<td align="center" height="99" class="tbl_row_dark"><b>Member $nav{login}.</b><br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=login">$nav{login}</a></td>
</tr>
</table>
</td>
</tr>
</table>
HTML

        theme::print_html($user_data{theme}, $nav{new_user}, 1);
}

# ---------------------------------------------------------------------
# Register a new user.
# ---------------------------------------------------------------------
sub register2 {

        # Check if user is already logged in.
        if ($user_data{uid} ne $usr{anonuser}) {
                require error; error::user_error($err{bad_input}, $user_data{theme});
        }

        # Check input.
        if (!$username) { register($err{enter_name}); }
        if ($username !~ m!^([\dA-Za-z\_]+)$!i
                || length($username) < 2
                || length($username) > 12
                || $username eq $usr{admin}
                || $username eq $usr{sadmin}
                || $username eq $usr{sfadmin}
                || $username eq $usr{mod}
                || $username eq $usr{user}
                || $username eq $usr{anonuser}
                || $username =~ m!\A\d+!i) {
                register($err{bad_username});
        }
        if (!$email) {
        register($err{enter_email});
        }

        if ($email !~ /^[0-9A-Za-z\@\.\_\-]+$/ || $email =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) {
                register($err{bad_input});
        }
# Check if user name exists
my $query1 = "SELECT * FROM members WHERE uid='$username'";
my $sth = $dbh->prepare($query1);
$sth->execute;
my $name = '';
while(my @user_data = $sth->fetchrow)  {
if($user_data[2] eq $username) { $name = $user_data[2]; }
}
$sth->finish();
if ($name) { register($err{username_exists}); }

# members count
# my $memct = 0;
# my $query1 = "SELECT * FROM whosonline WHERE id='1'";
# my $sth = $dbh->prepare($query1);
# $sth->execute || die("Couldn't exec sth!");
# while(my @row = $sth->fetchrow)  {
# $memct = $row[1];
# }
# $sth->finish();

        #Captcha
       #  $cfg{captchadbdir} = $cfg{modulesdir} . "/Captcha";
       use lib './lib/modules';
         require Captcha;
         my $secret_images = Captcha::get_image(1, $security_key, $date_captcha);
         if (!$secret_images) { register($err{auth_failure}); }

        # Get censored words.
       # my $censored = file2array("$cfg{datadir}/censor.txt", 1);

        # Check for bad words.
#         foreach (@{$censored})
#         {
#                 my ($bad_word, $censored) = split (/\=/, $_);
#                 user_error($err{bad_username}, $user_data{theme})
#                     if ($username eq $bad_word);
#         }

        # Generate a password.
        my $password;
        rand(time ^ $$);
        my @seed = ('a' .. 'k', 'm' .. 'n', 'P' .. 'Z', '2' .. '9');
        for (my $i = 0; $i < 8; $i++) {
                $password .= $seed[int(rand($#seed + 1))];
        }
        use Digest::SHA1 qw(sha1_hex);
        my $enc_password = sha1_hex($password, $username); # Better SHA1

        # Get date.
        require DATE_TIME;
        my $date = DATE_TIME::get_date();

        # Add user to database.
        if ($username =~ /^([\w.]+)$/) { $username = $1; }
        else { register($err{bad_input}); }

        require SQLEdit;
        SQLEdit::SQLAddEditDelete("UPDATE `whosonline` SET `membercount` =membercount + 1,`lastregistered` = '$username' WHERE `id` ='1' LIMIT 1 ;");

# Add New Member
SQLEdit::SQLAddEditDelete("INSERT INTO members VALUES (NULL,'$enc_password','$username','$username','$email','','','My generic signature','$usr{user}','_nopic.gif','$date','0','0','0','standard','','','','','','','','','','','','','$cfg{enable_approvals}','')");

        # Generate info email.
        my $subject = $msg{welcome_to} . " " . $cfg{pagetitle};
        my $message = <<EOT;
$inf{account_created}
$msg{usernameC} $username
$msg{passwordC} $password

This Email was sent from: $cfg{cgi_bin_url}/index.$cfg{ext}.
EOT

        # Send the email to recipient.
        require PM_EMAIL;
        PM_EMAIL::send_email($cfg{webmaster_email}, $email, $subject, $message);

        # Send info mail to site admin.
        PM_EMAIL::send_email($email, $cfg{webmaster_email}, $subject, $message);

        # Print info page.
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{new_user});

        print <<HTML;
<table align="center" border="0" cellspacing="1">
<tr>
<td>
$inf{info_sent} <b>$email</b><br>
$inf{change_pass}
</td>
</tr>
</table>
HTML

        theme::print_html($user_data{theme}, $nav{new_user}, 1);
}

sub user_names {

        if (!$username) {
        $username = $err{enter_name};
        }
        elsif ($username !~ m!^([\dA-Za-z\_]+)$!i
                || length($username) < 2
                || length($username) > 12
                || $username eq $usr{admin}
                || $username eq $usr{sadmin}
                || $username eq $usr{sfadmin}
                || $username eq $usr{mod}
                || $username eq $usr{user}
                || $username eq $usr{anonuser}
                || $username =~ m!\A\d+!i) {
                $username = $err{bad_username};
        }
         else {
my $query1 = "SELECT `uid` FROM `members` WHERE `uid` = '$username'";
my $sth = $dbh->prepare($query1);
$sth->execute;
my $name = '';
while(my @user_data = $sth->fetchrow)  {
if($user_data[0] eq $username) { $name = $user_data[0]; }
}
$sth->finish();
if ($name) {
     $username = $err{username_exists};
     }
      else {
         $username .= ' Name is Available';
      }
}
print "Content-type: text/xml\n\n";
    print qq(<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<response>
  <method>checkName</method>
  <result>$username</result>
</response>
);
 $dbh->disconnect();
 exit();
}
1;