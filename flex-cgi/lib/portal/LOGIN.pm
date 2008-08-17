package LOGIN;

=head1 COPYLEFT

  LOGIN.pm,v 1.0C 12/23/2007 N.K.A.

 This file is part of Flex WPS - Flex Web Portal System.
 Login, Log-out, Remember Password code.

 Need a Clear IP code

=cut

use strict;
use vars qw(
    $query
    %err %user_data %usr %nav %cfg %msg %btn
    $dbh %inf
    );
# Load Portal Core
use exporter;

my $username = $query->param('username') || '';
my $password = $query->param('password') || '';
my $email = $query->param('email') || '';
my $remember = $query->param('remember') || '';
my $confirm  = $query->param('confirm') || '';

# For - Captcha Module
my $security_key  = $query->param('security_key');
my $date_captcha  = $query->param('date_captcha');

    # XSS Holes - found By: M4K3 http://www.pldsoft.de/ | fixed by: S_Flex
     if ($date_captcha && $date_captcha !~ /^[0-9a-z]+$/) { require error; error::user_error($err{bad_input}); } # For - Captcha Module
     if ($security_key && $security_key !~ /^[0-9A-Za-z]+$/) { require error; error::user_error($err{bad_input}); } # For - Captcha Module
     if ($remember && $remember !~ /^[0-9a-z]+$/) { require error; error::user_error($err{bad_input}); }
     if ($confirm && $confirm !~ /^[0-9a-z]+$/) { require error; error::user_error($err{bad_input}); }
     if ($username && $username !~ /^[0-9A-Za-z_]+$/) { require error; error::user_error($err{bad_input}); }
     if ($password && $password !~ /^[0-9A-Za-z]+$/) { require error; error::user_error($err{bad_input}); }

=head1 NAME

Package LOGIN

=head1 DESCRIPTION

 Login, Logout, Reminder Module Settup .

=head1 SYNOPSIS

 use LOGIN;
 &LOGIN::login();
 &LOGIN::login2();
 &LOGIN::login3();
 &LOGIN::logout();
 &LOGIN::logout2();
 &LOGIN::reminder();
 &LOGIN::reminder2();
 &LOGIN::reminder3();


=head1 FUNCTIONS

 These functions are available from this package:

=cut

=head2 login()

 Return the LOGIN panel.
 LOGIN::login();

=cut

# ---------------------------------------------------------------------
# Display the login page.
# ---------------------------------------------------------------------
sub login {
        my $failed = shift || 0;
        my $retry_msg =
            ($failed
            ? qq(<tr height="30"><td colspan="2">$failed</td></tr>)
            : '');

        # Check if user is already logged in.
        if ($user_data{uid} ne $usr{anonuser}) {
                require error; error::user_error($err{bad_input}, $user_data{theme});
        }

#         $cfg{captchadbdir} = $cfg{modulesdir} . "/Captcha";
         use lib './lib/modules';
         require Captcha;
         my $Imagehtml = Captcha::get_image();

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{login});

        print <<HTML;
<table width="100%" border="0" cellspacing="5" cellpadding="5">
<tr>
<td width="50%">
<form method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<table border="0" cellpadding="5" cellspacing="1" align="center" class="navtable">
$retry_msg
<tr>
<td class="tbl_row_dark"><b>$msg{usernameC}</b></td>
<td class="tbl_row_light" align="center"><input type="text" name="username" size="10" maxlength="50"></td>
</tr>
<tr>
<td class="tbl_row_dark"><b>$msg{passwordC}</b></td>
<td class="tbl_row_light" align="center"><input type="password" name="password" size="10" maxlength="50"></td>
</tr>
<tr>
<td colspan="2"><input type="checkbox" name="remember" checked>&nbsp;$msg{remember_me}</td>
</tr>
<tr>
<td colspan="2">$Imagehtml<input type="hidden" name="op" value="login2"><input type="submit" value="$btn{login}"></td>
</tr>
<tr>
<td colspan="2" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=reminder">$nav{forgot_pass}</a></td>
</tr>
</table>
</form></td>
<td width="50%">
<table width="50%" border="0" cellspacing="0" cellpadding="0" align="center" class="navtable">
<tr>
<td align="center" height="99" class="tbl_row_dark"><b>Not a Member Yet?</b><br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=register">$nav{new_user}</a></td>
</tr>
</table>
</td>
</tr>
</table>
HTML

        theme::print_html($user_data{theme}, $nav{login}, 1);
}

