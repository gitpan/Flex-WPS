package Search;
# Flex-WPS Search
# By: N.K.A.
# Date: 10/20/2007
# Version: 2.2
# - Fixxed Bug in Search Select
# - Added Wiki, Site Log, Members Search
# - Changed HTML Style
#
# Last version 2.0 - 06/24/2006
# This is now a SQL back-end.
#
# - v1.0 - 9/24/2005
# Added Pages to search list.
# Good protection for page veriable.
# No Errors show in server error log file.
# No known bugs.

# Load necessary modules.
use strict;

# Assign global variables.
use vars qw(
    $query
    $search_term $match $case @what $start $max_items_per_page
    %user_data %nav %cfg %usr %msg %btn $dbh
    );

use exporter;
# search start
my $search_start = time;
# Get the input.
$search_term = $query->param('query');
$match       = $query->param('match') || 'OR';
$case        = $query->param('case') || 'i';
@what        = $query->param('what');
$start = $query->param('start') || 0;
$max_items_per_page = $query->param('page') || 15;

# Define missing veriables. Got this ^up there now.
#if (!$start) { $start = 0; }
if (!@what) { @what = ('all'); }
if ($what[0] =~ /\s/) {
 my @whater = split (/\s/, $what[0]);
 @what = ();
 @what = @whater;
}
#if (!$max_items_per_page) { $max_items_per_page = 15; }

# Change suspicious veriables w/ some protection.
if ($start && $start !~ /^[0-9]+$/ || length($start) > 10) { $start = 0; }
if ($max_items_per_page && $max_items_per_page !~ /^[0-9]+$/
     || $max_items_per_page && length($max_items_per_page) > 10
     || $max_items_per_page && $max_items_per_page <= 0) {$max_items_per_page = 15; }

# Cycle through category and display all entries.
my $num_shown = 0;

# Filter Search Term
if ($search_term) {
$search_term =~ s/&/&amp;/g;
$search_term =~ s/</&lt;/g;
$search_term =~ s/>/&gt;/g;
$search_term =~ s/"/&quot;/g;
$search_term =~ s~\$~&#36;~g;
$search_term =~ s~\(~&#40;~g;
$search_term =~ s~\)~&#41;~g;
$search_term =~ s~\*~&#42;~g;
$search_term =~ s~\+~&#43;~g;
#$search_term =~ s~\.~&#46;~g; # removed so i can search for IP's
#$search_term =~ s~\:~&#58;~g; # no problem found with it?
$search_term =~ s~\?~&#63;~g;
$search_term =~ s~\[~&#91;~g;
$search_term =~ s/\\/&#92;/g;
$search_term =~ s~\]~&#93;~g;
$search_term =~ s~\^~&#94;~g;
$search_term =~ s~\{~&#123;~g;
$search_term =~ s/\|/&#124;/g;
$search_term =~ s~\}~&#125;~g;
$search_term =~ s~\~~&#126;~g;
}
# Check if input is valid.
if (!$search_term || length($search_term) < 3 || length($search_term) > 50)
{
        #user_error($err{bad_input}, $user_data{theme});
        require theme;
        &theme::print_header();
        &theme::print_html($user_data{theme}, $nav{search});
        search_box();
        &theme::print_html($user_data{theme}, $nav{search}, 1); exit;
}
my @search_term = split (/\s+/, $search_term);

my (@matches, @data, @sorted_matches);

