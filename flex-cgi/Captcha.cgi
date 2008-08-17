#!/usr/bin/perl

# Load necessary modules.
use strict;
use vars qw(
    $query %cfg @rand_key $sec_key
    );
use Memoize;
# Load Portal Core
use lib '.';
use core;
use exporter;
use SQLsubs;
use SQLSubLoad;

# Only Called Here!
# Log Perl Warnings and Errors - Standard
    use CGI::Carp qw(carpout);
    open(LOG, '>>', './db/error.log')
        or die "Unable to append to error-log: at $!\n";
    carpout(*LOG);

# Load CGI.pm
$query = SQLsubs::LoadCGI();

 my $image_number   = $query->param('i') || '';
 my $size   = $query->param('a') || '';
 my $security_check   = $query->param('s') || '';
# Catch CGI.pm fatal errors.
core::fatal_error('CGI.pm has encounterd an error at CGI.pm') unless (!$query->cgi_error());

# Database Connect
memoize('SQLsubs::SQLConnect');
SQLsubs::SQLConnect();
# Database Config
memoize('SQLsubs::SQLConfig');
SQLsubs::SQLConfig();

# Get user profile.
#memoize('SQLsubs::SQL_Auth_Session');
%user_data = SQLsubs::SQL_Auth_Session();

# Subs Load - Location 1.
#memoize('SQLSubLoad::SQLSubLoad');
SQLSubLoad::SQLSubLoad('1');

# Catch Black hole error - from stats_log.pm loaded from SQLSubLoad()
core::fatal_error($cfg{system_error}) unless (!$cfg{system_error});
if ($security_check !~ /^[0-9a-z]+$/) {
print "Content-type: text/html\n\n";
exit;
}
# Check param
if ($image_number !~ m!^([0-9\|]+)$!i || !$image_number) {
print "Content-type: text/html\n\n";
exit;
}
if ($size && $size ne 'small') {
print "Content-type: text/html\n\n";
exit;
}
my $width = 375;
my $hight = 100;
my $font_size = 55;
my $lines = 30;
#my $particle = '350 * 50';
my $particle2 = 50;
my $font_size2 = 10;
my $text = ' Type The Black Letters You See. ';

    if ($size eq 'small') {
    $width = 165;
    $hight = 60;
    $font_size = 24;
    $font_size2 = 7;
    $text = ' GD::SecurityImage ';
    $lines = 5;
    #$particle = '350 * 20';
    $particle2 = 2;
    }

$cfg{captchadbdir} = $cfg{modulesdir} . "/Captcha";
require "$cfg{captchadbdir}/rand_key.pl";
my $secret_letter = '';
my $bad = '';

my @stuff = split /\|/, $image_number;
foreach my $let (@stuff) {
$bad = 1 if !$rand_key[$let];
last if $bad;
$secret_letter     .= $rand_key[$let];
}
 $bad = 1 if $secret_letter !~ m!\A\w{6}\z!i;
 # check if key is ok
 $security_check =~ s/(\d{10})\z//;
 my $date = $1;
 $bad = 1 if !$date;
 my $current = time;
 $bad = 1 if $date+360 < $current;
 use Digest::SHA1 qw(sha1_hex);
 my $seckey = $secret_letter;
 $seckey .= $ENV{'REMOTE_ADDR'} . $date;
# require "$cfg{captchadbdir}/rand_key.pl";
 $seckey = sha1_hex($seckey, $sec_key);
 if($security_check ne $seckey) { $bad = 1; }

 if ($bad) {
      print "Content-type: text/html\n\n";
      exit;
      }

   use GD::SecurityImage;
   #my $font  = "$cfg{captchadbdir}/LASVEGSN.TTF";
   my $font  = "$cfg{captchadbdir}/PROGBOT.TTF";
   #my $font  = "$cfg{captchadbdir}/Vivaldii.TTF";

   my $image = GD::SecurityImage->new(
      width  =>   $width,
      height =>    $hight,
      ptsize =>    $font_size,
      lines => $lines,
      rndmax =>     0, # keeping this low helps to display short strings
      frame  =>     0, # disable borders
      font   => $font,
      scramble => 0,
      angle => 0,
      bgcolor    => '#eff5fa',
      gd_font => 'larg',
   );

      $image->random($secret_letter);
      $image->create('ttf', 'ec', '#000000', '#000000');
      #$image->particle($particle, $particle2);

   $image->info_text(
      text   => $text,
      ptsize => $font_size2,
      strip  =>  1,
      color  => '#0094CC',
   );
   $image->info_text(
      text   => ' (c) 2007 Flex-WPS ',
      ptsize => $font_size2,
      strip  =>  1,
      color  => '#0094CC',
      y      => 'down',
   );

   my($image_data, $mime, $random_number) = $image->out;

   binmode STDOUT;
   print "Content-type: image/$mime\n\n";
   print $image_data;
   $dbh->disconnect();
   exit();