=head2 login2()

 Return a LOGIN Function.
 LOGIN::login2();

=cut

# ---------------------------------------------------------------------
# Log on the user.
# ---------------------------------------------------------------------
sub login2 {

        # Data integrity check.
        require filters;
        $username = filters::untaint2($username);
        if (!$username) {
            login($err{bad_username});
        }
        $password = filters::untaint2($password);
        if (!$password) {
            login($err{wrong_passwd});
        }
        if(length($username) < 1
           || length($username) > 12) {
              login($err{bad_username});
           }
        if(length($password) < 4
           || length($password) > 28) {
              login($err{wrong_passwd});
           }

         if (!$security_key || !$date_captcha) {
          login($err{auth_failure});
         }
#
#         $cfg{captchadbdir} = $cfg{modulesdir} . "/Captcha";
         # Captcha image check
         require Captcha;
         my $secret_images = Captcha::get_image(1, $security_key, $date_captcha);
         if (!$secret_images) {
          login('Bad security code');
         }

        # Get user profile.
       # Load Sha-1
       use Digest::SHA1 qw(sha1_hex);
       # Encrypt the password.
       my $encrypted_password = sha1_hex($password, $username); # Better SHA1
       # Build statment and Check if user is approved
        my $query1 = "SELECT * FROM `members` WHERE `password` = '$encrypted_password' AND `uid` = '$username' AND `approved` = '1'";
        my $sth = $dbh->prepare($query1);
        if ($username && $password && $encrypted_password) {

        $sth->execute || die("Couldn't exec sth!");
        my ($name, $pass, $update, $user_id, $votesd, $xp);
        # Get the current date.
        require DATE_TIME;
        my $date = DATE_TIME::get_date();

        while(my @user_data = $sth->fetchrow)  {
        $user_id = $user_data[0];
        $name = $user_data[2];
        $pass = $user_data[1];
        $xp = $user_data[11];
        $votesd = $user_data[13];
        }
        $sth->finish();

        if (!$name && !$pass) {
            login("$err{bad_username}, $err{wrong_passwd} $msg{search_or} $err{not_approved}");
            }

# Check Administrator and Moderator IP
if ($user_data{admin_ip} && $user_data{admin_ip} ne $ENV{REMOTE_ADDR}
     && ($user_data{sec_level} eq $usr{admin} || $user_data{sec_level} eq $usr{mod})) {
     login("$err{not_approved} or Bad security code, contact the site $usr{admin}.");
     }

     # Session ID - Test 1
        my $session = '';
        $sth = "SELECT * FROM auth_session WHERE user_id='$user_id' LIMIT 1 ;";
        $sth = $dbh->prepare($sth);
        $sth->execute;
        while(my @user_data = $sth->fetchrow)  {
                   $session = $user_data[0] if $user_data[0];
        }
        $sth->finish();

        require SQLEdit;
        if ($session) {

        my $sql_code = qq(DELETE FROM auth_session WHERE id='$session');
        SQLEdit::SQLAddEditDelete($sql_code);
        }
        my $vday = CGI::Util::expire_calc('now','');
        if ($votesd <= $vday) {
                if ($xp >= 300) {
                #$xp = ($xp / 400) * 100;
                $xp = $xp / 100;
                $xp =~ s/\..*?\z//g;
                $xp = 50 if $xp > 50;
                }
                 else { $xp = 3; }
                my $next_v = CGI::Util::expire_calc('+20h','');
                my $sql_code = qq(UPDATE `members` SET `votes` = '$xp', `next_votes` = '$next_v' WHERE `memberid` ='$user_id' LIMIT 1 ;);
                SQLEdit::SQLAddEditDelete($sql_code);
        }

                # Check if user session should be stored in cookie.
                my $expire = $remember ? $cfg{cookie_expire} : 0;
                my $session_exp = CGI::Util::expire_calc($expire,'');
                $pass = $encrypted_password . $name . $session_exp;
                # This makes any stolen cookies usless! - Shaka_Flex
                my $host = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || '';
                $pass = sha1_hex($pass, $host);

                # Add new session
                my $sql_code = qq(INSERT INTO `auth_session` ( `id` , `user_id` , `session_id` , `expire_date` , `date` )
VALUES (
NULL , '$user_id', '$pass', '$session_exp', '$date'
););
                SQLEdit::SQLAddEditDelete($sql_code);

                # Set the cookie.
                use CGI::Cookie;
                my $cookie_password = new CGI::Cookie(
                        -name     => 'ID',
                        -value    => $pass,
                        -expires  => $expire,
                        -httponly => 1,
                    );
#                 my $cookie_password = $query->cookie(
#                         -name     => 'ID',
#                         -value    => $pass,
#                         -path     => '/',
#                         -expires  => $expire,
#                         -httponly => 1,
#                     );

                $dbh->disconnect();
                # Redirect to the welcome page.
                print $query->redirect(
                        -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=view_profile',
                        -cookie   => $cookie_password,
                    );
        }
        else { login("$err{bad_username} $msg{search_or} $err{wrong_passwd}"); }
}

