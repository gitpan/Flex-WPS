package Captcha;
# Flex - WPS SQL
# Captch - GD::SecurityImage
# version 1.0
# By: N.K.A.
#
#
#
# 09-15-2007 - Release
#
use strict;
# Assign global variables.
use vars qw(
    %user_action $dbh %cfg %user_data
    $query @rand_key $sec_key
    );
use exporter;
# Define possible user actions.
%user_action = ( ajax_get => 1 );
$cfg{captchadbdir} = $cfg{modulesdir} . "/Captcha";

sub ajax_get {
my $a   = $query->param('a') || '';
$a = '' unless ($a eq 'small');
require "$cfg{captchadbdir}/rand_key.pl";
my ($secret_word, $secret_images) = ('','');
  for my $i (1..6)
  {
     my $letter_index = int(rand 994);
     $secret_images .= qq~$letter_index|~ if $i ne 6;
     $secret_images .= qq~$letter_index~ if $i eq 6;
     my $secret_letter = $rand_key[$letter_index];
     $secret_word .= $secret_letter;
  }

  use Digest::SHA1 qw(sha1_hex);
  my $start_time = time;
  $secret_word .= $ENV{'REMOTE_ADDR'} . $start_time;
  my $security_key2 = sha1_hex($secret_word, $sec_key);
  my $set = qq(<img src="$cfg{pageurl}/Captcha.$cfg{ext}?a=$a;i=$secret_images;s=$security_key2$start_time"><br><small>Not Case Sensitive</small><br>
<input type="text" name="security_key" value="">
<input type="hidden" name="date_captcha" value="$security_key2$start_time"><br>);
print "Content-type: text/html\n\n";
print $set;
 $dbh->disconnect();
 exit();
}

sub get_image
{
# Function: Captcha Auth & Get Images
# Usage: See Top of file!
#
# Code: Captcha 2-2
# Edit at your own Risk

my ($in_action, $seckey, $date_ch) = @_;

if ($in_action eq 'small' || !$in_action) {
$in_action = '' unless $in_action;
require "$cfg{captchadbdir}/rand_key.pl";
my ($secret_word, $secret_images) = ('','');
  for my $i (1..6)
  {
     my $letter_index = int(rand 994);
     $secret_images .= qq~$letter_index|~ if $i ne 6;
     $secret_images .= qq~$letter_index~ if $i eq 6;
     my $secret_letter = $rand_key[$letter_index];
     $secret_word .= $secret_letter;
  }

  use Digest::SHA1 qw(sha1_hex);
  my $start_time = time;
  $secret_word .= $ENV{'REMOTE_ADDR'} . $start_time;
  my $security_key2 = sha1_hex($secret_word, $sec_key);
  my $set = qq(<img src="$cfg{pageurl}/Captcha.$cfg{ext}?a=$in_action;i=$secret_images;s=$security_key2$start_time"><br><small>Not Case Sensitive</small><br>
<input type="text" name="security_key" value="">
<input type="hidden" name="date_captcha" value="$security_key2$start_time"><br>);

  return $set;
}
 else { # new
# Captcha Auth
 if(!$seckey || !$date_ch) { return 0; }
 $seckey = uc($seckey);
 $date_ch =~ s/(\d{10})\z//;
 my $date = $1;
 return 0 if !$date;
 my $current = time;
 #$date += 360; # 5min
 return 0 if $date+360 < $current;
 use Digest::SHA1 qw(sha1_hex);
 $seckey .= $ENV{'REMOTE_ADDR'} . $date;
 require "$cfg{captchadbdir}/rand_key.pl";
 $seckey = sha1_hex($seckey, $sec_key);
 if($date_ch eq $seckey) { return 1; }
 else { return 0; }
 }
}
1;