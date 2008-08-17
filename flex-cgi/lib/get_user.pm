package get_user;
use strict;
# Assign global variables.
use vars qw($dbh %usr %cfg %msg %user_data %nav);
use exporter;

# box code
sub box_script {
my $width = shift || 410;
$width .= 'px';
print <<HTML;
<style type="text/css">
<!--
.extra-space div.award-inline { margin-right: 5px; }
div.award-inline {
float: left;
width: 20px;
height: 20px;
position: relative;
}
div.award-inline:hover div.award-pop {
display: block;
}
div.award-pop {
display: none;
position: absolute;
top: 5px;
left: 0;
z-index: 50;
width: $width;
color : #FFFFFF;
background: #444643;
border: 4px solid #383c33;
-moz-opacity: .95;
}
div.dir-left {
left: 20px;
right: auto;
}
div.dir-right {
left: auto;
right: 20px;
}
-->
</style>
<script type="text/javascript">
<!--
var agt   = navigator.userAgent.toLowerCase();
var is_ie = ((agt.indexOf("msie") != -1) && (agt.indexOf("opera") == -1));
function hideMine(elmnt) {
        if( !is_ie ) return;
        var a = elmnt.getElementsByTagName("div");
        var div = a[0];
        elmnt.style.zIndex = 1;
        div.style.display = "none";
}
function showMine(elmnt) {
        if( !is_ie ) return;
        var a = elmnt.getElementsByTagName("div");
        var div = a[0];
        elmnt.style.zIndex = 100;
        div.style.display = "block";
}
//-->
</script>
HTML
}
# part 1
sub mouse_boxtop {
my $box = <<HTML;
<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">
HTML
return $box;
}
# part 2
sub mouse_box {
my $profile = shift || '';
return unless $profile;
my $box = <<HTML;
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center>$profile</center>
</div>
</div>
HTML
return $box;
}
sub profile {
# This will print out HTML with javascript for full profile info
my $memid = shift || '';
return unless $memid;
return unless ($memid =~ m!^([0-9]+)$!i);
        my %cp  = ();
        my $query1 = "SELECT * FROM members WHERE memberid='$memid'";
        my $sth = $dbh->prepare($query1);
        $sth->execute || die("Couldn't exec sth!");
        #login("$err{bad_username} $msg{search_or} $err{wrong_passwd}");
        while(my @user_data = $sth->fetchrow)  {
     ##  my @user_data = $sth->fetchrow or die "$sth->errstr\n";
        my $sec_level = $user_data[8];
        my $stat_level = $user_data[8];

        if ($user_data[8] eq '') {
        $sec_level = $usr{user}; $stat_level = $usr{user}; }

        if ($user_data[8] ne ''
        && $user_data[8] ne $usr{user}
        && $user_data[8] ne $usr{admin}
        && $user_data[8] ne $usr{mod}
        && $user_data[8] ne $usr{anonuser})
        { $sec_level = $usr{user}; $stat_level = $user_data[8]; }
%cp = (
 id => $user_data[0], uid => $user_data[2], pwd => $user_data[1],
 nick => $user_data[3], email => $user_data[4], website => $user_data[5],
 website_url => $user_data[6], signature => $user_data[7], forum_posts => $user_data[11],
 sec_level => $sec_level, icq => $user_data[15], pic => $user_data[9],
 joined => $user_data[10], topic_posts => $user_data[12], comments => $user_data[13],
 us_level => $stat_level, theme => $user_data[14], yahoo => $user_data[16],
 aim => $user_data[17], msnm => $user_data[18], skype => $user_data[19],
 flag => $user_data[20], gen => $user_data[21], bugbadge => $user_data[22],
 modules => $user_data[23], security => $user_data[24], bronze => $user_data[25],
 rib => $user_data[26], rib2 => $user_data[27], rib3 => $user_data[28]
 );
 }
 $sth->finish();
        # Get current user profile.
       # my $user_profile = file2array("$cfg{memberdir}/$username.dat", 1);

        # User picture.
        my $member_pic;
        if (!$cp{pic}) { $cp{pic} = '_nopic.gif'; }
        if ($cp{pic} =~ /http:\/\//)
        {
                my ($width, $height);
                if ($cfg{picture_width} != 0)
                {
                        $width = "width=\"$cfg{picture_width}\"";
                }
                else { $width = "25"; }

                if ($cfg{picture_height} != 0)
                {
                        $height = "height=\"$cfg{picture_height}\"";
                }
                else { $height = "25"; }

                $member_pic =
                    qq(<img src="$cp{pic}" $width $height border="0" alt="">);
        }
        else
        {
                $member_pic =
                    qq(<img src="$cfg{imagesurl}/avatars/$cp{pic}" border="0" alt="">);
        }

        # Get member ranks.
        require rank;
        my @ranks = rank::load_ranks();

        # Display member ranking.
        my $ranking =
            $cp{forum_posts} + $cp{topic_posts} + $cp{comments};

         my $member_info = '';
        foreach (@ranks)
        {
        my ($r_num, $r_name) = split (/\|/, $_);
           if ($ranking >= $r_num)
           {
           $member_info = $r_name;
           if($cfg{forum_stars}) {
           } else {
           $member_info = qq($r_name <img src="$cfg{imagesurl}/rank/$member_info.gif" alt="$member_info" border="0">);
           }
        }
    }
        my $status = $cp{sec_level} . ' , ' . $cp{us_level} || '';

        my $protected_email = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=contact;recip_name=$cp{id}"><img src='$cfg{imagesurl}/forum/email.gif' alt='$msg{send_email} $cp{nick}' border='0'></a>);
        # Format date.
        require DATE_TIME;
        my $formatted_date = DATE_TIME::format_date($cp{joined});

        my $userhtml = <<HTML;
<table border="0" cellspacing="2" width="66%" cellpadding="0">
<tr>
<td><font color="#FFFFFF"><b><big>$cp{nick}</big></b></font></div>
HTML

        # Print link to edit profile and link to send IMs.
        if ($cp{uid} eq $user_data{uid} || $user_data{sec_level} eq $usr{admin})
        {
                $userhtml .=
                    qq(&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=edit_profile;username=$cp{id}"><img src="$cfg{imagesurl}/forum/modify.gif" style="border: none;" alt="$nav{edit_profile}"></a>);
        }
        if ($cp{uid} ne $user_data{uid})
        {
        # Get Action ID
      #  $cfg{securitydir} = $cfg{modulesdir} . "/security";
       # require "$cfg{securitydir}/formid.pl";
       # my $time_stamp; #MAKE_ID('profile_buddy', $user_data{uid});

                $userhtml .=
                    qq(&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=view_pm;message=send;to=$cp{id}"><img src="$cfg{imagesurl}/forum/message.gif" style="border: none;" alt="$nav{send_message}"></a>);
                $userhtml .=
                    qq(&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=add_buddy;to=$cp{id}"><img src="$cfg{imagesurl}/add_remove_buddy.gif" style="border: none;" alt="$nav{addbuddy}"></a>);
        }
        # ICQ
        my $icq_link = '';
        if ($cp{icq}) {
        $icq_link = qq(<tr>
<td><b>$msg{icqC}</b></td>
<td><a href="http://wwp.icq.com/$cp{icq}"><img src="$cfg{imagesurl}/forum/icq.gif" style="border: none;" alt="$msg{icqC}"></a></td>
</tr>); }
        # YAHOO
        my $yahoo_link = '';
        if ($cp{yahoo}) {
        $yahoo_link = qq(<tr>
<td><b>Yahoo:</b></td>
<td><a href="http://edit.yahoo.com/config/send_webmesg?.target=$cp{yahoo}&.src=pg"><img src="$cfg{imagesurl}/forum/yim.gif" style="border: none;" alt="YIM"></a></td>
</tr>); }
        # AIM
        my $aim_link = '';
        if ($cp{aim}) {
        $aim_link = qq(<tr>
<td><b>AIM:</b></td>
<td><a href="aim:goim?screenname=$cp{aim}&message=Hello+Are+you+there?"><img src="$cfg{imagesurl}/forum/aim.gif" style="border: none;" alt="AIM"></a></td>
</tr>); }
        # MSNM
        my $msnm_link = '';
        if ($cp{msnm}) {
        $msnm_link = qq(<tr>
<td><b>MSNM:</b></td>
<td><a href="http://members.msn.com/$cp{msnm}"><img src="$cfg{imagesurl}/forum/msnm.gif" style="border: none;" alt="MSNM"></a></td>
</tr>); }
        # Skype link
        my $skype_link = '';
        if ($cp{skype}) { $skype_link = qq(<tr>
<td><b>Skype:</b></td>
<td><script type="text/javascript" src="http://download.skype.com/share/skypebuttons/js/skypeCheck.js"></script>
<a href="skype:$cp{skype}?call"><img src="http://mystatus.skype.com/smallclassic/$cp{skype}" style="border: none;" alt="Skype" /></a>
</td>
</tr>); }

  # Flag
  my $flag = '';
  if ($cp{flag}) {
     my $name = $cp{flag};
     $name =~ s/.gif$//g;
     $flag = qq(<tr>
<td><b>Country Flag:</b></td>
<td><img src="$cfg{imagesurl}/flags/$cp{flag}" style="border: none;" alt="$name"></td>
</tr>);
}
# Gender
  my $gen1 = '';
if ($cp{gen} =~ /($msg{male}|$msg{female})$/) {
     $gen1 = qq(<tr>
<td><b>$msg{gender}</b></td>
<td><img src="$cfg{imagesurl}/$cp{gen}.gif" style="border: none;" alt="$cp{gen}"></td>
</tr>);
}

       my $web_link = '';
       if ($cp{website} && $cp{website_url} && $cp{website_url} ne 'http://') { $web_link = qq(<a href="$cp{website_url}" target="_blank">$cp{website}</a>); }
       elsif (!$cp{website} && $cp{website_url} && $cp{website_url} ne 'http://') { $web_link = qq(<a href="$cp{website_url}" target="_blank">$cp{website_url}</a>); }
$userhtml .= <<HTML;
</td>
</tr>
<tr>
<td>
<table border="0" class="navtable">
<tr>
<td><b>$msg{nameC}</b></td>
<td>$cp{uid}</td>
</tr>
$gen1
$flag
<tr>
<td><b>$msg{emailC}</b></td>
<td>$protected_email</td>
</tr>
<tr>
<td><b>$msg{websiteC}</b></td>
<td>$web_link</td>
</tr>
$icq_link
$yahoo_link
$aim_link
$msnm_link
$skype_link
<tr>
<td><b>$msg{forum_postsC}</b></td>
<td>$cp{forum_posts}</td>
</tr>
<tr>
<td><b>$msg{articlesC}</b></td>
<td>$cp{topic_posts}</td>
</tr>
<tr>
<td><b>$msg{commentsC}</b></td>
<td>$cp{comments}</td>
</tr>
<tr>
<td><b>$msg{member_sinceC}</b></td>
<td>$formatted_date</td>
</tr>
<tr>
<td valign="top"><b>$msg{pictureC}</b></td>
<td align="center">$member_pic</td>
</tr>
<tr>
<td class="bg6"><b>$msg{statusC}</b></td>
<td bgcolor="#666666"><font color="#FFFFFF">&nbsp;&nbsp;$status</font></td>
</tr>
<tr>
<td class="bg6"><b>$msg{rankC}</b></td>
<td bgcolor="#666666"><font color="#FFFFFF">&nbsp;&nbsp;$member_info</font></td>
</tr>
</table>
</td>
</tr>
</table>
HTML
return unless $cp{id};
$userhtml = $cp{uid} . '<small>/(' . $cp{nick} . ')</small>' . '][][' . $userhtml;
 return $userhtml;
}
# Qiuck check user & return the name
sub check_user {
my $memid = shift || '';
my $option = shift || '';
return unless $memid;
my $check = 0;
my $query1 = "SELECT uid, nick FROM members WHERE memberid='$memid'";
$query1 = "SELECT memberid FROM members WHERE memberid='$memid'" if $option eq 1;
$query1 = "SELECT memberid FROM members WHERE uid='$memid'" if $option eq 2;
my $sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @user_data = $sth->fetchrow)  {
$check = $user_data[0];
$check .= '<small>/(' . $user_data[1] . ')</small>' if $user_data[1];
 }
 $sth->finish();
return unless $check;
return $check;
}
1;