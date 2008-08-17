package last_articles;

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

%sub_action = ( print_posts => 1 );
# working
sub print_posts {

my $post_msg = '';
#my @messages = ();
#my $num_shown = 0;
# mySQL Query works
# WOOT mySQL!!!
my $query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type = 'articles' AND forum_cat.sec_level = '$usr{anonuser}' ORDER BY forum_threads.date DESC LIMIT 5;";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type = 'articles' ORDER BY forum_threads.date DESC LIMIT 5;";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type = 'articles' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT 5;";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
$query1 = "SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.cat_type = 'articles' AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' ORDER BY forum_threads.date DESC LIMIT 5;";
  }
my $sth = $dbh->prepare($query1);
$sth->execute || return;
my $row_color = qq( class="tbl_row_dark");
while(my @row = $sth->fetchrow)  {
                $row_color =
                    ($row_color eq qq( class="tbl_row_dark"))
                    ? qq( class="tbl_row_light")
                    : qq( class="tbl_row_dark");
     my $cat_type = $row[$#row] if $row[$#row];

                my $subject = $row[11];
                if (length($subject) > 250) {
                    $subject = substr($subject, 0, 250);
                    $subject =~ s/(.*)\s.*/$1 \.\.\./;
                    }
                #require UBBC;
                #$subject = UBBC::do_ubbc($subject);
                #$subject = UBBC::do_smileys($subject);
                $AUBBC_mod->settings( for_links => 1 );
                $subject = $AUBBC_mod->do_all_ubbc($subject);
                $AUBBC_mod->settings( for_links => 0 );
                my $message = $row[12];
                if (length($message) > 250) {
                    $message = substr($message, 0, 250);
                    $message =~ s/(.*)\s.*/$1 \.\.\./;
                    }
                #$message = UBBC::do_ubbc($message);
                #$message = UBBC::do_smileys($message);
                $message = $AUBBC_mod->do_all_ubbc($message);
                $post_msg .= <<HTML;
  <tr$row_color valign="top">
    <td rowspan="2" width="82"><img src="$cfg{imagesurl}/topics/$row[2].gif" alt=""></td>
    <td height="5"><a href="$cfg{pageurl}/index.$cfg{ext}?op=threads;module=Forum;cat=$row[1];subcat=$row[2];thread=$row[0];sticky=$cat_type"><b>$subject</b></a>&nbsp;&nbsp;<a href="$cfg{pageurl}/index.$cfg{ext}?op=print_thread;module=Forum;cat=$row[1];subcat=$row[2];thread=$row[0];id=1" target="_blank"><img src="$cfg{imagesurl}/print.gif" alt="$msg{print_friendly}" border="0"></a></td>
  </tr>
  <tr$row_color>
    <td valign="top" height="50">$message</td>
  </tr>
HTML
}
$sth->finish;


#         $messages_print .= qq(</td>
# </tr>);
#$messages_print .= theme::box_footer();
print <<HTML;
<br>
<table width="100%" border="0" cellspacing="2" cellpadding="2">
$post_msg
</table>
HTML

}
1;