sub search {
# Save Searched Term and Count Times Term is Searched
my $add = 1;
my $number = 1;
my $name = '';
my $query2 = "SELECT * FROM search_log WHERE term='$search_term'";
my $sth = $dbh->prepare($query2);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {

if ($row[1] eq $search_term) {
$add = 2;
$number = $row[2] + $number;
$name = $search_term;
   }
}
# Upadte or add to Search log.
require SQLEdit;
if($add eq 2) {
SQLEdit::SQLAddEditDelete("UPDATE `search_log` SET `count` = '$number' WHERE `term` ='$name' LIMIT 1 ;");
} else {
SQLEdit::SQLAddEditDelete("INSERT INTO search_log VALUES (NULL,'$search_term','1')");
}

# Perform search.
foreach my $what (@what) {
#         if ($what eq 'articles' || $what eq 'all')
#         {
#
#                 # Search for articles.
#                 my $cats = dir2array($cfg{topicsdir});
#                 my @cats = grep(/\.cat/, @{$cats});
#
#                 # Cycle through the categories.
#                 foreach my $cat (@cats)
#                 {
#                         my $cat_data = file2array("$cfg{topicsdir}/$cat", 1);
#                         $cat =~ s/\.cat//;
#
#                         # Build index.
#                         foreach my $topic (@{$cat_data})
#                         {
#                                 my ($id, $subject, $poster, $postdate, $comments, $views) =
#                                     split (/\|/, $topic);
#
#                                 # Get the text for the current article.
#                                 my $text = file2scalar("$cfg{articledir}/$id.txt", 1);
#                                 if ($text)
#                                 {
#
#                                         # Search in message title and body.
#                                         my @text = split (/\|/, $text);
#                                         my $string = join (" ", $text[0], $text[3]);
#                                         my $found = do_search($string);
#
#                                         if ($found)
#                                         {
#                                                 push (@matches,
#                                                         join ('|', $id, $subject, $poster, $cat,
#                                                                 'articles'));
#                                         }
#                                 }
#                         }
#                 }
#         }
#         if ($what eq 'forumposts' || $what eq 'all')
#         {
#
#                 # Search for forumposts.
#                 my $cats = dir2array($cfg{boardsdir});
#                 my @cats = grep(/\.txt/, @{$cats});
#
#                 # Cycle through the categories.
#                 foreach my $cat (@cats)
#                 {
#                         my $cat_data = file2array("$cfg{boardsdir}/$cat", 1);
#                         $cat =~ s/\.txt//;
#
#                         # Build index.
#                         foreach my $thread (@{$cat_data})
#                         {
#                                 my (
#                                         $id,   $subject, $poster, undef, undef,
#                                         undef, undef,    undef,   undef
#                                     )
#                                     = split (/\|/, $thread);
#
#                                 # Get the text for the current article.
#                                 my $text = file2scalar("$cfg{messagedir}/$id.txt", 1);
#                                 if ($text)
#                                 {
#
#                                         # Search in message title and body.
#                                         my @text = split (/\|/, $text);
#                                         my $string = join (' ', $text[0], $text[5]);
#                                         my $found = do_search($string);
#
#                                         if ($found)
#                                         {
#                                                 push (
#                                                         @matches,
#                                                         join (
#                                                                 '|',      $id,
#                                                                 $subject, $poster,
#                                                                 $cat,     'forumposts'
#                                                         )
#                                                     );
#                                         }
#                                 }
#                         }
#                 }
#         }
#         if ($what eq 'links' || $what eq 'all')
#         {
#
#                 # Search for links.
#                 my $cats = dir2array($cfg{linksdir});
#                 my @cats = grep(/\.dat/, @{$cats});
#
#                 # Cycle through the categories.
#                 foreach my $cat (@cats)
#                 {
#                         if ($cat eq 'linkcats.dat') { next; }
#                         my $cat_data = file2array("$cfg{linksdir}/$cat");
#                         $cat =~ s/\.dat//;
#
#                         # Build index.
#                         foreach my $link (@{$cat_data})
#                         {
#                                 my ($id, $subject, undef, $desc, undef, $poster, undef) =
#                                     split (/\|/, $link);
#
#                                 # Search in entry's title and body.
#                                 my $string = join (" ", $subject, $desc);
#                                 my $found = do_search($string);
#
#                                 if ($found)
#                                 {
#                                         push (@matches,
#                                                 join ('|', $id, $subject, $poster, $cat, 'links'));
#                                 }
#                         }
#                 }
#         }
# @matches = &search_subload('1', $what);

# Flex Product Manager
# if ($what eq 'Cart_PM' || $what eq 'all')
# {
#
# # Search for pages.
# my $query1 = "SELECT * FROM cart_product_details";
# my $sth = $dbh->prepare($query1);
# $sth->execute;
# # Get page content.
# while(my @row = $sth->fetchrow)  {
# # Search in page's title and body.
# my $string = join (' ', $row[0], $row[1], $row[2], $row[3], $row[4], $row[5], $row[6], $row[7]);
# my $found = do_search($string);
# if ($found) {
#    push (@matches,
#    join ('|', $row[0], "$row[1] - $row[2] - $row[3] - $row[5], $row[6], $row[7]", $usr{admin}, '', 'Cart_PM'));
#    }
# }
# $sth->finish();
# }

# Page Search - mySQL Search
if ($what eq 'pages' || $what eq 'all') {
my $new_term = $search_term;
my $search_case = '';
$search_case = ' BINARY' if $case eq 's';
$new_term =~ s/\s/\|/gso if $match eq 'OR';
# Search for pages.
my $query1 = "SELECT pageid, title FROM `pages` WHERE `active`='1' AND (`title` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `pagetext` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level`='$usr{anonuser}' LIMIT 0 , 30";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT pageid, title FROM `pages` WHERE `title` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `pagetext` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" LIMIT 0 , 30";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
 $query1 = "SELECT pageid, title FROM `pages` WHERE `active`='1' AND (`title` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `pagetext` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
  $query1 = "SELECT pageid, title FROM `pages` WHERE `active`='1' AND (`title` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `pagetext` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user})' LIMIT 0 , 30";
  }
#SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};
my $sth = $dbh->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
   push (@matches,
   join ('|', $row[0], $row[1], $cfg{pagetitle}, '', 'pages'));
# Search in page's title and body.
# my $string = join (' ', $row[0], $row[2], $row[3]);
# my $found = do_search($string);
# if ($found) {
#    push (@matches,
#    join ('|', $row[0], $row[2], $usr{admin}, '', 'pages'));
#    }
}
$sth->finish();
}

