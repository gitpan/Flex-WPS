package wiki_link;

use strict;
use vars qw(
    $dbh %cfg
    );
use exporter;

# make a link v2 Fast version
sub build_link_id {
#
my $wiki_info = shift;
my $wiki_return = '';

my $sth = qq(SELECT `id`, `name` FROM `wiki_site` WHERE `id` = '$wiki_info' LIMIT 1);
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
      $wiki_return = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=view;module=Wiki;id=$row[0]"$cfg{hreftarget}>$row[1]</a>);
      }
}
$sth->finish;

 return $wiki_return;
}
# make a link v2 Fast version
sub build_link_name {
#
my $wiki_info = shift;
my $wiki_return = '';

my $sth = qq!SELECT `id`, `name` FROM `wiki_site` WHERE `name` REGEXP '^$wiki_info\$' LIMIT 1!;
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
         $wiki_return = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=view;module=Wiki;id=$row[0]"$cfg{hreftarget}>$wiki_info</a>);
         }
}
$sth->finish;

 return $wiki_return;
}
# make a link -- Not used
sub build_links {

my $message = shift;
my %wiki_stuff = ();
my %wiki_id = ();

my $sth = "SELECT id, name FROM wiki_site";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
      $wiki_id{"$row[0]"} = $row[1];
      $row[1] = lc($row[1]);
      $wiki_stuff{"$row[1]"} = $row[0];
      }
$sth->finish;

# -------- Revers lookup
$message =~ s{\[wkid://([0-9]+)\](?(?{defined$wiki_id{$1};})|(?!))}{<a href="$cfg{pageurl}/index.$cfg{ext}?op=view;module=Wiki;id=$1" target="_parent">$wiki_id{$1}</a>}gso;

# -------- Forword lookup
$message =~ s{\[wiki://([a-zA-Z0-9\:\-\s\_]+)\](?(?{defined$wiki_stuff{"\L$1"};})|(?!))}{<a href="$cfg{pageurl}/index.$cfg{ext}?op=view;module=Wiki;id=$wiki_stuff{"\L$1"}" target="_parent">$1</a>}gso;

 return $message;
}
1;