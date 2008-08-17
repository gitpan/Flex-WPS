package stats_log;
#
# Site logging script for Flex-WPS
# By: Nicholas A.
#
use strict;
use vars qw(
    %user_data %cfg $dbh %sub_action
    $AUBBC_mod
    );
use exporter;

%sub_action = ( log => 1 );

sub log {

my $A_PID = $$ || 'PID';
my $DATE = time || 'DATE';

my $REMOTE_ADDR = $ENV{'REMOTE_ADDR'} || 'R-A';
my $REMOTE_HOST = $ENV{'REMOTE_HOST'} || 'R-H';
my $SCRIPT_NAME = $ENV{'SCRIPT_NAME'} || 'S-N';
my $GATEWAY_INTERFACE = $ENV{'GATEWAY_INTERFACE'} || 'G-I';
my $DOCUMENT_ROOT = $ENV{'DOCUMENT_ROOT'} || 'D-R';

my $SERVER_PORT = $ENV{'SERVER_PORT'} || 'S-P';
my $REMOTE_PORT = $ENV{'REMOTE_PORT'} || 'R-P';

# Not to safe. So we convert some bad characters
# The convetion may make the entries bigger for Black Hole Check.
# But its not that BIG of a deal. =D
my $SERVER_PROTOCOL = $AUBBC_mod->script_escape($ENV{'SERVER_PROTOCOL'}) || 'TCP';
my $REQUEST_METHOD = $AUBBC_mod->script_escape($ENV{'REQUEST_METHOD'}) || 'R-M';
my $QUERY_STRING = $AUBBC_mod->script_escape($ENV{'QUERY_STRING'}) || 'Q-S';
my $HTTP_REFERER = $AUBBC_mod->script_escape($ENV{'HTTP_REFERER'}) || 'H-R';
my $HTTP_ACCEPT_LANGUAGE = $AUBBC_mod->script_escape($ENV{'HTTP_ACCEPT_LANGUAGE'}) || 'A-L';
my $CONTENT_TYPE = $AUBBC_mod->script_escape($ENV{'CONTENT_TYPE'}) || 'C-T';
my $HTTP_USER_AGENT = $AUBBC_mod->script_escape($ENV{'HTTP_USER_AGENT'}) || 'U-A';
my $CONTENT_LENGTH = $AUBBC_mod->script_escape($ENV{'CONTENT_LENGTH'}) || 'C-L';
my $HTTP_COOKIE = $AUBBC_mod->script_escape($ENV{'HTTP_COOKIE'}) || 'H-C';

# Wait Some time befor loading Code.
# my $wait = '';
# my $host = $ENV{'REMOTE_ADDR'} || $ENV{'REMOTE_HOST'} || '';
# # Check Last time IP/domain accessed the site
# my $sth = "SELECT * FROM stats_log";
# $sth = $dbh->prepare($sth);
# $sth->execute || die("Couldn't exec sth!");
# while(my @row = $sth->fetchrow)  {
#        my ($date, undef, $ip, $domain, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef, undef) = split(/\|/, $row[1]);
#         $ip = $ip || $domain || '';
#         if ($ip eq $host && $DATE < $date + 2) {
#             $wait = 1;
#             last;
#         }
# }
# $sth->finish();
#
# # Delay all unless admin.
# if ($wait && $user_data{sec_level} ne $usr{admin}) {
# #      while (1) { # This will loop forever!
# #      last if time () - $DATE > 2; # "last" stops the "while ()" in 2 seconds
# #      }
#        # better
#        sleep(2);
#    }

##############
#print "$A_PID , $DATE , $REMOTE_ADDR , $REMOTE_HOST , $SCRIPT_NAME , $GATEWAY_INTERFACE , $REQUEST_METHOD , $DOCUMENT_ROOT , $QUERY_STRING , $HTTP_REFERER , $HTTP_ACCEPT_LANGUAGE , $CONTENT_TYPE , $HTTP_USER_AGENT , $User_Name";

# Get new date - used for delay code only
# $DATE = time || 'DATE';

push (my @stats,
   join ('|',  $A_PID,       $REMOTE_ADDR,
        $REMOTE_HOST,     "$SERVER_PORT/$REMOTE_PORT", $SERVER_PROTOCOL, $SCRIPT_NAME,
        $GATEWAY_INTERFACE,  $REQUEST_METHOD, $DOCUMENT_ROOT,   $QUERY_STRING,
        $HTTP_REFERER,       $HTTP_ACCEPT_LANGUAGE, $CONTENT_TYPE,    $HTTP_USER_AGENT,
        $CONTENT_LENGTH, $HTTP_COOKIE, $user_data{uid}, $user_data{sec_level})
        );

# System Black Hole
my $Max_Post = 1024 * $cfg{max_upload_size} + 100;
my $Hole_length = "@stats";
$Hole_length = length($Hole_length); # length in bytes

    if ($Hole_length > $Max_Post) {
         # Very large requests are not logged and give an error.
         $cfg{system_error} = 'Request entity too large at System Black Hole';
    }
     else {
     my $q_stats = $dbh->quote("@stats");
     $DATE = $dbh->quote($DATE);
       # Normal Logging
         my $sql = qq(INSERT INTO `stats_log` VALUES ( NULL , $DATE , $q_stats ););
         require SQLEdit;
         SQLEdit::SQLAddEditDelete($sql);
    }
}
1;