# FAQ search - mySQL Search
if ($what eq 'faq' || $what eq 'all') {
my $new_term = $search_term;
my $search_case = '';
$search_case = ' BINARY' if $case eq 's';
$new_term =~ s/\s/\|/gso if $match eq 'OR';
# Search for pages.
my $query1 = "SELECT id, question FROM faq WHERE (`question` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\")";
# if ($user_data{sec_level} eq $usr{admin}) {
# $query1 = "SELECT id, question FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") LIMIT 0 , 30";
# }
#  elsif ($user_data{sec_level} eq $usr{mod}) {
#  $query1 = "SELECT id, question FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
#  }
#   elsif ($user_data{sec_level} eq $usr{user}) {
#   $query1 = "SELECT id, question FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user})' LIMIT 0 , 30";
#   }
#$query1 = "SELECT * FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
my $sth = $dbh->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
# Search in page's title and body.
#my $string = join (' ', $row[0], $row[1], $row[2]);
#my $found = do_search($string);
#if ($found) {
   push (@matches,
   join ('|', $row[0], $row[1], $usr{admin}, '', 'faq'));
   #}
 }
 $sth->finish();
}

# Members search - mySQL Search
if ($what eq 'members' && $user_data{sec_level} ne $usr{anonuser}) {
my $new_term = $search_term;
my $search_case = '';
$search_case = ' BINARY' if $case eq 's';
$new_term =~ s/\s/\|/gso if $match eq 'OR';
# Search for pages.
my $query1 = '';
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT memberid, uid, nick FROM members WHERE (`uid` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `nick` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") LIMIT 0 , 30";
}
 elsif ($user_data{sec_level} eq $usr{mod} || $user_data{sec_level} eq $usr{user}) {
 $query1 = "SELECT memberid, uid, nick FROM members WHERE (`uid` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `nick` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") AND `approved`='1' LIMIT 0 , 30";
 }

