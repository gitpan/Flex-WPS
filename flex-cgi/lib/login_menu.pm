package login_menu;

use strict;

use vars qw(
    %sub_action
    %cfg %nav %btn %msg
    %user_data %usr
    );

# Define possible sub actions.
%sub_action = ( print_menu => 1 );
use exporter;

sub print_menu {

if ($user_data{sec_level} eq $usr{anonuser}) {
         use lib './lib/modules';
         require Captcha;
         my $Imagehtml = Captcha::get_image('small');
         require theme;
     my $user_panel = theme::box_header($nav{login});

     $user_panel .= <<HTML;
<tr>

<form method="post" action="$cfg{pageurl}/index.$cfg{ext}"><td>
<table border="0" cellpadding="5" cellspacing="0" align="center" class="navtable">
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
<td colspan="2" align="center"><a href="$cfg{pageurl}/index.$cfg{ext}?op=reminder">$nav{forgot_pass}</a><br>
<a href="$cfg{pageurl}/index.$cfg{ext}?op=register">$nav{new_user}</a></td>
</tr>
</table>
</td></form>
</tr>
HTML
     $user_panel .= theme::box_footer();

     print $user_panel;
}
}
1;