package FAQ;
# Simple FAQ with user status, but not used at this time
use strict;
use vars qw(%user_action $dbh %cfg %user_data %usr $query %err %faq_lg);
use exporter;
# Define possible user actions.
%user_action = (
 faq => 1,
 view_answer => 1
 );

my $id   = $query->param('id');
if ($id && $id !~ m!^([0-9]+)$!i) {
require error;
error::user_error($err{bad_input});
}

# Load FAQ lang. file
require "$cfg{modulesdir}/FAQ/lang.pl";

sub faq {
# table has user status
my $data;
my $sth = "SELECT * FROM faq";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't connect to database!\n");
while(my @row = $sth->fetchrow)  {
      if($row[0]){
      $data .= qq($faq_lg{q} <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_answer;module=FAQ;id=$row[0]">$row[1]</a><br>);
      }
}
$sth->finish;
if (!$data) {
require error;
error::user_error($err{bad_input});
}
require theme;
theme::print_header();
theme::print_html($user_data{theme}, $faq_lg{page1});
print <<HTML;
<br>
<table class="bg5" border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td width="100%" class="cathdl">&nbsp;$faq_lg{page1}</td>
</tr>
</table>
<table class="menuback" border="0" cellpadding="1" cellspacing="0" width="100%">
<tr>
<td><table border="0" cellpadding="3" cellspacing="0">
$data
</table></td>
</tr>
</table><br>
HTML
theme::print_html($user_data{theme}, $faq_lg{page1}, 1);
}
sub view_answer {
my $data;
my $sth = "SELECT * FROM faq WHERE id='$id'";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't connect to database!\n");
while(my @row = $sth->fetchrow)  {
      if($row[0]){
      $data = qq(<b>$faq_lg{q} $row[1]</b><br><b>$faq_lg{a}</b> $row[2]<br>);
      }
}
$sth->finish;
my $data2;
$sth = "SELECT * FROM faq";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't connect to database!\n");
while(my @row = $sth->fetchrow)  {
      if($row[0]){
      $data2 .= qq($faq_lg{q} <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_answer;module=FAQ;id=$row[0]">$row[1]</a><br>);
      }
}
$sth->finish;
require theme;
theme::print_header();
theme::print_html($user_data{theme}, $faq_lg{page2});
print <<HTML;
<table width="100%" border="0" cellspacing="0" cellpadding="4" class="navtable">
<tr>
<td>$data</td>
</tr>
</table><br>
<table class="bg5" border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
<td width="100%" class="cathdl">&nbsp;$faq_lg{page2}</td>
</tr>
</table>
<table class="menuback" border="0" cellpadding="1" cellspacing="0" width="100%">
<tr>
<td><table border="0" cellpadding="3" cellspacing="0">
$data2
</table></td>
</tr>
</table><br>
HTML
theme::print_html($user_data{theme}, $faq_lg{page2}, 1);
}

sub mine_view {
# Can be used in subload only
require theme;
my $data = theme::box_header($faq_lg{page1});
my $sth = "SELECT * FROM faq";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't connect to database!\n");
while(my @row = $sth->fetchrow)  {
if($row[0]){
$data .= qq($faq_lg{q} <a href="$cfg{pageurl}/index.$cfg{ext}?op=view_answer;module=FAQ;id=$row[0]">$row[1]</a><br>);
}

}
$sth->finish;
$data .= theme::box_footer();
print $data;
}
1;