#$query1 = "SELECT * FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
my $sth = $dbh->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
# Search in page's title and body.
#my $string = join (' ', $row[0], $row[1], $row[2]);
#my $found = do_search($string);
#if ($found) {
my $s_name = $row[1] . '<small>/(' . $row[2] . ')</small>';
   push (@matches,
   join ('|', $row[0], $s_name, $s_name, '', 'members'));
   #}
 }
 $sth->finish();
}
# SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};
# Forum search - mySQL Search
if ($what eq 'forums' || $what eq 'all') {
my $new_term = $search_term;
my $search_case = '';
$search_case = ' BINARY' if $case eq 's';
$new_term =~ s/\s/\|/gso if $match eq 'OR';
# Search for pages.
my $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_cat.sec_level = '$usr{anonuser}' AND (forum_threads.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_threads.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND (forum_threads.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_threads.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
 $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' AND (forum_threads.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_threads.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
  $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type FROM forum_threads, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' AND (forum_threads.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_threads.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
  }
#$query1 = "SELECT * FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
my $sth = $dbh->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
# Search in page's title and body.
#my $string = join (' ', $row[0], $row[1], $row[2]);
#my $found = do_search($string);
#if ($found) {
my $s_name =  $row[4] . ',' . $row[1] . ','. $row[0] . ',' . $row[5] . ',' . '';
   push (@matches,
   join ('|', $s_name, $row[3], $row[2], $row[5], 'forums'));
   #}
 }
 $sth->finish();
$query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type, forum_reply.id FROM forum_threads, forum_reply, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_reply.thread_id=forum_threads.id AND forum_cat.sec_level = '$usr{anonuser}' AND (forum_reply.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_reply.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
if ($user_data{sec_level} eq $usr{admin}) {
$query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type, forum_reply.id FROM forum_threads, forum_reply, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_reply.thread_id=forum_threads.id AND (forum_reply.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_reply.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
}
 elsif ($user_data{sec_level} eq $usr{mod}) {
 $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type, forum_reply.id FROM forum_threads, forum_reply, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_reply.thread_id=forum_threads.id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' AND (forum_reply.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_reply.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
 }
  elsif ($user_data{sec_level} eq $usr{user}) {
  $query1 = "SELECT forum_threads.id, forum_threads.subcat_id, forum_threads.poster, forum_threads.subject, forum_cat.id, forum_cat.cat_type, forum_reply.id FROM forum_threads, forum_reply, forum_cat WHERE forum_cat.id=forum_threads.cat_id AND forum_reply.thread_id=forum_threads.id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user})' AND (forum_reply.subject REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR forum_reply.message REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\");";
  }
#$query1 = "SELECT * FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
my $sth = $dbh->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
# Search in page's title and body.
#my $string = join (' ', $row[0], $row[1], $row[2]);
#my $found = do_search($string);
#if ($found) {
my $s_name =  $row[4] . ',' . $row[1] . ','. $row[0] . ',' . $row[5] . ",#0$row[6]";
   push (@matches,
   join ('|', $s_name, $row[3], $row[2], $row[5], 'forums'));
   #}
 }
 $sth->finish();
}

# Wiki search - mySQL Search
if ($what eq 'wiki' || $what eq 'all') {
my $new_term = $search_term;
my $search_case = '';
$search_case = ' BINARY' if $case eq 's';
$new_term =~ s/\s/\|/gso if $match eq 'OR';
# Search for pages.
my $query1 = "SELECT id, name, lastauther FROM wiki_site WHERE (`name` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `desc` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" OR `also_see` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\") LIMIT 0 , 30";

#$query1 = "SELECT * FROM faq WHERE (`question` REGEXP \"\[[:<:]]$new_term\[[:>:]]\" OR `answer` REGEXP \"\[[:<:]]$new_term\[[:>:]]\") AND `sec_level` REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 0 , 30";
my $sth = $dbh->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
# Search in page's title and body.
#my $string = join (' ', $row[0], $row[1], $row[2]);
#my $found = do_search($string);
#if ($found) {
   push (@matches,
   join ('|', $row[0], $row[1], $row[2], '', 'wiki'));
   #}
 }
 $sth->finish();
}

# Site Log Search - mySQL Search
if ($user_data{sec_level} eq $usr{admin} && $what eq 'statlog') {
my $new_term = $search_term;
my $search_case = '';
$search_case = ' BINARY' if $case eq 's';
$new_term =~ s/\s/\|/gso if $match eq 'OR';
# Search for pages.
my $query1 = "SELECT * FROM `stats_log` WHERE `stats_info` REGEXP$search_case \"\[[:<:]]$new_term\[[:>:]]\" ORDER BY id DESC";

#SELECT * FROM forum_threads, forum_cat WHERE forum_cat.id = forum_threads.cat_id AND forum_cat.sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' ORDER BY forum_threads.date DESC LIMIT $cfg{max_items_per_page};
my $sth = $dbh->prepare($query1);
$sth->execute;
# Get page content.
while(my @row = $sth->fetchrow)  {
$row[2] =~ s/\|/ &#124;/gso;
   push (@matches,
   join ('|', $row[0], "$row[2]", $cfg{pagetitle}, $row[1], 'statlog'));
# Search in page's title and body.
# my $string = join (' ', $row[0], $row[2], $row[3]);
# my $found = do_search($string);
# if ($found) {
#    push (@matches,
#    join ('|', $row[0], $row[2], $usr{admin}, '', 'pages'));
#    }
}
$sth->finish();
}

}

