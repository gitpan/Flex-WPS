package portal_aubbc;

use vars qw( %cfg %user_data %usr $dbh );
use strict;
use exporter;
sub search_links {
my $message = shift;
my $search_pat = 'a-zA-Z\d\:\-\s\_\/\.';
 # Flex-WPS Search
 if ($message =~ m/\A([$search_pat]+)\,([a-z\s]+)\z/i) {
 # Pattern, search in   [search://search_term,wiki forums poll]
 $message = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=search;query=$1;match=OR;what=$2"$cfg{hreftarget}>$1</a>);
 }
  elsif ($message =~ m/\A([$search_pat]+)\,([a-z\s]+)\,(AND|OR)\z/i) {
 # Pattern, search in, Boolean   [search://search_term,wiki forums poll,OR]
 $message = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=search;query=$1;match=$3;what=$2"$cfg{hreftarget}>$1</a>);
 }
  elsif ($message =~ m/\A([$search_pat]+)\,([a-z\s]+)\,(AND|OR)\,(i|s)\z/i) {
 # Pattern, search in, Boolean, case   [search://search_term,wiki forums poll,OR,s]
 $message = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=search;case=$4;query=$1;match=$3;what=$2"$cfg{hreftarget}>$1</a>);

 # All Search  [search://search_term]
 }
  elsif ($message =~ m/\A([$search_pat]+)\z/i) {
 $message = qq(<a href="$cfg{pageurl}/index.$cfg{ext}?op=search;query=$1;match=OR"$cfg{hreftarget}>$1</a>);
 }
  else {
  $message = '';
  }
 return $message;
}

sub page_links {
my $page_id = shift;

if ($page_id) {
$page_id = $dbh->quote($page_id);
my $sth = "SELECT pageid, title FROM pages WHERE pageid=$page_id AND active='1' AND sec_level='$usr{anonuser}' LIMIT 1;";
if ($user_data{sec_level} eq $usr{admin}) {
     $sth = "SELECT pageid, title FROM pages WHERE pageid=$page_id LIMIT 1;";
       }
        elsif ($user_data{sec_level} eq $usr{mod}) {
                $sth = "SELECT pageid, title FROM pages WHERE pageid=$page_id AND active='1' AND sec_level REGEXP '($usr{anonuser}|$usr{user}|$usr{mod})' LIMIT 1;";
        }
         elsif ($user_data{sec_level} eq $usr{user}) {
                $sth = "SELECT pageid, title FROM pages WHERE pageid=$page_id AND active='1' AND sec_level REGEXP '($usr{anonuser}|$usr{user})' LIMIT 1;";
         }
$sth = $dbh->prepare($sth);
$sth->execute;
$page_id = '';
while(my @row = $sth->fetchrow)  {
$page_id = qq(<a href="javascript:doGETRequest('$cfg{pageurl}/index.$cfg{ext}?op=page;id=$row[0]', processReqChangeMany, 'controle', '');">$row[1]</a>) if $row[0];
}
$sth->finish;

}
 else {
  $page_id = '';
 }

return $page_id;
}
1;
