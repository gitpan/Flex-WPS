package ban;

#
#  ban.pm
# v 1.2 10/24/2007 04:05:39 By: N.K.A. - script looks good.
#
#  This file is part of Flex-WPS - mySQL.
#

use strict;
# Global variables.
use vars qw( $dbh %user_data %sub_action %cfg );
use exporter;
%sub_action = ( check_ban => 1 );

# New Ban style
# Check ban should be added in the user register,
# so ban names and emails are not in registerd members
sub check_ban {
my $host = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || '';
my $ban = 0;
# Faster and is case insensitive
my $query1 = "SELECT `banid` FROM `ban` WHERE `banid` REGEXP '^($host|$user_data{uid}|$user_data{email})' LIMIT 1";
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
# Check for banned usernames, emails and IP addresses.
$ban = $row[0] if ($row[0]);
}
$sth->finish;

      if($ban) {
      # Track Ban
      my $DATE = time || 'DATE';
      $ban = $dbh->quote($ban);
      my $sql = qq(UPDATE `ban` SET `count` =count + 1, `last_date` = '$DATE' WHERE `banid` = $ban LIMIT 1 ;);

      require SQLEdit;
      SQLEdit::SQLAddEditDelete($sql);

      require error;
      error::ban_error();
      }

$cfg{check_ban} = 1;

}


1;