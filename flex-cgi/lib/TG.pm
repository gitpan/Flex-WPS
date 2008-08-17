package TG;
#
# TG: Honey Pot 2
# v1.0
# For all the little trix.
# Spam likes to F#ck themself.
use strict;
# Assign global variables.
use vars qw(
    $dbh %user_data
    $query
    );
use exporter;

# The form feild
sub trapper {   #  class="formfeild"
my $crap = <<HTML;
<div class="formfeild"><input name="formfeild" type="text" value="" size="1" style="font-size: 1px;"></div>
HTML
return $crap;
}

sub checker {
my $formfeild = $query->param('formfeild') || '';
# ban or temp ban
if ($formfeild) {
                # ban the IP
                require SQLEdit;
                my $host = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || '';
                my $DATE = time || 'DATE';
                my $string = qq(INSERT INTO `ban` VALUES ( '$host' , '$DATE' , '1', '$DATE' ););
                SQLEdit::SQLAddEditDelete($string);
                # Ban user name
                #$string = qq(INSERT INTO `ban` ( `banid` ) VALUES ( '$user_data{uid}' );) if $user_data{uid} ne $usr{anonuser};
                #SQLEdit::SQLAddEditDelete($string);
                $dbh->disconnect();
                require error;
                error::ban_error();
}
# TG: End
}
1;