=head2 logout()

 Return a LOGIN Function.
 LOGIN::logout();

=cut

# ---------------------------------------------------------------------
# Log off the user.
# ---------------------------------------------------------------------
sub logout {

        $dbh->disconnect();
        # Empty cookie values.
        my $cookie_username = $query->cookie(
                -name    => 'ID',
                -value   => '',
                -path    => '/',
                -expires => 'now'
            );
         $dbh->disconnect();
        # Redirect to the logout page.
        print $query->redirect(
                -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=logout2',
                -cookie   => $cookie_username
            );
}

=head2 logout2()

 Return a LOGIN Function.
 LOGIN::logout2();

=cut

# ---------------------------------------------------------------------
# Display logout page.
# ---------------------------------------------------------------------
sub logout2 {

        # Check if user is logged in.
        if ($user_data{uid} ne $usr{anonuser}) {
                require error; error::user_error($err{bad_input}, $user_data{theme});
        }

        # Print the logout page.
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{logout});

        print
            qq($inf{logged_out}<br>\n<a href="$cfg{pageurl}/index.$cfg{ext}">$nav{click_back}</a>);

        theme::print_html($user_data{theme}, $nav{logout}, 1);
}

=head2 reminder()

 Return a LOGIN Function.
 LOGIN::reminder();

=cut

# ---------------------------------------------------------------------
# Display a formular, where user can reset his password.
# ---------------------------------------------------------------------
sub reminder {

        # Check if user is already logged in.
        if ($user_data{uid} ne $usr{anonuser}) {
                require error; error::user_error($err{bad_input}, $user_data{theme});
        }

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{reset_pass});

        print <<HTML;
<center><p>This will change the current Password of your Member and email it to the currect email.</center>
<form method="post" action="$cfg{pageurl}/index.$cfg{ext}">
<input type="hidden" name="op" value="reminder2">
<table border="0" cellspacing="1">
<tr>
<td><b>$msg{usernameC}</b></td>
<td><input type="text" name="username" size="30"></td>
</tr>
<tr>
<td><b>$msg{emailC}</b></td>
<td><input type="text" name="email" size="30" maxlength="100"></td>
</tr>
</table>
<input type="submit" value="$btn{send}">
</form>
HTML

        theme::print_html($user_data{theme}, $nav{reset_pass}, 1);
}

