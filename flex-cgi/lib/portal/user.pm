package user;

=head1 COPYLEFT

 $Id: user.pm,v 1.0 5/19/2006 13:37:55 $|-|4X4_|=73}{ Exp $

 This file is part of Flex WPS - Flex Web Portal System.

=cut

# Load necessary modules.
use strict;
# Assign global variables.
use vars qw(
    $query
    $op $username $password1 $password2 $nick $email $website $website_url $signature $forum_posts
    $sec_level $icq $member_pic $member_pic_personal $member_pic_personal_check $joined
    $topic_posts $comments $theme $modify $delete
    %user_data %err $dbh %usr %cfg %msg %nav %btn $AUBBC_mod
    );
use exporter;
# inputs
$username                  = $query->param('username');
$password1                 = $query->param('password1');
$password2                 = $query->param('password2');
$nick                      = $query->param('nick');
$email                     = $query->param('email');
$website                   = $query->param('website');
$website_url               = $query->param('website_url');
$signature                 = $query->param('signature');
$forum_posts               = $query->param('forum_posts');
$sec_level                 = $query->param('sec_level');
$icq                       = $query->param('icq');
$member_pic                = $query->param('member_pic');
$member_pic_personal       = $query->param('member_pic_personal');
$member_pic_personal_check = $query->param('member_pic_personal_check');
$joined                    = $query->param('joined') || '';
$topic_posts               = $query->param('topic_posts');
$comments                  = $query->param('comments');
$theme                     = $query->param('theme');
$modify                    = $query->param('modify');
$delete                    = $query->param('delete');

my $yahoo                  = $query->param('yahoo');
my $aim                    = $query->param('aim');
my $msnm                   = $query->param('msnm');
my $skype                  = $query->param('skype');
my $flag                   = $query->param('flag');
my $gen                    = $query->param('gen') || '';
my $bugbadge               = $query->param('bugbadge') || '';
my $gold                   = $query->param('gold') || '';
my $silver                 = $query->param('silver') || '';
my $bronze                 = $query->param('bronze') || '';
my $rib                    = $query->param('rib') || '';
my $rib2                   = $query->param('rib2') || '';
my $rib3                   = $query->param('rib3') || '';

    # XSS Holes - found By: M4K3 http://www.pldsoft.de/ | fixed by: S_Flex
     if ($password2 && $password2 !~ m!^([0-9A-Za-z]+)$!i) { require error; error::user_error($err{bad_input}); }
     if ($username && $username !~ m!^([0-9a-zA-Z_]+)$!i) { require error; error::user_error($err{bad_input}); }
     if ($password1 && $password1 !~ m!^([0-9A-Za-z]+)$!i) { require error; error::user_error($err{bad_input}); }

=head1 NAME

Package user

=head1 DESCRIPTION

 95% complete 09/22/2006

=head1 SYNOPSIS

Well it should work, may have some bugs.
Delete Profile has not been tested and should add a switch to tern on/off.


=head1 FUNCTIONS

 These functions are available from this package:

=cut

=head2 view_profile()

 Display user's profile.

=cut

sub view_profile
{

        # Check if user is logged in.
        if ($user_data{uid} eq $usr{anonuser})
        {
         require error; error::user_error($err{bad_input}, $user_data{theme});
        }

if (!$username) { $username = $user_data{id}; }
        my %cp  = ();
        my $query1 = '';
        $query1 = "SELECT * FROM members WHERE memberid='$username' AND approved='1' LIMIT 0 , 30" if $username =~ /\A\d+\z/;
        $query1 = "SELECT * FROM members WHERE memberid='$username' LIMIT 0 , 30" if ($user_data{sec_level} eq $usr{admin} && $username =~ /\A\d+\z/);
        $query1 = "SELECT * FROM members WHERE uid = '$username' AND approved='1' LIMIT 0 , 30" if $username !~ /\A\d+\z/;
        $query1 = "SELECT * FROM members WHERE uid = '$username' LIMIT 0 , 30" if ($user_data{sec_level} eq $usr{admin} && $username !~ /\A\d+\z/);

        my $sth = $dbh->prepare($query1);
        $sth->execute;
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
 votes_used => $user_data[23], views => $user_data[24], bronze => $user_data[25],
 rib => $user_data[26], rib2 => $user_data[27], rib3 => $user_data[28]
 );
 }
 $sth->finish();

 # No data error
 if (!$cp{id}) {
     require error;
     error::user_error('$err{bad_input}', $user_data{theme});
     }

  # Text and word Wrap, default Perl Module!
 use Text::Wrap
 $Text::Wrap::columns = 45; # Wrap at 45 characters
    $cp{signature} = wrap('', '', $cp{signature});
    #require UBBC;
    #$cp{signature} = UBBC::do_ubbc($cp{signature});
    #$cp{signature} = UBBC::do_smileys($cp{signature});
    $cp{signature} = $AUBBC_mod->do_all_ubbc($cp{signature});
          # View count
          my $string = qq(UPDATE `members` SET `view_ct` =view_ct + 1 WHERE `memberid` ='$cp{id}' LIMIT 1 ;);
          require SQLEdit;
          SQLEdit::SQLAddEditDelete($string);
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
                else { $width = ""; }

                if ($cfg{picture_height} != 0)
                {
                        $height = "height=\"$cfg{picture_height}\"";
                }
                else { $height = ""; }

                $member_pic =
                    qq(<img src="$cp{pic}" $width $height border="0" alt=""></a>);
        }
        else
        {
                $member_pic =
                    qq(<img src="$cfg{imagesurl}/avatars/$cp{pic}" border="0" alt=""></a>);
        }

        # Get member ranks.
        require rank;
        my @ranks = rank::load_ranks();
        if(!$cp{forum_posts}) { $cp{forum_posts} = 0; }
        #if(!$cp{topic_posts}) { $cp{topic_posts} = 0; }
        #if(!$cp{comments}) { $cp{comments} = 0; }
        # Display member ranking.
        my $ranking = $cp{forum_posts};

         my $member_info = '';
        foreach (@ranks)
        {
        my ($r_num, $r_name) = split (/\|/, $_);
           if ($ranking >= $r_num)
           {
           $member_info = $r_name;
           if($cfg{forum_stars}) {
           } else {
           $member_info = qq($r_name <img src="$cfg{imagesurl}/rank/$member_info.gif" alt="$member_info" border="0" style="background-color : #666666;">);
           }
        }
    }
        my $status = $cp{sec_level} . ' , ' . $cp{us_level} || '';

        my $protected_email = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=contact;recip_name=$username"><img src='$cfg{imagesurl}/forum/email.gif' alt='$msg{send_email} $cp{nick}' border='0'></a>);
        # Format date.
        require DATE_TIME;
        my $formatted_date = DATE_TIME::format_date($cp{joined});

        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, $nav{view_profile});

        print <<HTML;
<style type="text/css">
 <!--
 .extra-space div.award-inline { margin-right: 5px; }
div.award-inline {
float: left;
width: 45px;
height: 45px;
position: relative;
}
div.award-inline:hover div.award-pop {
display: block;
}
div.award-pop {
display: none;
position: absolute;
top: 40px;
left: 0;
z-index: 50;
width: 410px;
color : #FFFFFF;
background: #444643;
border: 4px solid #383c33;
-moz-opacity: .95;
}

div.dir-left {
left: 30px;
right: auto;
}

