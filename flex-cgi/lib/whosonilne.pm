package whosonilne;
#
# v1.1 - 10/21/2007 07:15:47 By: N.K.A.
# - Supports Buddys, guest, members, est..
#
# Global variables.
use strict;
use vars qw(
         %sub_action %usr $dbh
         %user_data %cfg %nav %msg
         );
use exporter;

%sub_action = ( user_status => 1 );

# ---------------------------------------------------------------------
# Display a box with current user status.  - Flex - Updated
# ---------------------------------------------------------------------
sub user_status {

# Get visitor log. - done, test more
        my ($guests, $users, $buddy)  = ('0', '0', '0');
        my $DATE = time || 'DATE';
        my %pre_log = ();
        $DATE -= 60 * 15;
my $sth = "SELECT * FROM stats_log WHERE date > $DATE;";  #  LIMIT 1000;
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
       my (undef, $ip, $domain, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, $uid, $sec_level) = split(/\|/, $row[2]);

        $ip = $ip || $domain || '';

        if ($sec_level eq $usr{anonuser}) {
            if (!$pre_log{$ip}) {
                $guests++;
                $pre_log{$ip} = 1;
                }
        }
}
$sth->finish();
#clear the hash to maybe speed up the program
%pre_log = ();

my $buds = '';
require get_user;
require DATE_TIME;
my $date = DATE_TIME::get_date();
$date -= 60 * 15;
my $sth = "SELECT * FROM auth_session WHERE date >= $date;";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");

while(my @row = $sth->fetchrow)  {

  $users++ if $row[0];
  if ($user_data{sec_level} ne $usr{anonuser}) {
  my $u_name = get_user::check_user($row[1]);
my (@iid) = split (/\,/, $user_data{buddys});
if (@iid) {
     foreach my $crap (@iid) {
        if ($crap eq $row[1]) {
          $buddy++;
          $buds .= "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$row[1]\"><small>$u_name</small></a>, ";
        }
     }
    }
  $cfg{online_members} .= "<a href=\"$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$row[1]\"><small>$u_name</small></a>, ";
 }
}
$sth->finish();

# END

# Get members stats - done, test more
my ($most_online, $member_count, $last_registered)  = ('0', '0', '0');
my $sth = "SELECT * FROM whosonline";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
  $member_count = $row[1] if $row[1];
  $most_online = $row[2] if $row[2];
  $last_registered = $row[3] if $row[3];
}
$sth->finish();
# END

# Most online check
my $current_most = $users + $guests;
    if ($current_most > $most_online) {
         require SQLEdit;
         SQLEdit::SQLAddEditDelete("UPDATE `whosonline` SET `mostonline` = '$current_most' WHERE `id` =1 LIMIT 1 ;");
         $most_online = $current_most;
    }
# END

if ($user_data{sec_level} ne $usr{anonuser}) {
# Whos Online Menu
        require theme;
        my $user_status = theme::box_header($nav{who_is_online});
        my $voter = '';
        $voter = qq(<hr noshade width="65%">You have $user_data{votes} votes left.) if $user_data{votes};
                $user_status .= <<HTML;
<tr>
<td class="cat">$msg{logged_in_asC}<br><center><a href=\"$cfg{pageurl}/index.$cfg{ext}?op=view_profile">$user_data{uid}</a><small>/($user_data{nick})</smal></center></td>
</tr>
<tr>
<td class="cat"><center><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_pm"><img src="$cfg{imagesurl}/forum/message.gif" alt="$nav{im_index}" border="0"></a></center>
$voter<hr noshade width="65%"></td>
</tr>
HTML
$buds .= '<br>' if $buds;
# Show online users and guests.
# $msg{guestsC} $guests<br>

        $user_status .= <<HTML;
<tr>
<td class="cat">
$msg{guestsC} $guests<br>
Buddys: $buddy<br>
$buds
$msg{membersC} $users<br>
$cfg{online_members}<br>
<b>Most Online: $most_online
<hr noshade width="65%">
$msg{member_countC} $member_count<br>
Newest Member:<br><center>$last_registered</center></b></td>
</tr>
HTML

        $user_status .= theme::box_footer();
# END
        #return $user_status;
        print $user_status;
        }
}
1;