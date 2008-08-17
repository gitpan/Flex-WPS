package forum_home;

# SELECT * FROM pmin WHERE memberid='$user_data{id}'
# ORDERBY date DESC


use strict;
# Assign global variables.
use vars qw(
    %user_data $dbh
    %usr %cfg %msg
    %sub_action %nav $AUBBC_mod
    );
use exporter;

%sub_action = ( last_posts => 1 );
# working
sub last_posts {

my ($post_msg, $last_date) = ('','');
my @messages = ();
#my $num_shown = 0;
# mySQL Query works
# WOOT mySQL!!!
my $query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' AND forum_cat.sec_level = '$usr{anonuser}' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};";
  }
  my $row_color = qq( class="tbl_row_dark");
my $sth = $dbh->prepare($query1);
$sth->execute || return;
while(my @row = $sth->fetchrow)  {
if($row[13]) { $last_date = $row[13]; }
else { $last_date = $row[5]; }

                $row_color =
                    ($row_color eq qq( class="tbl_row_dark"))
                    ? qq( class="tbl_row_light")
                    : qq( class="tbl_row_dark");

my $cat_type = '';
# my $catname = $row[18];
$cat_type = $row[$#row] if $row[$#row];

                if (!$row[8]) {
                # Check if thread is hot or not.
                my $type;
                if ($row[3] <= 2) { $type = "off"; }
                if ($row[3] > 2 || $row[4] >= 10) { $type = "on"; }
                if ($row[3] >=10 || $row[4] >= 25) { $type = "thread"; }
                if ($row[3] >= 15 || $row[4] >= 75)  { $type = "hotthread"; }
                if ($row[3] >= 25 || $row[4] >= 100) { $type = "veryhotthread"; }
                if ($row[7]) { $type = "locked"; }
                #if(!$type) { $type = "thread"; }

                # Thread page navigator.
                my $num_messages = $row[3] + 1;
                my $count        = 0;
                my $pages = '';
                if ($num_messages > $cfg{max_items_per_page})
                {
                        while ($count * $cfg{max_items_per_page} < $num_messages)
                        {
                                my $view = $count + 1;
                                my $strt = ($count * $cfg{max_items_per_page});
                                if($strt) { $strt -= 1; }
                                $pages .=
                                    qq( [<a href="$cfg{pageurl}/index.$cfg{ext}?op=threads;module=Forum;cat=$row[1];subcat=$row[2];thread=$row[0];start=$strt;sticky=$cat_type">$view</a>]);
                                $count++;
                        }

                       # $pages =~ s/\n$//g;
                        $pages =
                            qq(( <img src="$cfg{imagesurl}/forum/multipage.gif" alt=""> $pages ));
                }

             #   my $unseen = '';
                my $new = qq(<img src="$cfg{imagesurl}/forum/off.gif" alt="">);
#                 if ($unseen)
#                         {
#                                 $new = qq(<img src="$cfg{imagesurl}/forum/on.gif" alt="">);
#                         }
                my $last_post = $row[14];
                if($last_post ne 'Self') {
                #$last_post =~ s/\|/\,/gso;
                $last_post =~ s/(.*?)\,(.*?)\,(.*?)\,(.*?)\,(.*?)$//i;
                #my ($dt, $lcat, $lsubcat, $lthread, $lposter) = split (/\|/, $_);
                require DATE_TIME;
                my $format_dt = DATE_TIME::format_date($1, 2);
                $last_post = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=threads;module=Forum;cat=$2;subcat=$3;sticky=$cat_type;thread=$4">$format_dt</a><br>$msg{by} $5);
                } else {
                $last_post = qq(No Replies/ Edited);
                }
                my $subject = $row[11];
                #use UBBC;
                #$subject = UBBC::do_smileys($subject);
                $AUBBC_mod->settings( for_links => 1 );
                $subject = $AUBBC_mod->do_all_ubbc($subject);
                $AUBBC_mod->settings( for_links => 0 );
                $post_msg .= <<HTML;
<tr$row_color>
<td width="16"><img src="$cfg{imagesurl}/forum/$type.gif" alt=""></td>
<td width="15"><img src="$cfg{imagesurl}/forum/$row[6].gif" alt="" border="0" align="middle"></td>
<td width="45%"><b>$nav{$cat_type}:</b><a href="$cfg{pageurl}/index.$cfg{ext}?op=threads;module=Forum;cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$cat_type"><b>$subject</b></a><br>$pages</td>
<td width="15%">$row[10]</td>
<td width="10%" align="center">$row[3]</td>
<td width="10%" align="center">$row[4]</td>
<td width="20%" align="center"><small>$last_post</small></td>
</tr>
HTML
} # no stick
}
$sth->finish;

        print <<HTML;
<br>
<table width="100%" border="0" cellspacing="0" cellpadding="2">
<tr>
<td>
<table width="100%" border="0" cellspacing="1" cellpadding="2">
<tr class="tbl_header">
<td width="16">&nbsp;</td>
<td width="15">&nbsp;</td>
<td width="45%"><b>Newest Topic $msg{subjectC}</b></td>
<td width="15%"><b>$msg{started_by}</b></td>
<td width="10%" align="center"><b>$msg{replies}</b></td>
<td width="10%" align="center"><b>$msg{views}</b></td>
<td width="20%" align="center"><b>$msg{last_post}</b></td>
HTML
print $post_msg;

        print <<HTML;
</table>
</td>
</tr>
</table>
<table border="0" width="100%">
<tr>
<td><b>
</td>
<td align="right"></td>
</tr>
<tr>
<td colspan="2" align="right" valign="bottom">
<div align="right">
HTML

        # Make forum selector.
       # forum_selector();

        print <<HTML;
</td>
</tr>
</table>
HTML

}

sub build_link {
my $thread_id = shift;
my $jump_num = shift || '';
my $return_link = '';
$jump_num = '#' . $jump_num if $jump_num;
my $query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' AND forum_cat.sec_level = '$usr{anonuser}' LIMIT 1;";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' LIMIT 1;";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
$query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 1;";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
$query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll)' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' LIMIT 1;";
  }
my $sth = $dbh->prepare($query1);
$sth->execute || return;
while(my @row = $sth->fetchrow)  {
if ($row[0]) {
$return_link = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=threads;module=Forum;cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$row[4]$jump_num"$cfg{hreftarget}>$row[3]</a>);
}
# cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$row[4]
# <a href="">$row[3]</a>

}
$sth->finish;

return $return_link;
}

sub build_link_aubbc {
my $thread_id = shift;
my $jump_num = '';
my $return_link = '';
if ($thread_id =~ m/\A(\d+)(\#\d+)?\z/i) {
$thread_id = $1;
$jump_num = $2 || '';
#$jump_num = '#' . $jump_num if $jump_num;
my $query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll|articles)' AND forum_cat.sec_level = '$usr{anonuser}' LIMIT 1;";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll|articles)' LIMIT 1;";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
$query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll|articles)' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 1;";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
$query1 = "SELECT forum_threads.id, forum_threads.cat_id, forum_threads.subcat_id, forum_threads.subject, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_threads.id = '$thread_id' AND forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type REGEXP '(forums|poll|articles)' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' LIMIT 1;";
  }
my $sth = $dbh->prepare($query1);
$sth->execute || return;
while(my @row = $sth->fetchrow)  {
if ($row[0]) {
$return_link = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=threads;module=Forum;cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$row[4]$jump_num"$cfg{hreftarget}>$row[3]</a>);
}
# cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$row[4]
# <a href="">$row[3]</a>

}
$sth->finish;
}
return $return_link;
}
1;
