package memberlist;



#  memberlist.pm,v 1.0 10/25/2007 By: N.K.A.
#
#  This file is part of Flex-WPS.
#  $cfg{online_members} 


use exporter;

use strict;
# Assign global variables.
use vars qw(
    $query %err %user_data %usr $dbh %cfg
    %nav %msg
);
# Get the input.
my $sort  = $query->param('sort')  || 3;
my $start = $query->param('start') || 0;

     if ($sort && $sort !~ m!^(\d+)$!i) { require error; error::user_error($err{bad_input}); }
     if ($start && $start !~ m!^(\d+)$!i) { require error; error::user_error($err{bad_input}); }
# Get user profile.

sub list {
# Check if user is logged in.
if ($user_data{uid} eq $usr{anonuser}) {
     require error; error::user_error($err{bad_input}, $user_data{theme});
}

# Get names of all members and count them.
my $members;

# Get every member's data.
my $members_count = 0;
my $id = 0;
my @member;
my $lastregisered = '';
my $query1 = "SELECT * FROM `whosonline` WHERE `id` = '1' LIMIT 1 ;";
my $sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't exec sth!");
while(my @row = $sth->fetchrow)  {
$members_count = $row[1];
$lastregisered = $row[3];
}
$sth->finish();

my $query1 = "SELECT * FROM `members` WHERE approved='1'";
my $sth = $dbh->prepare($query1);
$sth->execute || die("Couldn't exec sth!");

my $member_profile;
while($member_profile = $sth->fetchrow_arrayref)  {

$id++;



        # Get member profile.
        # Make string for nickname sorting.
        my $sort_name = lc $member_profile->[2];

        # current member xp.
        my $posts = $member_profile->[11];

        # Get member rank.
        my $rank;
        require rank;
        my @ranks  = rank::load_ranks();
        foreach (@ranks)
        {
            my ($r_num, $r_name) = split (/\|/, $_);
                if ($posts >= $r_num) {
                $rank = $r_name;
                  if($cfg{forum_stars}) {
                  } else {
                  $rank = qq(<img src="$cfg{imagesurl}/rank/$rank.gif" alt="$rank" border="0");
                  }
                }
        }
        if(!$member_profile->[20]) { $member_profile->[20] = ''; }
        push (
                @member,
                join (
                        "|",                  $member_profile->[3],
                        $member_profile->[4], $member_profile->[10],
                        $member_profile->[20], $rank,
                        $posts,               $member_profile->[8],
                        $id,                  $sort_name,
                        $member_profile->[2], $member_profile->[0]
                )
            );
}
$sth->finish();

# Sort members.
my (@data, @sorted, @sorted_members);
for (0 .. $#member) {
        my @fields = split (/\|/, $member[$_]);
        for my $i (0 .. $#fields) { $data[$_][$i] = $fields[$i]; }
}

# Sort entries.
if ($sort == 1) {
        @sorted = sort { $a->[8] cmp $b->[8] } @data;
}  # Sort by username (sort_name).
if ($sort == 2) {
        @sorted = sort { $a->[1] cmp $b->[1] } @data;
}  # Sort by email.
if ($sort == 3) {
        @sorted = sort { $a->[7] <=> $b->[7] } @data;
}  # Sort by member since (id).
if ($sort == 4) {
        @sorted = sort { $a->[3] cmp $b->[3] } @data;
}  # Sort by Flag.


if ($sort == 5 || $sort == 6) {
        @sorted = sort { $a->[5] <=> $b->[5] } @data;
}  # Sort by rank/posts.

if ($sort == 7) {
        @sorted = reverse sort { $a->[6] cmp $b->[6] } @data;
}  # Sort by function.

for (@sorted) {
        my $sorted_row = join ("|", @$_);
        push (@sorted_members, $sorted_row);
}

# <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$members->[$#$members]">$members->[$#$members]</a>
# Online Members comes from whosonline.pm $cfg{online_members}
require theme;
theme::print_header();
theme::print_html($user_data{theme}, $nav{member_list});
print <<HTML;
<table border="0" width="100%" cellspacing="1">
<tr>
<td valign="top">$msg{newest_memberC} $lastregisered<br>
$msg{member_countC} $members_count<br>
$msg{online_countC} $cfg{online_members}</td>
</tr>
</table>
<table class="navtable" width="100%" border="0" cellspacing="0" cellpadding="0"><tr>
<form action="$cfg{pageurl}/index.$cfg{ext}" method="post" name="sbox" onSubmit="if (document.sbox.query.value=='') return false">
<td align="center">
<input type="text" name="query" size="15" class="text">
<input type="hidden" name="what" value="members">
<input type="hidden" name="op" value="search">
&nbsp;&nbsp;<input type="submit" value="$msg{search} $msg{membersC}">
</td>
</form></tr></table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr>
<td>
<table width="95%" border="0" cellspacing="1" cellpadding="3" align="center">
<tr class="tbl_header">
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=list;sort=1;start=$start"><b>$msg{nameC}</b></a></td>
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=list;sort=2;start=$start"><b>$msg{emailC}</b></a></td>
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=list;sort=3;start=$start"><b>$msg{member_sinceC}</b></a></td>
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=list;sort=4;start=$start"><b>Flag:</b></a></td>
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=list;sort=5;start=$start"><b>$msg{rankC}</b></a></td>
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=list;sort=6;start=$start"><b>XP:</b></a></td>
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=list;sort=7;start=$start"><b>$msg{functionC}</b></a></td>
</tr>
HTML

# Print the memberlist.
my $num_shown = 0;
if (@sorted_members) {
        my $row_color = qq( class="tbl_row_dark");
        for (my $i = $start; $i < @sorted_members; $i++) {
                my (
                        $nick,  $email, $since, $flag,       $rank,
                        $posts, $funct, $id,    $sort_name, $name, $lid
                    )
                    = split (/\|/, $sorted_members[$i]);

                if ($flag) {
                        $flag =
                            qq(<img src="$cfg{imagesurl}/flags/$flag" style="border: none;" alt="$name">);
                }

                # Alternate the row colors.
                $row_color =
                    ($row_color eq qq( class="tbl_row_dark"))
                    ? qq( class="tbl_row_light")
                    : qq( class="tbl_row_dark");

                # Protect email address.
                # Need to make 'op=contact'
                my $protected_email = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=contact;recip_name=$name"><img src='$cfg{imagesurl}/forum/email.gif' alt='$msg{send_email} $nick' border='0'></a>);

                # Format date.
                require DATE_TIME;
                my $formatted_date = DATE_TIME::format_date($since);

                print <<HTML;
<tr$row_color>
<td><a href="$cfg{pageurl}/index.$cfg{ext}?op=view_profile;username=$lid">$name</a><small>/($nick)</small></td>
<td>$protected_email</td>
<td>$formatted_date</td>
<td align="center">$flag</td>
<td align="center"><div style="background-color : #666666; border:1px solid black; padding: 1px 1px 1px 1px;">$rank</div></td>
<td>$posts</td>
<td>$funct</td>
</tr>
HTML

                $num_shown++;
                if ($num_shown >= $cfg{max_items_per_page}) { $i = @sorted_members; }
        }
}

print <<HTML;
</table></td>
</tr>
</table><br>
<b>$msg{pagesC}</b>
HTML

# Make page navigation bar.
my $num_members = @sorted_members;
my $count       = 0;
while ($count * $cfg{max_items_per_page} < $num_members)
{
        my $view = $count + 1;
        my $strt = $count * $cfg{max_items_per_page};
        if ($start == $strt) { print "[$view] "; }
        else
        {
                print
                    qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=memberlist;sort=$sort;start=$strt">$view</a> );
        }
        $count++;
}

theme::print_html($user_data{theme}, $nav{member_list}, 1);
}
1;