# ---------------------------------------------------------------------
# Send user confirmation email for resetting password.
# ---------------------------------------------------------------------
sub reminder2 {
                if (!$email) { require error; error::user_error($err{enter_email}, $user_data{theme}); }
                if ($email !~ /^[0-9A-Za-z@\._\-]+$/
                        || $email =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) {
                        require error; &error::user_error($err{bad_input}, $user_data{theme});
                }
                require filters;
                $username = filters::untaint2($username);
                if (!$username) { require error; &error::user_error($err{bad_input}, $user_data{theme}); }
        # Read user profile.
        my @user_profile = ();
        my $new_name = $username;
        $username = $dbh->quote($username);
        $email = $dbh->quote($email);
        my $sth = "SELECT * FROM `members` WHERE `uid` = $username AND `email` = $email AND `approved` = '1' LIMIT 1 ;";
        $sth = $dbh->prepare($sth);
        $sth->execute || die("Couldn't exec sth!");
        #login("$err{bad_username} $msg{search_or} $err{wrong_passwd}");
        while(my @row = $sth->fetchrow)  {
        push (
                @user_profile,
                join (
                        "|",     $row[0],
                        $row[1], $row[2],
                        $row[3], $row[4]
                )
            );
        }
        if (!@user_profile) { require error; &error::user_error($err{not_writable}); }

for (@user_profile) {
@user_profile = split(/\|/, $_);
my $sql = qq(UPDATE `members` SET `approved` = '0' WHERE `memberid` ='$user_profile[0]' LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);

        my $confirm_link =
            "$cfg{pageurl}/index.cgi?op=reminder3&confirm=$user_profile[1]&username=$new_name";

        # Generate info email.
        my $subject =
            "$cfg{pagename} - $msg{confirm_pass_change} $user_profile[3]";
        my $message = <<EOT;
$inf{hi_you_or} $ENV{REMOTE_ADDR} $inf{requested_that_user} $user_profile[3] $inf{receive_new_pass} $inf{to_confirm_visit}
$confirm_link
$inf{change_required_msg}

E-mail was sent from: $cfg{cgi_bin_url}/index.$cfg{ext}
EOT

        # Send the email to recipient.
        require PM_EMAIL;
        PM_EMAIL::send_email($cfg{webmaster_email}, $user_profile[4], $subject, $message);

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{forgot_pass});

        print "$inf{confirmation_sent} <b>$user_profile[3]</b>";

        theme::print_html($user_data{theme}, $nav{forgot_pass}, 1);
  }
}

# ---------------------------------------------------------------------
# Reset user password.
# ---------------------------------------------------------------------
sub reminder3 {
        if (!$username) { require error; &error::user_error($err{enter_name}, $user_data{theme}); }
        if (!$confirm) { require error; &error::user_error($err{enter_name}, $user_data{theme}); }
        # Read user profile.
        my @user_profile = ();
        my $new_name = $username;
        $username = $dbh->quote($username);
        $confirm = $dbh->quote($confirm);
        my $sth = "SELECT * FROM `members` WHERE `password` = $confirm AND `uid` = $username AND `approved` = '0' LIMIT 1 ;";
        $sth = $dbh->prepare($sth);
        $sth->execute || die("Couldn't exec sth!");
        while(my @row = $sth->fetchrow)  {
        # Get user data.
        push (
                @user_profile,
                join (
                        "|",     $row[0],
                        $row[1], $row[2],
                        $row[3], $row[4], $row[8]
                )
            );
        }
        if (!@user_profile) { require error; &error::user_error($err{bad_confirm_code}, $user_data{theme}); }
        for (@user_profile) {
        @user_profile = split(/\|/, $_);
        # Generate a password.
        my $password;
        rand(time ^ $$);
        my @seed = ('a' .. 'k', 'm' .. 'n', 'P' .. 'Z', '2' .. '9');

        for (my $i = 0; $i < 8; $i++)
        {
                $password .= $seed[int(rand($#seed + 1))];
        }
        use Digest::SHA1 qw(sha1_hex);
        my $enc_password = sha1_hex($password, $new_name); # Better SHA1

        # Update user database.
        my $sql = qq(UPDATE `members` SET `password` = '$enc_password',
`approved` = '1' WHERE `memberid` ='$user_profile[0]' LIMIT 1 ;);
        require SQLEdit;
        SQLEdit::SQLAddEditDelete($sql);

        # Generate info email.
        my $subject =
            $cfg{pagename} . " - " . $msg{password_forC} . $user_profile[3];
        my $message = <<EOT;
$inf{hi_you_or} $ENV{REMOTE_ADDR} $inf{requested_that_user} $user_profile[3] $inf{receive_new_pass} $inf{user_pass_are}

$msg{usernameC} $user_profile[2]
$msg{passwordC} $password

$msg{statusC} $user_profile[5]

$inf{change_pass}

E-mail was sent from: $cfg{cgi_bin_url}/index.$cfg{ext}
EOT

        # Send the email to recipient
        require PM_EMAIL;
        PM_EMAIL::send_email($cfg{webmaster_email}, $user_profile[4], $subject, $message);

        # Print info page.
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{reset_pass});

        print "$inf{info_sent} <b>$user_profile[3]</b>";

        theme::print_html($user_data{theme}, $nav{reset_pass}, 1);
   }
}
1;
