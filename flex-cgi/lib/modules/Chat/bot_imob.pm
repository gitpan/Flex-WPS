package bot_imob;
# Intelligent Message output bot

use vars qw(
    %user_data $dbh %usr
    $VERSION
    );
use exporter;

sub speack {
my $stuff = shift;
my $talk = '';
#my $dt = CGI::Util::expires('now','');

if ($stuff =~ m/^\/imob add \[(.+?)\]\-\[(.+?)\]$/i && $user_data{sec_level} eq $usr{admin}) {
             require SQLEdit;
             my $regex = $1;
             my $talk_text = $2;
             $talk_text =~ s{'}{&#39;}gso;
             #$talk_text =~ s{\\}{&#92;}gso;
             $regex =~ s{'}{&#39;}gso;
             #$regex =~ s{\\}{&#92;}gso;
             $talk_text = qq(INSERT INTO `chat_bot_imob` ( `id` , `message` , `regex` , `sec_level` , `active` )
VALUES (
NULL , '$talk_text', '$regex', NULL , '1'
););
             SQLEdit::SQLAddEditDelete($talk_text);
             $talk = 'New Command was added by: ' . $usr{admin};
}
 elsif ($stuff =~ m/^imob cmd$/i) {
my $sth = "SELECT * FROM chat_bot_imob WHERE active='1'";
$sth = $dbh->prepare($sth);
$sth->execute;
$talk = "\n";
my $start = '';
while(my @row = $sth->fetchrow)  {
      if ($row[0]) {
       $start = $row[2];
       $start =~ s/\^//;
      $talk .= <<HTML;
ID $row[0] - $start
HTML
      }
}
$sth->finish;
 }
 else {
my $sth = "SELECT * FROM chat_bot_imob WHERE active='1'";
$sth = $dbh->prepare($sth);
$sth->execute;
while(my @row = $sth->fetchrow)  {
      if ($row[0] && $stuff =~ m/$row[2]/i) {
           $talk = $row[1];
           $talk =~ s/%VERSION%/$VERSION/gso;
           $talk =~ s/%MESSAGE%/$stuff/gso;
           $talk =~ s/%pageurl%/$cfg{pageurl}\/index.$cfg{ext}/gso;
           if ($talk =~ m/%admin%/i && $user_data{sec_level} eq $usr{admin}) {
                $talk =~ s/\%admin\%/Add Command \> \/imob add \[regex\]\-\[message\]/;
           }
           else {
                 $talk =~ s/\n%admin%//;
           }
           last;
      }
}
$sth->finish;
}

return $talk;
}
1;