for (0 .. $#matches)
{
        my @fields = split (/\|/, $matches[$_]);
        for my $i (0 .. $#fields) { $data[$_][$i] = $fields[$i]; }
}

# Sort the matches by category.
my @sorted = sort { $a->[4] cmp $b->[4] } @data;
for (@sorted)
{
        my $sorted_row = join ("|", @$_);
        push (@sorted_matches, $sorted_row);
}
require theme;
theme::print_header();
theme::print_html($user_data{theme}, $nav{search});
search_box();

# Print the results.
if (!@matches) { print "<b>$msg{db_was_searched} \"<i>$search_term</i>\"<br>$msg{no_matches}.</b>"; }
else
{
        my $sorted_matches = @sorted_matches;

        my $result = $sorted_matches . ' ' . $msg{matches};
        if ($sorted_matches == 1)
        {
                $result = $sorted_matches . ' ' . $msg{match};
        }
  $search_start = time - $search_start;
        print <<HTML;
<table border="0" cellpadding="0" cellspacing="5" width="100%">
<tr>
<td><b>$msg{db_was_searched} "<i>$search_term</i>".<br>
$msg{search_returned} $result in $search_start second(s).</b></td>
</tr>
HTML
        require DATE_TIME;
        for (my $i = $start; $i < @sorted_matches; $i++) {
                my ($id, $subject, $poster, $cat, $type) =
                    split (/\|/, $sorted_matches[$i]);

                # Get nick of link poster.
                my $user_profile = '';#= file2array("$cfg{memberdir}/$poster.dat", 1);

                print <<HTML;
<tr>
<td><div style="padding: 3px 5px 3px 5px;" class="navtable"><img src="$cfg{imagesurl}/urlgo.gif" border="0" alt="">&nbsp;&nbsp;
HTML

#                 if ($type eq 'articles')
#                 {
#                         print
#                             qq($nav{articles}: <b><a href="$cfg{pageurl}/topics.$cfg{ext}?op=view_topic;cat=$cat;id=$id">$subject</a></b><br>\n);
#                 }
#                 if ($type eq 'forumposts')
#                 {
#                         print
#                             qq($nav{forums}: <b><a href="$cfg{pageurl}/forum.$cfg{ext}?op=view_thread;board=$cat;thread=$id">$subject</a></b><br>\n);
#                 }
#                 if ($type eq 'links')
#                 {
#                         print
#                             qq($nav{links}: <b><a href="$cfg{pageurl}/links.$cfg{ext}?op=view_link;cat=$cat;id=$id">$subject</a></b><br>\n);
#                 }
#                 if ($type eq 'Cart_PM')
#                 {
#                         print
#                             qq(Product Manager: <b><a href="$cfg{pageurl}/index.$cfg{ext}?op=detail_form;module=Cart_Details;id=$id">$subject</a></b><br>\n);
#                 }
                if ($type eq 'pages') {
                        print
                            qq(<b>$nav{pages}:</b> <b><a href="$cfg{pageurl}/index.$cfg{ext}?op=page;id=$id">$subject</a></b><br>\n);
                }
                # Search sub load
                #&search_subload('3');
    if ($type eq 'faq') {
       print
       qq(<b>FAQ's:</b> <b><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_answer;module=FAQ;id=$id">$subject</a></b><br>\n);
    }
                if ($type eq 'members') {
                        print
                            qq(<b>Member:</b> <b><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$id">$subject</a></b><br>\n);
                }
                if ($type eq 'forums') {
                       my ($cats, $subs, $threads, $stickys, $jump_forum) = split(/\,/, $id);
                        print qq(<b>$nav{$cat}:</b> <b>
                        <a href="$cfg{pageurl}/index.$cfg{ext}?op=threads;module=Forum;cat=$cats;subcat=$subs;thread=$threads;sticky=$stickys$jump_forum">$subject</a></b><br>\n
                        <font color=DarkRed>Link to this Thread: [id://$threads$jump_forum]</font><br>\n);
                }
                if ($type eq 'statlog') {
                      # my ($cats, $subs, $threads, $stickys) = split(/\,/, $id);
                        $cat = DATE_TIME::format_date($cat, 11);
                        print
                            qq(<b>Log:</b> $id - $subject<br><font color=DarkRed>$cat</font><br>\n);
                }
                if ($type eq 'wiki') {
                      # my ($cats, $subs, $threads, $stickys) = split(/\,/, $id);
                        print
                            qq(<b>Wiki:</b> <a href="$cfg{pageurl}/index.$cfg{ext}?op=view;module=Wiki;id=$id"><b>$subject</b></a><br>
                            <font color=DarkRed><b>Link to this wiki:</b> [wkid://$id] <b>or</b> [wiki://$subject]</font><br>\n);
                        print qq(<small><a href="$cfg{pageurl}/index.$cfg{ext}?op=admin;module=Wiki;id=$id">Edit This Wiki</a> | <a href="$cfg{pageurl}/index.$cfg{ext}?op=admin;module=Wiki">Add New Wiki</a></small><br>) if $user_data{sec_level} eq $usr{admin};
                }
                print '<small>' . $msg{written_by} . ' ' . $poster . '</small>' if $poster;

#                 if ($poster eq $usr{anonuser} || $poster eq $usr{admin})
#                 {
#                        print $poster;
#                 }
                # elsif ($poster && $user_profile->[1])
#                 {
#                         print
#                             qq(<a href="$cfg{pageurl}/user.$cfg{ext}?op=view_profile;username=$poster">$user_profile->[1]</a>);
#                 }

                print <<HTML;
</div>
</td>
</tr>
HTML
                $num_shown++;
                if ($num_shown >= $max_items_per_page) { last; }
        }
print '</table>';
# Make jumpbar.  >= $max_items_per_page
        if ($num_shown)
        {
                print qq(<hr noshade="noshade" size="1">\n Number of Pages );
                my $num_links = scalar @sorted_matches;

                my $count = 0;
                while (($count * $max_items_per_page) < $num_links)
                {
                        my $viewc = $count + 1;
                        my $strt  = ($count * $max_items_per_page);
                        if ($start == $strt) { print " [$viewc] &nbsp;"; }
                        else
                        {
                                print
                                    qq(&nbsp;<a href="index.$cfg{ext}?op=search;start=$strt;query=$search_term;page=$max_items_per_page;match=$match;what=@what">$viewc</a> &nbsp;);
                        }
                        $count++;
                }
        }

}

theme::print_html($user_data{theme}, $nav{search}, 1);
}
# Load other modules for search
# Not fully used yet
# Note: Make Main sub load with changing query, for small code
sub search_subload {
my ($location) = @_;
my $query1 = "SELECT * FROM search_subload WHERE location='$location'";
my $sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
no strict 'refs'; # 0, well..
while(my @row = $sth->fetchrow) {
if (!$row[1] && $row[4]) { require "$row[2].pm"; my $load = $row[2] . '::' . $row[3]; $load->(); }
elsif ($row[1]) { use lib './lib/modules'; require "$row[2].pm"; my $load = $row[2] . '::' . $row[3]; $load->(); }
}
$sth->finish();
}
# Search Box
sub search_box
{
if (!$search_term) { $search_term = ''; }
print <<HTML;
<b>$msg{new} $msg{search}:</b><br>
<form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="sform" onsubmit="if (document.sform.query.value=='') return false">
<table border="0" cellpadding="2" cellspacing="0" width="100%">
<tr>
<td valign="top"><table border="0" cellpadding="2" cellspacing="0">
<tr>
<td><b>$msg{search_for}:</b></td>
<td><input name="query" type="text" size="20" value="$search_term" maxlength="256"></td>
</tr>
<tr>
<td><b>$msg{boolean}:</b></td>
<td><select name="match">
<option value="OR">$msg{search_or}</option>
<option value="AND">$msg{search_and}</option>
</select></td>
</tr>
<tr>
<td><b>$msg{case}:</b></td>
<td><select name="case">
<option value="i">$msg{search_insensitive}</option>
<option value="s">$msg{search_sensitive}</option>
</select></td>
</tr>
<tr>
<td><b>Items Per Page:</b></td>
<td><select name="page">
<option value="35">35</option>
<option value="30">30</option>
<option value="25">25</option>
<option value="20">20</option>
<option value="15">15</option>
<option value="10">10</option>
<option value="5">5</option>
</select></td>
</tr>
</table>
</td>
<td valign="top"><table border="0" cellpadding="2" cellspacing="0">
<tr>
<td valign="top"><b>$msg{search_in}:</b></td>
<td><select name="what" size="6" multiple>
HTML

# Bug fixxed
my ($wk_check, $forum_check, $page_check, $faq_check, $mem_check, $stat_check) = ('','','','','','');
foreach my $what (@what) {
$wk_check = ' selected' if $what eq 'wiki';
$forum_check = ' selected' if $what eq 'forums';
$page_check = ' selected' if $what eq 'pages';
$faq_check = ' selected' if $what eq 'faq';
$mem_check = ' selected' if ($what eq 'members' && $user_data{sec_level} ne $usr{anonuser});
$stat_check = ' selected' if ($what eq 'statlog' && $user_data{sec_level} eq $usr{admin});
}
print <<HTML;
<option value="wiki"$wk_check>Wiki</option>
<option value="forums"$forum_check>$nav{forums}</option>
<option value="pages"$page_check>$nav{pages}</option>
<option value="faq"$faq_check>FAQ's</option>
HTML

print qq(<option value="members"$mem_check>Members</option>) if ($user_data{sec_level} eq $usr{admin});
print qq(<option value="statlog"$stat_check>Site Log</option>) if ($user_data{sec_level} eq $usr{admin});

# Has a bug
# foreach my $what (@what) {
# $what eq 'wiki' ? print "<option value=\"wiki\" selected>Wiki</option>\n" : print "<option value=\"wiki\">Wiki</option>\n";
# $what eq 'forums' ? print "<option value=\"forums\" selected>$nav{forums}</option>\n" : print "<option value=\"forums\">$nav{forums}</option>\n" ;
# $what eq 'pages' ? print "<option value=\"pages\" selected>$nav{pages}</option>\n" : print "<option value=\"pages\">$nav{pages}</option>\n" ;
# $what eq 'faq' ? print "<option value=\"faq\" selected>FAQ's</option>\n" : print "<option value=\"faq\">FAQ's</option>\n" ;
# ($what eq 'members' && $user_data{sec_level} ne $usr{anonuser}) ? print "<option value=\"members\" selected>Members</option>\n" : print "<option value=\"members\">Members</option>\n" ;
# ($what eq 'statlog' && $user_data{sec_level} eq $usr{admin}) ? print "<option value=\"statlog\" selected>Site Log</option>\n" : print "<option value=\"statlog\">Site Log</option>\n" ;
# #$what eq 'Cart_PM' ? print "<option value=\"Cart_PM\" selected>Details</option>\n" : print "<option value=\"Cart_PM\">Details</option>\n" ;
# }
# <option value="pages">$nav{pages}</option>
# <option value="faq">FAQ's</option>
# <option value="Cart_PM">Details</option>
print <<HTML;
</select></td>
</tr>
</table></td>
</tr>
<tr>
<td><input type="hidden" name="op" value="search"><input type="submit" value="$btn{search}"></td>
</tr>
</table>
</form>
<hr size="1">
HTML

}
# ---------------------------------------------------------------------
# Perform boolean search in given text string.
# ---------------------------------------------------------------------
# Nothing is using this
# sub do_search
# {
#         my $string = shift;
#         my $found  = 0;
#
#         if ($match eq 'AND')
#         {
#                 foreach my $term (@search_term)
#                 {
#                         if ($case eq 'Insensitive')
#                         {
#                                 if (!($string =~ /$term/i)) { $found = 0; last; }
#                                 else { $found = 1; }
#                         }
#                         if ($case eq 'Sensitive')
#                         {
#                                 if (!($string =~ /$term/)) { $found = 0; last; }
#                                 else { $found = 1; }
#                         }
#                 }
#         }
#
#         if ($match eq 'OR')
#         {
#                 foreach my $term (@search_term)
#                 {
#                         if ($case eq 'Insensitive')
#                         {
#                                 if ($string =~ /$term/i) { $found = 1; last; }
#                                 else { $found = 0; }
#                         }
#                         if ($case eq 'Sensitive')
#                         {
#                                 if (!($string =~ /$term/)) { $found = 1; last; }
#                                 else { $found = 0; }
#                         }
#                 }
#         }
#
#         return $found;
# }
1;