div.dir-right {
left: auto;
right: 30px;
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
<table border="0" cellspacing="2" cellpadding="0" width="100%">
<tr>
<td><div class="texttitle">$cp{uid}<small>/($cp{nick})</small></div>
HTML

        # Print link to edit profile and link to send IMs.
        if ($username eq $user_data{id} || $user_data{sec_level} eq $usr{admin})
        {
                print
                    qq(&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=edit_profile;username=$username"><img src="$cfg{imagesurl}/forum/modify.gif" style="border: none;" alt="$nav{edit_profile}"></a>);
        }
        if ($username ne $user_data{id})
        {
        # Get Action ID
      #  $cfg{securitydir} = $cfg{modulesdir} . "/security";
       # require "$cfg{securitydir}/formid.pl";
        my $time_stamp = ''; #MAKE_ID('profile_buddy', $user_data{uid});

                print
                    qq(&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=view_pm;message=send;to=$username"><img src="$cfg{imagesurl}/forum/message.gif" style="border: none;" alt="$nav{send_message}"></a>);
                print
                    qq(&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=add_buddy;to=$username"><img src="$cfg{imagesurl}/add_remove_buddy.gif" style="border: none;" alt="$nav{addbuddy}"></a>);
        }
        # ICQ
        my $icq_link = '';
        if ($cp{icq}) {
        $icq_link = qq(<tr>
<td class="bg6"><b>$msg{icqC}</b></td>
<td><a href="http://wwp.icq.com/$cp{icq}"><img src="$cfg{imagesurl}/forum/icq.gif" style="border: none;" alt="$msg{icqC}"></a></td>
</tr>); }
        # YAHOO
        my $yahoo_link = '';
        if ($cp{yahoo}) {
        $yahoo_link = qq(<tr>
<td class="bg6"><b>Yahoo:</b></td>
<td><a href="http://edit.yahoo.com/config/send_webmesg?.target=$cp{yahoo}&.src=pg"><img src="$cfg{imagesurl}/forum/yim.gif" style="border: none;" alt="YIM"></a></td>
</tr>); }
        # AIM
        my $aim_link = '';
        if ($cp{aim}) {
        $aim_link = qq(<tr>
<td class="bg6"><b>AIM:</b></td>
<td><a href="aim:goim?screenname=$cp{aim}&message=Hello+Are+you+there?"><img src="$cfg{imagesurl}/forum/aim.gif" style="border: none;" alt="AIM"></a></td>
</tr>); }
        # MSNM
        my $msnm_link = '';
        if ($cp{msnm}) {
        $msnm_link = qq(<tr>
<td class="bg6"><b>MSNM:</b></td>
<td><a href="http://members.msn.com/$cp{msnm}"><img src="$cfg{imagesurl}/forum/msnm.gif" style="border: none;" alt="MSNM"></a></td>
</tr>); }
        # Skype link
        my $skype_link = '';
        if ($cp{skype}) { $skype_link = qq(<tr>
<td class="bg6"><b>Skype:</b></td>
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
<td class="bg6"><b>Country Flag:</b></td>
<td><img src="$cfg{imagesurl}/flags/$cp{flag}" style="border: none;" alt="$name"></td>
</tr>);
}
# Gender
  my $gen1 = '';
if ($cp{gen} =~ /($msg{male}|$msg{female})$/) {
     $gen1 = qq(<tr>
<td class="bg6"><b>$msg{gender}</b></td>
<td><img src="$cfg{imagesurl}/$cp{gen}.gif" style="border: none;" alt="$cp{gen}"></td>
</tr>);
}
# Bug Badge
  my $bgbadge = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if (!$cp{bugbadge}) { $cp{bugbadge} = 0; }
if ($cp{bugbadge} >= 2 && $cp{bugbadge} <= 4) {
     $bgbadge = qq($bgbadge<img src="$cfg{imagesurl}/awards/BugsBadge_1.gif" style="border: none;" alt="$msg{bugbadge} $msg{basic}">);
}
elsif ($cp{bugbadge} >= 5 && $cp{bugbadge} <= 9) {
     $bgbadge = qq($bgbadge<img src="$cfg{imagesurl}/awards/BugsBadge_2.gif" style="border: none;" alt="$msg{bugbadge} $msg{veteran}">);
}
elsif ($cp{bugbadge} >= 10) {
     $bgbadge = qq($bgbadge<img src="$cfg{imagesurl}/awards/BugsBadge_3.gif" style="border: none;" alt="$msg{bugbadge} $msg{expert}">);
} else { $bgbadge = qq($bgbadge<img src="$cfg{imagesurl}/awards/BugsBadge_0.gif" style="border: none;" alt="$msg{bugbadge} $msg{non}">); }
$bgbadge = qq($bgbadge
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>$msg{bugbadge}</strong></center>
<ul>
<li>$msg{basic} Report 2 Bugs on this site.</li>
<li>$msg{veteran} Report 5 Bugs on this site.</li>
<li>$msg{expert} Report 10 Bugs on this site.</li>
<li>$cp{bugbadge} Bugs Reported to this site.</li>
</ul>
</div>
</div>);
# Votes Here
my ($pos_vote, $neg_vote, $vtotal) = split(/\|/, $cp{votes_used});
$pos_vote = 0 if !$pos_vote;
$neg_vote = 0 if !$neg_vote;
$vtotal = 0 if !$vtotal;
my $vote_image = '';
my $poll_votes = $vtotal - $pos_vote;
$poll_votes = $poll_votes - $neg_vote;

# Board Badge
my $bdbadge = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if (!$cp{forum_posts}) { $cp{forum_posts} = 0; }
if ($cp{forum_posts} >= 500 && $cp{forum_posts} <= 4999) {
     $bdbadge = qq($bdbadge<img src="$cfg{imagesurl}/awards/BoardBadge_1.gif" style="border: none;" alt="$msg{bdbadge} $msg{basic}">);
}
elsif ($cp{forum_posts} >= 5000 && $cp{forum_posts} <= 8999) {
     $bdbadge = qq($bdbadge<img src="$cfg{imagesurl}/awards/BoardBadge_2.gif" style="border: none;" alt="$msg{bdbadge} $msg{veteran}">);
}
elsif ($cp{forum_posts} >= 9000) {
     $bdbadge = qq($bdbadge<img src="$cfg{imagesurl}/awards/BoardBadge_3.gif" style="border: none;" alt="$msg{bdbadge} $msg{expert}">);
} else { $bdbadge = qq($bdbadge<img src="$cfg{imagesurl}/awards/BoardBadge_0.gif" style="border: none;" alt="$msg{bdbadge} $msg{non}">); }
$bdbadge = qq($bdbadge
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>$msg{bdbadge}</strong></center>
<ul>
<li>$msg{basic} Get XP 500.</li>
<li>$msg{veteran} Get XP 5000.</li>
<li>$msg{expert} Get XP 9000.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
# News Badge
#my $xp = $cp{forum_posts};
  my $nwsbadge = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if (!$pos_vote) { $pos_vote = 0; }
if ($pos_vote >= 100 && $pos_vote <= 2499) {
     $nwsbadge = qq($nwsbadge<img src="$cfg{imagesurl}/awards/NewsBadge_1.gif" style="border: none;" alt="$msg{nwbadge} $msg{basic}">);
}
elsif ($pos_vote >= 2500 && $pos_vote <= 4999) {
     $nwsbadge = qq($nwsbadge<img src="$cfg{imagesurl}/awards/NewsBadge_2.gif" style="border: none;" alt="$msg{nwbadge} $msg{veteran}">);
}
elsif ($pos_vote >= 5000) {
     $nwsbadge = qq($nwsbadge<img src="$cfg{imagesurl}/awards/NewsBadge_3.gif" style="border: none;" alt="$msg{nwbadge} $msg{expert}">);
} else { $nwsbadge = qq($nwsbadge<img src="$cfg{imagesurl}/awards/NewsBadge_0.gif" style="border: none;" alt="$msg{nwbadge} $msg{non}">); }
$nwsbadge = qq($nwsbadge
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>$msg{nwbadge}</strong></center>
<ul>
<li>$msg{basic} Up Vote 100 Members.</li>
<li>$msg{veteran} Up Vote 2500 Members.</li>
<li>$msg{expert} Up Vote 5000 Members.</li>
<li>$pos_vote Total Up Votes.</li>
</ul>
</div>
</div>);
# News Comment Badge
  my $nwscbadge = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if (!$poll_votes) { $poll_votes = 0; }
if ($poll_votes >= 50 && $poll_votes <= 499) {
     $nwscbadge = qq($nwscbadge<img src="$cfg{imagesurl}/awards/LevelBadge_1.gif" style="border: none;" alt="$msg{basic}">);
}
elsif ($poll_votes >= 500 && $poll_votes <= 1999) {
     $nwscbadge = qq($nwscbadge<img src="$cfg{imagesurl}/awards/LevelBadge_2.gif" style="border: none;" alt="$msg{veteran}">);
}
elsif ($poll_votes >= 2000) {
     $nwscbadge = qq($nwscbadge<img src="$cfg{imagesurl}/awards/LevelBadge_3.gif" style="border: none;" alt="$msg{expert}">);
} else { $nwscbadge = qq($nwscbadge<img src="$cfg{imagesurl}/awards/LevelBadge_0.gif" style="border: none;" alt="$msg{non}">); }
$nwscbadge = qq($nwscbadge
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>$msg{no}</strong></center>
<ul>
<li>$msg{basic} Use 50 votes on Polls .</li>
<li>$msg{veteran} Use 500 votes on Polls .</li>
<li>$msg{expert} Use 2000 votes on Polls .</li>
<li>$poll_votes  Total Poll Votes.</li>
</ul>
</div>
</div>);
$bgbadge = qq(<tr height="50">
<td class="bg6"><b>$msg{badges}</b></td>
<td><table border="0" cellspacing="0" cellpadding="2">
<tr>
<td align="left" bgcolor="#666666" valign="top" width="50%">$bgbadge$bdbadge$nwsbadge$nwscbadge</td>
</tr>
</table></td>
</tr>);
# Metals
#if (!$cp{modules}) { $cp{modules} = 0; }
  my $brzimg = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 25) {
     $brzimg .= qq(<img src="$cfg{imagesurl}/metals/BronzeStar_1.gif" style="border: none;" alt="$msg{metals} $msg{bronze}">);
} else { $brzimg .= qq(<img src="$cfg{imagesurl}/metals/BronzeStar_0.gif" style="border: none;" alt="$msg{metals} $msg{non}">); }
$brzimg = qq($brzimg
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Bronze Star</strong></center>
<ul>
<li>Need to have 25 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);

  my $silvimg = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 250) {
     $silvimg .= qq(<img src="$cfg{imagesurl}/metals/SilverStar_1.gif" style="border: none;" alt="$msg{metals} $msg{silver}">);
} else { $silvimg .= qq(<img src="$cfg{imagesurl}/metals/SilverStar_0.gif" style="border: none;" alt="$msg{metals} $msg{non}">); }

$silvimg = qq($silvimg
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Silver Star</strong></center>
<ul>
<li>Need to have 250 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
  my $gldimg = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 500) {
     $gldimg .= qq(<img src="$cfg{imagesurl}/metals/GoldStar_1.gif" style="border: none;" alt="">);
} else { $gldimg .= qq(<img src="$cfg{imagesurl}/metals/GoldStar_0.gif" style="border: none;" alt="">); }
$gldimg = qq($gldimg
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Gold Star</strong></center>
<ul>
<li>Need to have 500 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
#   my $goodcon = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
# if ($user_profile->[21] >= 8) {
#      $goodcon .= qq(<img src="$cfg{imagesurl}/metals/GoodConductMedal_1.gif" style="border: none;" alt="">);
# } else { $goodcon .= qq(<img src="$cfg{imagesurl}/metals/GoodConductMedal_0.gif" style="border: none;" alt="">); }
# $goodcon = qq($goodcon
# <div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
# <center><strong>Good Conduct Medal</strong></center>
# <ul>
# <li>Need to have made 8 Modules for Flex-WPS.</li>
# <li>$user_profile->[21] Flex Modules Made.</li>
# </ul>
# </div>
# </div>);
  my $achive = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 1000) {
     $achive .= qq(<img src="$cfg{imagesurl}/metals/FlexAchievement_1.gif" style="border: none;" alt="">);
} else { $achive .= qq(<img src="$cfg{imagesurl}/metals/FlexAchievement_0.gif" style="border: none;" alt="">); }
$achive = qq($achive
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Achievement Medal</strong></center>
<ul>
<li>Need to have 1000 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
  my $legion = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 2000) {
     $legion .= qq(<img src="$cfg{imagesurl}/metals/LegionofMerit_1.gif" style="border: none;" alt="">);
} else { $legion .= qq(<img src="$cfg{imagesurl}/metals/LegionofMerit_0.gif" style="border: none;" alt="">); }
$legion = qq($legion
<div class="award-pop dir-right" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Legion of Merit Medal</strong></center>
<ul>
<li>Need to have 2000 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
  my $destsev = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 4000) {
     $destsev .= qq(<img src="$cfg{imagesurl}/metals/DistinguishedServiceMedal_1.gif" style="border: none;" alt="">);
} else { $destsev .= qq(<img src="$cfg{imagesurl}/metals/DistinguishedServiceMedal_0.gif" style="border: none;" alt="">); }
$destsev = qq($destsev
<div class="award-pop dir-right" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Distinguished Service Medal</strong></center>
<ul>
<li>Need to have 4000 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
  my $honor = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 8000) {
     $honor .= qq(<img src="$cfg{imagesurl}/metals/metalofhonor_1.gif" style="border: none;" alt="">);
} else { $honor .= qq(<img src="$cfg{imagesurl}/metals/metalofhonor_0.gif" style="border: none;" alt="">); }
$honor = qq($honor
<div class="award-pop dir-right" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Medal of Honor</strong></center>
<ul>
<li>Need to have 8000 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
#if (!$cp{security}) { $cp{security} = 0; }
  my $combat = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 150) {
     $combat .= qq(<img src="$cfg{imagesurl}/metals/CombatInfantryMedal_1.gif" style="border: none;" alt="">);
} else { $combat .= qq(<img src="$cfg{imagesurl}/metals/CombatInfantryMedal_0.gif" style="border: none;" alt="">); }
$combat = qq($combat
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Combat Infantry Medal</strong></center>
<ul>
<li>Need to have 150 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
  my $marks = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 550) {
     $marks .= qq(<img src="$cfg{imagesurl}/metals/MarksmanInfantryMedal_1.gif" style="border: none;" alt="">);
} else { $marks .= qq(<img src="$cfg{imagesurl}/metals/MarksmanInfantryMedal_0.gif" style="border: none;" alt="">); }
$marks = qq($marks
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Marksman Infantry Medal</strong></center>
<ul>
<li>Need to have 550 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
  my $navy = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 2500) {
     $navy .= qq(<img src="$cfg{imagesurl}/metals/NavyCross_1.gif" style="border: none;" alt="">);
} else { $navy .= qq(<img src="$cfg{imagesurl}/metals/NavyCross_0.gif" style="border: none;" alt="">); }
$navy = qq($navy
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Navy Cross</strong></center>
<ul>
<li>Need to have 2500 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
  my $servc = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 5000) {
     $servc .= qq(<img src="$cfg{imagesurl}/metals/MeritoriousServiceMedal_1.gif" style="border: none;" alt="">);
} else { $servc .= qq(<img src="$cfg{imagesurl}/metals/MeritoriousServiceMedal_0.gif" style="border: none;" alt="">); }
$servc = qq($servc
<div class="award-pop dir-left" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Meritorious Service Medal</strong></center>
<ul>
<li>Need to have 5000 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
  my $valor = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 7000) {
     $valor .= qq(<img src="$cfg{imagesurl}/metals/MedalofValor_1.gif" style="border: none;" alt="">);
} else { $valor .= qq(<img src="$cfg{imagesurl}/metals/MedalofValor_0.gif" style="border: none;" alt="">); }
$valor = qq($valor
<div class="award-pop dir-right" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Medal of Valor</strong></center>
<ul>
<li>Need to have 7000 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
  my $dessev = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 9000) {
     $dessev .= qq(<img src="$cfg{imagesurl}/metals/DefenseDistinguishedServic_1.gif" style="border: none;" alt="">);
} else { $dessev .= qq(<img src="$cfg{imagesurl}/metals/DefenseDistinguishedService_0.gif" style="border: none;" alt="">); }
$dessev = qq($dessev
<div class="award-pop dir-right" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Distinguished Service Medal</strong></center>
<ul>
<li>Need to have 9000 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
  my $super = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
if ($cp{forum_posts} >= 10000) {
     $super .= qq(<img src="$cfg{imagesurl}/metals/DefenseSuperiorService_1.gif" style="border: none;" alt="">);
} else { $super .= qq(<img src="$cfg{imagesurl}/metals/DefenseSuperiorService_0.gif" style="border: none;" alt="">); }
$super = qq($super
<div class="award-pop dir-right" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
<center><strong>Superior Service Metal</strong></center>
<ul>
<li>Need to have 10000 XP.</li>
<li>$cp{forum_posts} XP Total.</li>
</ul>
</div>
</div>);
#   my $phart = qq(<div class="award-inline" onmouseover="showMine(this);" onmouseout="hideMine(this);">);
# if ($user_profile->[22] >= 25) {
#      $phart .= qq(<img src="$cfg{imagesurl}/metals/PurpleHeart_1.gif" style="border: none;" alt="">);
# } else { $phart .= qq(<img src="$cfg{imagesurl}/metals/PurpleHeart_0.gif" style="border: none;" alt="">); }
# $phart = qq($phart
# <div class="award-pop dir-right" style="background: rgb(68, 70, 67)  no-repeat scroll left top; -moz-background-clip: -moz-initial; -moz-background-origin: -moz-initial; -moz-background-inline-policy: -moz-initial;">
# <center><strong>Purple Heart</strong></center>
# <ul>
# <li>Need to Find 25 Security Issues in Flex-WPS.</li>
# <li>$user_profile->[22] Security Issues found.</li>
# </ul>
# </div>
# </div>);
$brzimg = qq(<tr height="50">
<td class="bg6"><b>$msg{metals}</b></td>
<td align="left" bgcolor="#666666" valign="top" width="320">
$brzimg$silvimg$gldimg$achive$legion$destsev$honor<div style="clear: left"> </div>
$combat$marks$navy$servc$valor$dessev$super</td>
</tr>);

# Ribbons
  my $rbimg = qq(<img src="$cfg{imagesurl}/ribbons/ProgRibbon_0.gif" style="border: none;" alt="">);
if ($cp{rib}) {
     $rbimg = qq(<img src="$cfg{imagesurl}/ribbons/ProgRibbon_1.gif" style="border: none;" alt="">);
}
  my $rb2img = qq(<img src="$cfg{imagesurl}/ribbons/CrackRibbon_0.gif" style="border: none;" alt="">);
if ($cp{rib2}) {
     $rb2img = qq(<img src="$cfg{imagesurl}/ribbons/CrackRibbon_1.gif" style="border: none;" alt="">);
}
  my $rb3img = qq(<img src="$cfg{imagesurl}/ribbons/WebRibbon_0.gif" style="border: none;" alt="">);
if ($cp{rib3}) {
     $rb3img = qq(<img src="$cfg{imagesurl}/ribbons/WebRibbon_1.gif" style="border: none;" alt="">);
}
$rbimg = qq(<tr>
<td class="bg6"><b>$msg{ribbon}</b></td>
<td align="center" bgcolor="#666666">$rbimg &nbsp;$rb2img &nbsp;$rb3img</td>
</tr>);

# voter image =D
$vote_image = qq(<img src="$cfg{imagesurl}/smilies/grumpy.gif" border="0" alt="">) if ($neg_vote >= $pos_vote && $neg_vote >= $poll_votes);
$vote_image = qq(<img src="$cfg{imagesurl}/smilies/deepthought.gif" border="0" alt="">) if ($poll_votes >= $pos_vote && $poll_votes >= $neg_vote);
$vote_image = qq(<img src="$cfg{imagesurl}/smilies/respect.gif" border="0" alt="">) if ($pos_vote >= $neg_vote && $pos_vote >= $poll_votes);

$pos_vote = "++$pos_vote <b>vs</b> --$neg_vote, <b>polls</b>($poll_votes) <b>total</b>($vtotal) $vote_image";

       my $web_link = '';
       if ($cp{website} && $cp{website_url} && $cp{website_url} ne 'http://') { $web_link = qq(<a href="$cp{website_url}" target="_blank">$cp{website}</a>); }
       elsif (!$cp{website} && $cp{website_url} && $cp{website_url} ne 'http://') { $web_link = qq(<a href="$cp{website_url}" target="_blank">$cp{website_url}</a>); }
        print <<HTML;
</td>
</tr>
<tr>
<td>
<table border="0" class="navtable" width="500">
<tr>
<td class="bg6" width="46"><b>$msg{nameC}</b></td>
<td>$cp{nick}</td>
</tr>
$gen1
$flag
<tr>
<td class="bg6" width="46"><b>$msg{emailC}</b></td>
<td>$protected_email</td>
</tr>
<tr>
<td class="bg6"><b>$msg{websiteC}</b></td>
<td>$web_link</td>
</tr>
$icq_link
$yahoo_link
$aim_link
$msnm_link
$skype_link
<tr>
<td class="bg6"><b>Experience</b></td>
<td>$cp{forum_posts}</td>
</tr>
<tr valign="baseline">
<td class="bg6"><b>Votes Used</b></td>
<td>$pos_vote</td>
</tr>
<tr>
<td class="bg6"><b>Profile Views</b></td>
<td>$cp{views}</td>
</tr>
<tr>
<td class="bg6"><b>$msg{member_sinceC}</b></td>
<td>$formatted_date</td>
</tr>
<tr>
<td valign="top"><b>$msg{pictureC}</b></td>
<td align="center">$member_pic</td>
</tr>
<tr>
<td valign="top"><b>Signature</b></td>
<td height="25">$cp{signature}</td>
</tr>
<tr>
<td class="bg6"><b>$msg{statusC}</b></td>
<td bgcolor="#666666"><font color="#FFFFFF">&nbsp;&nbsp;$status</font></td>
</tr>
<tr>
<td class="bg6"><b>$msg{rankC}</b></td>
<td bgcolor="#666666"><font color="#FFFFFF">&nbsp;&nbsp;$member_info</font></td>
</tr>
$brzimg
$rbimg
$bgbadge
</table>
</td>
</tr>
</table>
HTML

        theme::print_html($user_data{theme}, $nav{send_im}, 1);
}

=head2 edit_profile()

 Display formular to edit user's profile.

=cut

sub edit_profile
{
# Check if user is logged in.
if ($user_data{uid} eq $usr{anonuser}) {
 require error;
 error::user_error($err{bad_input}, $user_data{theme});
}
if (!$username) {
$username = $user_data{id};
}
# Check if user has permissions to edit other user's profile.
if ($user_data{id} ne $username && $user_data{sec_level} ne $usr{admin}) {
 require error;
 error::user_error($err{auth_failure}, $user_data{theme});
 }

# Get current user profile.
my @user_profile = ();
#my $query1 = "SELECT * FROM members WHERE memberid='$username'";

#my $query1 = "SELECT * FROM members WHERE memberid='$username' AND approved='1'";
#$query1 = "SELECT * FROM members WHERE memberid='$username'" if ($user_data{sec_level} eq $usr{admin});
        my $query1 = '';
        $query1 = "SELECT * FROM members WHERE memberid='$username' AND approved='1' LIMIT 0 , 30" if $username =~ /\A\d+\z/;
        $query1 = "SELECT * FROM members WHERE memberid='$username' LIMIT 0 , 30" if ($user_data{sec_level} eq $usr{admin} && $username =~ /\A\d+\z/);
        $query1 = "SELECT * FROM members WHERE uid = '$username' AND approved='1' LIMIT 0 , 30" if $username !~ /\A\d+\z/;
        $query1 = "SELECT * FROM members WHERE uid = '$username' LIMIT 0 , 30" if ($user_data{sec_level} eq $usr{admin} && $username !~ /\A\d+\z/);

my $sth = $dbh->prepare($query1);
$sth->execute() || die("Couldn't exec sth!");
 while(my @row = $sth->fetchrow) {
if ($row[0]) {
@user_profile = (
 "$row[0]","$row[1]","$row[2]","$row[3]","$row[4]","$row[5]",
 "$row[6]","$row[7]","$row[8]","$row[9]","$row[10]","$row[11]",
 "$row[12]","$row[13]","$row[14]","$row[15]","$row[16]","$row[17]",
 "$row[18]","$row[19]","$row[20]","$row[21]","$row[22]","$row[23]",
 "$row[24]","$row[25]","$row[26]","$row[27]","$row[28]");
 }
 }
$sth->finish();

      my $signature = $user_profile[7] || '';
      #$signature =~ s/\&\&/\n/g;
      # little fix
      if ($user_profile[6] =~ /(http|https):\/\//) {
      }
      else {
      $user_profile[6] = 'http://';
      }

      # Gender
      my $gen_im = "_nopic.gif";
      my $genlist = '';
      my $male = "<option value=\"$msg{male}\">$msg{male}</option>";
      my $female = "<option value=\"$msg{female}\">$msg{female}</option>";
      my $non = "<option value=\"_nopic\">$msg{non}</option>";
#if ($user_profile->[21] && $user_profile->[21] =~ /($msg{male}|$msg{female})$/) {
if ($user_profile[21] =~ /$msg{male}$/) {
$genlist =
      qq($non <option value="$msg{male}" selected="selected">$msg{male}</option> $female\n);
$gen_im = "$msg{male}.gif";
}
elsif ($user_profile[21] =~ /$msg{female}$/) {
$genlist =
      qq($non $male<option value="$msg{female}" selected="selected">$msg{female}</option>\n);
$gen_im = "$msg{female}.gif";
}
else {
$genlist = "<option value=\"_nopic\" selected=\"selected\">$msg{non}</option>" . $male . $female;
}
                #require HTML_TEXT;
                #$signature = HTML_TEXT::html_to_text($signature);
                $signature = $AUBBC_mod->html_to_text($signature);
require theme;
theme::print_header();
theme::print_html($user_data{theme}, $nav{edit_profile});

        print <<HTML;
<table border="0" cellspacing="1">
<tr>
<td><form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="creator">
<table border="0">
<tr>
<td><b>$msg{usernameC}</b></td>
<td><input type="hidden" name="username" value="$user_profile[2]"><b>$user_profile[2]</b></td>
</tr>
<tr>
<td><b>$msg{gender}</b></td>
<td><select name="gen" onChange="document.images['gender'].src = '$cfg{imagesurl}/' + this.value + '.gif';" >
$genlist</select>&nbsp;<img src="$cfg{imagesurl}/$gen_im" name="gender">
</td>
</tr>
<tr>
<td><b>$msg{passwordC}</b></td>
<td><input type="password" name="password1" size="20" value="$user_profile[1]">*</td>
</tr>
<tr>
<td><b>$msg{passwordC}</b></td>
<td><input type="password" name="password2" size="20" value="$user_profile[1]">*</td>
</tr>
<tr>
<td><b>$msg{nameC}</b></td>
<td><input type="text" name="nick" size="40" value="$user_profile[3]">*</td>
</tr>
<tr>
<td><b>$msg{emailC}</b></td>
<td><input type="text" name="email" size="40" value="$user_profile[4]">*</td>
</tr>
<tr>
<td><b>$msg{websiteC}</b></td>
<td><input type="text" name="website" size="40" value="$user_profile[5]"></td>
</tr>
<tr>
<td><b>$msg{urlC}</b></td>
<td><input type="text" name="website_url" size="40" value="$user_profile[6]"></td>
</tr>
<tr>
<td><b>$msg{icqC}</b></td>
<td><input type="text" name="icq" size="40" value="$user_profile[15]"></td>
</tr>
<tr>
<tr>
<td><b>Yahoo:</b></td>
<td><input type="text" name="yahoo" size="40" value="$user_profile[16]"></td>
</tr>
<tr>
<tr>
<td><b>AIM:</b></td>
<td><input type="text" name="aim" size="40" value="$user_profile[17]"></td>
</tr>
<tr>
<tr>
<td><b>MSNM:</b></td>
<td><input type="text" name="msnm" size="40" value="$user_profile[18]"></td>
</tr>
<tr>
<tr>
<td><b>Skype:</b></td>
<td><input type="text" name="skype" size="40" value="$user_profile[19]"></td>
</tr>
<tr>
<td><b>Country Flag:</b></td>
<td><select name="flag" onChange="document.images['user_flag'].src = '$cfg{imagesurl}/flags/' + this.value;" >
HTML

#selected="selected"
# $cfg{flagdbdir} = "$cfg{modulesavedir}/flags";
# my $flags = &file2array("$cfg{flagdbdir}/flags.dat", 1);
 my $flag_im = 'blank.gif';
# foreach (@{$flags}) {
#    my ($flag_img, $flag_nm) = split(/\|/, $_);
$query1 = "SELECT * FROM flags";
$sth = $dbh->prepare($query1);

$sth->execute || die("Couldn't exec sth!");
while(my @flags = $sth->fetchrow)  {
   if ($user_profile[20] && $user_profile[20] eq $flags[1]) {
      print
      qq(<option value="$flags[1]" selected="selected">$flags[2]</option>\n);
      $flag_im = $flags[1];
   }
   elsif ($flags[1]) {
      print
      qq(<option value="$flags[1]">$flags[2]</option>\n);
   }
 }
$sth->finish();
    print <<HTML;
 </select>&nbsp;<img src="$cfg{imagesurl}/flags/$flag_im" width="32" height="20" name="user_flag">
 </td>
 </tr>
<tr>
<td valign="top"><b>$msg{signatureC}</b></td>
<td><textarea name="signature" rows="4" cols="35" wrap="virtual">$signature</textarea></td>
</tr>
<tr>
<td valign="top"><b>$msg{themeC}</b></td>
<td>
HTML

# <select name="theme">
# Get list of installed themes.
# my $themes = dir2array($cfg{themesdir});
#
# foreach (sort @{$themes})
# {
#  if ($_ eq '.' || $_ eq '..') { next; }
#
#     my ($theme_name, $extension) = split (/\./, $_);
#        if (!$extension)
#           {
#           if ($user_profile->[13] eq $theme_name)
#              {
#              print
#                   qq(<option value="$theme_name" selected>$theme_name</option>\n);
#              }
#              else
#              {
#               print qq(<option value="$theme_name">$theme_name</option>\n);
#               }
#              }
#         } </select>

        print <<HTML;
</td>
</tr>
HTML

        # Get available avatars.
        my @avatars = ();
$sth = "SELECT * FROM avatars";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
if(!@avatars) {
@avatars = ("$row[1]");
}
else {
@avatars = (@avatars,"$row[1]");
}
 }
$sth->finish();

        my ($images, $checked, $pic_name, $pic, $http) = ('', '', '', '', '');

        if (!$user_profile[9]) {
        $user_profile[9] = "_nopic.gif";
        }
        if ($user_profile[9] =~ m~\A$cfg{imagesurl}\/\bavatars\b\/(.*?)$~) {
           $user_profile[9] = $1;
        }

       if(@avatars) {
        foreach my $shit (sort @avatars) {
                my ($name, $extension) = split (/\./, $shit);
                #$extension = lc($extension);

                if ($shit eq $user_profile[9] || ($user_profile[9] =~ m~\Ahttp://~ && $shit eq '')) {
                $checked = ' selected';
                }

                if ($extension =~ m![gif|jpg|jpeg|png|GIF|JPG|JPEG|PNG]$!i) {
                        if ($shit eq '_nopic.gif') {
                                $pic  = "_nopic.gif";
                                $name = $msg{no_picture};
                        }
                        $images .= qq(<option$checked value="$shit">$name</option>\n);
                        $checked = '';
                }
        }
        }
        if ($user_profile[9] =~ m/http:\/\//) {
                $pic     = $user_profile[9];
                $checked = ' checked';
                $http    = $user_profile[9];
        }
        else {
                $pic  = $cfg{imagesurl} . '/avatars/' . $user_profile[9];
                $http = 'http://';
        }

        print <<HTML;
<tr>
<td valign="top"><b>$msg{pictureC}</b></td>
<td valign="top">
<table>
<tr>
<td>$msg{use_standard_picC}</td>
</tr>
<tr>
<td><script language="javascript" type="text/javascript">
<!--
function showImage() {
document.images.avatars.src="$cfg{imagesurl}/avatars/"+document.creator.member_pic.options[document.creator.member_pic.selectedIndex].value;
}
// -->
</script>
<select name="member_pic" onChange="showImage()" size="6">
$images</select>
<img src="$pic" name="avatars" border="0" hspace="15"></td>
</tr>
<tr>
<td>$msg{use_own_pictureC}</td>
</tr>
<tr>
<td><input type="checkbox" name="member_pic_personal_check"$checked>
<input type="text" name="member_pic_personal" size="40" value="$http"><br>
$msg{pic_message}</td>
</tr>
</table>
</td>
</tr>
<tr>
<td valign="top"><b>$msg{subscribe_to}</b></td>
<td><table border="0" cellspacing="1">
<tr>
<td width="33%" align="center"><b>$nav{articles}</b></td>
<td width="33%" align="center"><b>$nav{forums}</b></td>
<td width="33%" align="center"><b>$nav{links}</b></td>
</tr>
<tr>
HTML
#
#         # Print subscription box for articles.
#         my $topic_cats = file2array("$cfg{topicsdir}/cats.dat", 1);
#         print
#             qq(<td width="33%" align="center"><select name="topics_subscr" size="5" multiple>);
#         foreach (@{$topic_cats})
#         {
#                 my @item = split (/\|/, $_);
#                 my $topic_subscribed = file2array("$cfg{topicsdir}/$item[1].im", 1);
#                 my $selected =
#                     (grep { $_ eq $user_data{uid} } @{$topic_subscribed})
#                     ? ' selected'
#                     : '';
#                 print qq(<option value="$item[1]"$selected>$item[0]</option>\n);
#         }
#         print '</select></td><td width="33%" align="center">';
#
#         # Print subscription box for forums.
#         my $forum_cats = file2array("$cfg{boardsdir}/cats.txt", 1);
#         print qq(<select name="boards_subscr" size="5" multiple>);
#         foreach (@{$forum_cats})
#         {
#                 my $cat_info         = file2array("$cfg{boardsdir}/$_.cat",  1);
#                 my $board_subscribed = file2array("$cfg{boardsdir}/$_.im", 1);
#                 my $selected         =
#                     (grep { $_ eq $user_data{uid} } @{$board_subscribed})
#                     ? ' selected'
#                     : '';
#                 print qq(<option value="$_"$selected>$cat_info->[0]</option>\n);
#         }
#         print '</select></td><td width="33%" align="center">';
#
#         # Print subscription box for links.
#         my $links_cats = file2array("$cfg{linksdir}/linkcats.dat", 1);
#         print qq(<select name="links_subscr" size="5" multiple>);
#         foreach (@{$links_cats})
#         {
#                 my @item = split (/\|/, $_);
#                 my $link_subscribed = file2array("$cfg{linksdir}/$item[1].im", 1);
#                 my $selected =
#                     (grep { $_ eq $user_data{uid} } @{$link_subscribed})
#                     ? ' selected'
#                     : '';
#                 print qq(<option value="$item[1]"$selected>$item[0]</option>\n);
#         }
#         print '</select></td>';

        print <<HTML;
<td></td>
</tr>
</table></td>
</tr>
HTML

        # Print actions for admins.
        if ($user_data{sec_level} eq $usr{admin}) {
                my $pos       = '';
                my @userlevel = ($usr{admin}, $usr{mod}, $usr{user});

                if (!$user_profile[8]) {
                        foreach (@userlevel[0 .. 2]) {
                                $pos =
                                    ($user_profile[8] eq $_)
                                    ? qq($pos<option value="$_" selected>$_</option>\n)
                                    : qq($pos<option value="$_">$_</option>\n);
                        }
                        #$pos = qq($pos<option value="" selected>$userlevel[2]</option>\n);
                }
                else {
                        foreach (@userlevel[0 .. 2]) {
                                $pos =
                                    ($user_profile[8] eq $_)
                                    ? qq($pos<option value="$_" selected>$_</option>\n)
                                    : qq($pos<option value="$_">$_</option>\n);
                        }
                        #$pos = qq($pos<option value="">$userlevel[2]</option>\n);
                }

                print <<HTML;
<tr>
<td><b>XP</b></td>
<td><input type="text" name="forum_posts" size="4" value="$user_profile[11]"></td>
</tr>
<tr>
<td><b>Votes</b></td>
<td><input type="text" name="topic_posts" size="4" value="$user_profile[12]"></td>
</tr>
<tr>
<td><b>Vote date</b></td>
<td><input type="text" name="comments" size="4" value="$user_profile[13]"></td>
</tr>
<tr>
<td><b>$msg{bugbadge}</b></td>
<td><input type="text" name="bugbadge" size="4" value="$user_profile[22]"></td>
</tr>
<tr>
<td><b>Votes Used</b></td>
<td><input type="text" name="gold" size="4" value="$user_profile[23]"></td>
</tr>
<tr>
<td><b>View Count</b></td>
<td><input type="text" name="silver" size="4" value="$user_profile[24]"></td>
</tr>
<tr>
<td><b>??</b></td>
<td><input type="text" name="bronze" size="4" value="$user_profile[25]"></td>
</tr>
<tr>
<td><b>Buddys</b></td>
<td><input type="text" name="rib" size="4" value="$user_profile[26]"></td>
</tr>
<tr>
<td><b>Active User</b></td>
<td><input type="text" name="rib2" size="4" value="$user_profile[27]"></td>
</tr>
<tr>
<td><b>IP Security</b></td>
<td><input type="text" name="rib3" size="4" value="$user_profile[28]"></td>
</tr>
<tr>
<td><b>Status</b></td>
<td><select name="sec_level">
$pos</select></td>
</tr>
<tr>
<td colspan="2">* $msg{required_fields}</td>
</tr>
<tr>
<td colspan="2"><input type="hidden" name="joined" value="$user_profile[10]">
<input type="hidden" name="forum_posts" value="$user_profile[11]">
<input type="hidden" name="topic_posts" value="$user_profile[12]">
<input type="hidden" name="comments" value="$user_profile[13]">
HTML
        }
        else {
                print <<HTML;
<tr>
<td colspan="2">* $msg{required_fields}</td>
</tr>
<tr>
<td colspan="2">
HTML
        }

        print <<HTML;
<input type="hidden" name="op" value="edit_profile2">
<input type="submit" name="modify" value="$btn{edit_profile}">
<input type="submit" name="delete" value="$btn{delete_profile}" onclick="javascript:return confirm('Are you sure you want to Delete This Member?')">
</td>
</tr>
</table>
</form>
</td>
</tr>
</table>
HTML

        theme::print_html($user_data{theme}, $nav{edit_profile}, 1);
}

=head2 edit_profile2()

 Update user's profile.

=cut

sub edit_profile2 {

        # Check if user is logged in.
        if ($user_data{uid} eq $usr{anonuser}) {
                require error;
                error::user_error($err{bad_input}, $user_data{theme});
        }

        if (!$username) {
        $username = $user_data{uid};
        }

        if ($username ne $user_data{uid} && $user_data{sec_level} ne $usr{admin}) {
             require error;
             error::user_error($err{bad_username}, $user_data{theme});
        }

        # Get current user profile.
        require filters;
        $username = filters::untaint2($username);
        if (!$username) {
        require error;
        error::user_error($err{bad_input}, $user_data{theme});
        }
# Get current user profile.
my @user_profile = ();
#my $query1 = "SELECT * FROM members WHERE uid='$username'";

        my $query1 = "SELECT * FROM members WHERE uid='$username' AND approved='1'";
        $query1 = "SELECT * FROM members WHERE uid='$username'" if ($user_data{sec_level} eq $usr{admin});

my $sth = $dbh->prepare($query1);
$sth->execute() || die("Couldn't exec sth!");
 while(my @row = $sth->fetchrow) {
if ($row[0]) {
@user_profile = (
 "$row[0]","$row[1]","$row[2]","$row[3]","$row[4]","$row[5]",
 "$row[6]","$row[7]","$row[8]","$row[9]","$row[10]","$row[11]",
 "$row[12]","$row[13]","$row[14]","$row[15]","$row[16]","$row[17]",
 "$row[18]","$row[19]","$row[20]","$row[21]","$row[22]","$row[23]",
 "$row[24]","$row[25]","$row[26]","$row[27]","$row[28]"); }
 }
$sth->finish();
# No data error
if (!@user_profile) {
require error;
error::user_error($err{bad_input}, $user_data{theme});
}
        # Update user profile.
        if ($modify ne '') {

                # Password validation.
                if ($password1 ne $password2) {
                     require error;
                     error::user_error($err{verify_pass}, $user_data{theme});
                }
                if (!$password1) {
                require error;
                error::user_error($err{enter_pass}, $user_data{theme});
                }

                my $password;
                if ($password1 eq $user_profile[1]) {
                $password = $user_profile[1];
                }
                else {
                # $password = crypt($password1, substr($username, 0, 2));
                use Digest::SHA1 qw(sha1_hex);
                $password = sha1_hex($password1, $username); # Better SHA1
                }
                 #/^[0-9A-Za-z#%+,-\.:=?@^_ ]+$/
                # Nickname validation.
#                 if ($username eq $usr{sadmin} && $nick ne $usr{sfadmin}) {
#                 require error; error::user_error($err{no_edit_name}, $user_data{theme});
#                 }

                if (!$nick) {
                require error;
                error::user_error($err{enter_nick}, $user_data{theme});
                }
                if ($user_data{sec_level} eq $usr{admin}) { # Administrator can Edit other user profiles.
                }
                elsif ($nick !~ m!^([0-9A-Za-z_\ ]+)$!i
                        || $nick =~ /^[\.+\/\\\*\?\~\^\$\@\%\`\"\'\&\;\|\<\>\x00-\x1F]$/
                        || length($nick) < 2
                        || length($nick) > 12
                        || $nick eq $usr{admin}
                        || $nick eq $usr{mod}
                        || $nick eq $usr{user}
                        || $nick eq $usr{anonuser}
                        || $nick eq $usr{sadmin}
                        || $nick eq $usr{sfadmin}) {
                        require error;
                        error::user_error($err{bad_input}, $user_data{theme});
                }

                # Email validation.
                if (!$email) {
                user_error($err{enter_email}, $user_data{theme});
                }
                if ($email !~ /^[0-9A-Za-z@\._\-]+$/
                        || $email =~ /(@.*@)|(\.\.)|(@\.)|(\.@)|(^\.)|(\.$)/) {
                        require error;
                        error::user_error($err{bad_input}, $user_data{theme});
                }

                # Picture validation.
                if ($member_pic_personal_check &&
                        ($member_pic_personal =~
                        m/(\.gif|\.jpg|\.jpeg|\.png|\.GIF|\.JPG|\.JPEG|\.PNG)$/i)) {
                        $member_pic = $member_pic_personal;
                }
                elsif (!$member_pic) { $member_pic = $user_profile[9]; }
                #else { $member_pic = "$cfg{imagesurl}/avatars/$member_pic"; }

                if ($member_pic &&
                        $member_pic !~ m^\A[0-9a-zA-Z_\.\#\%\-\:\+\?\$\&\~\.\,\@/]+\Z^)
                {
                       require error; error::user_error('$err{bad_input}', $user_data{theme});
                }

                # Signature.
                if (!$signature) { $signature = $msg{default_sig}; }
#                 if ($signature !~ ' ' && length($signature) > 50)
#                 {
#                  $signature = substr($signature, 0, 50);
#                 } elsif (length($signature) > 80) {
#                  $signature = substr($signature, 0, 80);
#                 }
                require HTML_TEXT;
                #$signature =~ s/\n/\&\&/g;
                $signature =~ s/\r//g;
                $signature = HTML_TEXT::html_escape($signature);

                # Site URL Check
                if ($website_url =~ /^(http|https):\/\// || $user_profile[6] =~ /^(http|https):\/\//) {
                $website_url =~ s/ .*//gs;
                $website_url =~ s/\"//gs;
                $website_url =~ s/\'//gs;
                $website_url =~ s/\)//gs;
                $website_url =~ s/\(//gs;
                $website_url =~ s/\%//gs;
                $website_url =~ s/\<//gs;
                $website_url =~ s/\>//gs;
                } else { $website_url = ''; }
                if ($website) {
                $website =~ s/\"//gs;
                $website =~ s/\%//gs;
                $website =~ s/\'//gs;
                $website =~ s/\)//gs;
                $website =~ s/\(//gs;
                $website =~ s/\<//gs;
                $website =~ s/\>//gs;
                } else { $website = ''; }

                # ICQ
                if ($icq && $icq !~ m!^([0-9]+)$!i) { $icq = ''; }
                # YAHOO
                if ($yahoo && $yahoo !~ m!^([0-9A-Za-z\_\-]+)$!i) { $yahoo = ''; }
                # MSNM
                if ($msnm && $msnm =~ /[0-9A-Za-z\_\-]\@(msn|hotmail|passport)\.com$/) { }
                else {  $msnm = ''; }
                # AIM
                if ($aim && $aim !~ m!^([0-9A-Za-z\_\-]+)$!i) { $aim = ''; }
                # SKYPE
                if ($skype && $skype !~ m!^([0-9A-Za-z\_\-]+)$!i) { $skype = ''; }

                # flag
                if ($flag && $flag =~ /[a-z]\.gif$/) { }
                else {  $flag = 'blank.gif'; }

                # Gender
                if ($gen && $gen =~ /^($msg{male}|$msg{female})$/) { }
                else {  $gen = ''; }

                # Check if user has permissions to modify security level and post count.
                if ($user_data{sec_level} ne $usr{admin})
                {
                        $sec_level   = $user_profile[8];
                        $joined      = $user_profile[10];
                        $forum_posts = $user_profile[11];
                        $topic_posts = $user_profile[12];
                        $comments    = $user_profile[13];
                        $bugbadge    = $user_profile[22];
                        $gold    = $user_profile[23];
                        $silver    = $user_profile[24];
                        $bronze    = $user_profile[25];
                        $rib    = $user_profile[26];
                        $rib2    = $user_profile[27];
                        $rib3    = $user_profile[28];
                }
                # Bug Badge
                #if ($bugbadge && $bugbadge !~ m!^([0-9]+)$!i) { $bugbadge = ''; }

                if ($member_pic eq '_nopic.gif') { $member_pic = ''; }
                if (!$forum_posts) { $forum_posts = 0; }
                if (!$topic_posts) { $topic_posts = 0; }
                if (!$comments)    { $comments    = 0; }
                if (!$theme)    { $theme    = 'standard'; }
# Write profile.
my $sql = qq(UPDATE `members` SET `password` = '$password',
`nick` = '$nick',
`email` = '$email',
`website` = '$website',
`websiteurl` = '$website_url',
`signature` = '$signature',
`seclevel` = '$sec_level',
`memberpic` = '$member_pic',
`joined` = '$joined',
`xp` = '$forum_posts',
`votes` = '$topic_posts',
`next_votes` = '$comments',
`theme` = '$theme',
`icq` = '$icq',
`yahoo` = '$yahoo',
`aim` = '$aim',
`msnm` = '$msnm',
`skype` = '$skype',
`flag` = '$flag',
`gen` = '$gen',
`bugbadge` = '$bugbadge',
`votes_used` = '$gold',
`view_ct` = '$silver',
`date_expire` = '$bronze',
`rib` = '$rib',
`approved` = '$rib2',
`admin_ip` = '$rib3' WHERE `uid` ='$username' LIMIT 1 ;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);
                # Update article subscriptions.
                #use lib 'flex-lib';
                # require PM_EMAIL;
#                 my $tcats = file2array("$cfg{topicsdir}/cats.dat", 1);
#                 foreach (@{$tcats})
#                 {
#                         my (undef, $link) = split (/\|/, $_);
#                         my $file = ($link =~ /^([\w.]+)$/) ? $1 : next;
#                         if (grep { $_ eq $file } $query->param('topics_subscr'))
#                         {
#                                &PM_EMAIL::update_subscriptions("$cfg{topicsdir}/$file.mail", $email, 1);
#                                 #update_subscriptions("$cfg{topicsdir}/$file.mail", $email, 1);
#                         }
#                         if (!(grep { $_ eq $file } $query->param('topics_subscr')) &&
#                                 -w "$cfg{topicsdir}/$file.mail")
#                         {
#                                 &PM_EMAIL::update_subscriptions("$cfg{topicsdir}/$file.mail", $email, 0);
#                                 #update_subscriptions("$cfg{topicsdir}/$file.mail", $email, 0);
#                         }
#                 }
#
#                 # Update forums subscriptions.
#                 my $fcats = file2array("$cfg{boardsdir}/cats.txt", 1);
#                 foreach (@{$fcats})
#                 {
#                         my $file = ($_ =~ /^([\w.]+)$/) ? $1 : next;
#                         if (grep { $_ eq $file } $query->param('boards_subscr'))
#                         {
#                                 &PM_EMAIL::update_subscriptions("$cfg{boardsdir}/$file.mail", $email, 1);
#                                 #update_subscriptions("$cfg{boardsdir}/$file.mail", $email, 1);
#                         }
#                         if (!(grep { $_ eq $file } $query->param('boards_subscr')) &&
#                                 -w "$cfg{boardsdir}/$file.mail")
#                         {
#                                 &PM_EMAIL::update_subscriptions("$cfg{boardsdir}/$file.mail", $email, 0);
#                                 #update_subscriptions("$cfg{boardsdir}/$file.mail", $email, 0);
#                         }
#                 }
#
#                 # Update links subscriptions.
#                 my $lcats = file2array("$cfg{linksdir}/linkcats.dat", 1);
#                 foreach (@{$lcats})
#                 {
#                         my (undef, $link) = split (/\|/, $_);
#                         my $file = ($link =~ /^([\w.]+)$/) ? $1 : next;
#                         if (grep { $_ eq $file } $query->param('links_subscr'))
#                         {
#                                 &PM_EMAIL::update_subscriptions("$cfg{linksdir}/$file.mail", $email, 1);
#                                 #update_subscriptions("$cfg{linksdir}/$file.mail", $email, 1);
#                         }
#                         if (!(grep { $_ eq $file } $query->param('links_subscr')) &&
#                                 -w "$cfg{linksdir}/$file.mail")
#                         {
#                                 &PM_EMAIL::update_subscriptions("$cfg{linksdir}/$file.mail", $email, 0);
#                                 #update_subscriptions("$cfg{linksdir}/$file.mail", $email, 0);
#                         }
#                 }

                if ($user_data{uid} eq $username) {

                my $session_exp = CGI::Util::expire_calc($cfg{cookie_expire},'');
                my $date = CGI::Util::expire_calc('now','');
                $password = $password . $username . $session_exp;
                # This makes any stolen cookies usless! - Shaka_Flex
                my $host = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || '';
                $password = sha1_hex($password, $host);

                # Add new session
                my $sql_code = qq(UPDATE `auth_session` SET `session_id` = '$password', `expire_date` = '$session_exp' , `date` = '$date' WHERE user_id = '$user_data{id}');
                SQLEdit::SQLAddEditDelete($sql_code);

                # Set the cookie.
                use CGI::Cookie;
                my $cookie_password = new CGI::Cookie(
                        -name     => 'ID',
                        -value    => $password,
                        -expires  => $cfg{cookie_expire},
                        -httponly => 1,
                    );
#                         my $cookie_password = $query->cookie(
#                                 -name    => 'CartID2',
#                                 -value   => $password,
#                                 -path    => '/',
#                                 -expires => $cfg{cookie_expire}
#                             );

                        # Redirect to the welcome page.
                        print $query->redirect(
                                -location => $cfg{pageurl} . '/index.' . $cfg{ext} .
                                '?op=view_profile',
                                -cookie => $cookie_password,
                            );
                }
                else
                {
                $username = $user_profile[0];
                        print $query->redirect(
                                -location => $cfg{pageurl} . '/index.' . $cfg{ext} .
                                '?op=view_profile;username=' . $username);
                }
        }

        # Delete user.
        elsif ($delete ne '')
        {
my $sql = qq(DELETE FROM `members` WHERE `uid` = '$username' LIMIT 1;);
require SQLEdit;
SQLEdit::SQLAddEditDelete($sql);

# fix last registered
my $last_member = '';
$query1 = "SELECT `uid` FROM members ORDER BY `joined` DESC LIMIT 1 ;";
my $sth = $dbh->prepare($query1);
$sth->execute() || die("Couldn't exec sth!");
 while(my @row = $sth->fetchrow) {
if ($row[0]) {
 $last_member = $row[0];
}
 }
$sth->finish();

$sql = qq(UPDATE `whosonline` SET `membercount` =membercount - 1,`lastregistered` = '$last_member' WHERE `id` ='1' LIMIT 1 ;);
SQLEdit::SQLAddEditDelete($sql);

$dbh->disconnect();
                if ($user_data{uid} eq $username)
                {

                        # Empty cookie values.
                        my $cookie_username = $query->cookie(
                                -name    => 'ID',
                                -value   => '',
                                -path    => '/',
                                -expires => 'now'
                            );

                        # Redirect to the logout page.
                        print $query->redirect(
                                -location => $cfg{pageurl} . '/index.' . $cfg{ext} ,
                                -cookie => $cookie_username,
                            );

                }
                else
                {
                        print $query->redirect(
                                -location => $cfg{pageurl} . '/index.' . $cfg{ext});
                }
        }
        else { require error; error::user_error($err{bad_input}, $user_data{theme}); }
}
1;
