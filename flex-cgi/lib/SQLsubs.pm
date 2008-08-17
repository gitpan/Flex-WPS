package SQLsubs;

# =====================================================================
# Flex - WPS SQL
# SQLsubs version 1.0 Final
#
# Copyright (C) 2006 by N. K. A. (shakainc@tampabay.rr.com)
#
# This program is NOT free software; you can NOT redistribute it and/or
# modify it!
#
# Final
#
# Date: 06/02/2006 11:50:28
# =====================================================================

# Load necessary modules.
use strict;
# Initialize global variables.
use vars qw(
    $query %mysql @row $dbh $VERSION
    %cfg %usr %err %msg
    %user_action $sth $AUBBC_mod
    );

#use lib '.';
use exporter;

sub LoadCGI {
use CGI qw(:standard);
$cfg{max_upload_size} = 100;
$CGI::POST_MAX        = $cfg{max_upload_size} * 1024;
$CGI::DISABLE_UPLOADS = 1;
$CGI::HEADERS_ONCE    = 1;
$query = new CGI;
return $query;
}
sub UpLoadCGI {
use CGI qw(:standard);
$cfg{max_upload_size} = 50000;
$CGI::POST_MAX =  $cfg{max_upload_size} * 1024; # Set maximum upload size.  $cfg{max_upload_size}
$CGI::DISABLE_UPLOADS = 0; # Enable uploads.
$query = new CGI;
return $query;
}
sub SQLConnect {
# Read configuration variables.
require 'config.pl';
# Connect to SQL Backend {Taint=>1}
$dbh = DBI->connect("dbi:mysql:$mysql{backendname}", $mysql{username}, $mysql{password}, {AutoCommit => 0})
or die("Couldn't connect to database! at Read configuration variables");
$cfg{db_fault_error} = 1;
}

sub SQLConfig {
# Get Portal Config 1 of 2
$sth = "SELECT * FROM config WHERE pcfg=1";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth! at Get Portal Config 1");

my ($configid, $portalconfig) = ('','');
while(@row = $sth->fetchrow)  {
       $configid = $row[0];
       $portalconfig = $row[1];
}
$sth->finish();
# Get Portal Config 2 of 2
$sth = 'SELECT * FROM portalconfigs WHERE configid=' . $configid;
#$sth = filters::untaint2($sth, '0-9a-zA-Z\=\*\s');
#die("Couldn't exec sth! at Get Portal Config a2") if !$sth;
$sth = $dbh->prepare($sth) or die $DBI::errstr;
$sth->execute || die("Couldn't exec sth! at Get Portal Config b2");

while(@row = $sth->fetchrow)  {
# Have to clean and setup the config with better stuff!!!
# little cleaner
# not using ip_time, enable_approvals, date_format?,
#
%cfg = (
 configid => $row[0],
 pagename => $row[1],
 pagetitle => $row[2],
 cgi_bin_dir => $row[3],
 non_cgi_dir => $row[4],
 cgi_bin_url => $row[5],
 non_cgi_url => $row[6],
 lang => $row[7],
 codepage => $row[8],
 ip_time => $row[9],
 enable_approvals => $row[10],
 webmaster_email => $row[11],
 mail_type => $row[12],
 mail_program => $row[13],
 smtp_server => $row[14],
 time_offset => $row[15],
 date_format => $row[16],
 cookie_expire => $row[17],
 max_items_per_page => $row[18],
 max_upload_size => $row[19],
 picture_height => $row[20],
 picture_width => $row[21],
 ext => $row[22],
 );
 }
 $sth->finish();

# need to move to lang file.
%usr = (
 admin => 'Administrator',
 mod => 'Moderator',
 user => 'User',
 anonuser => 'Guest',
 sadmin => 'admin',
 sfadmin => 'Admin',
 );

# Build some paths
$cfg{scriptdir}     = $cfg{cgi_bin_dir};
$cfg{datadir}       = $cfg{scriptdir} . '/db'; # F*** this dirctory!
$cfg{libdir}        = $cfg{scriptdir} . '/lib';
$cfg{modulesdir}    = $cfg{scriptdir} . '/lib/modules';
$cfg{portaldir}     = $cfg{scriptdir} . '/lib/portal';
$cfg{langdir}       = $cfg{scriptdir} . '/lang';
# $cfg{themesdir}   = $cfg{cgi_bin_dir} . '/themes-lib'; # test new style
$cfg{imagesdir}     = $cfg{non_cgi_dir} . '/images';
$cfg{pageurl}       = $cfg{cgi_bin_url};
#$cfg{modulesurl}   = $cfg{pageurl} . '/modules'; # and this link too.
$cfg{themesurl}     = $cfg{non_cgi_url} . '/themes';
$cfg{imagesurl}     = $cfg{non_cgi_url} . '/images';

# Load the language library.
my $lang_lib = "$cfg{langdir}/$cfg{lang}.pl";
#$lang_lib = filters::untaint($lang_lib, '\w.*?');
#die("Couldn't Load language File! at Load the language library 1") if !$lang_lib;
if ($lang_lib =~ /^([\w.]+)$/) {
$lang_lib = $1;
} # Redo this or remove
require $lang_lib;
}
sub SQLUserAction {
# User Actions SQL Config
$sth = 'SELECT * FROM useractions WHERE active=1';
$sth = $dbh->prepare($sth) or die("Couldn't exec sth! at SQLUserAction 1");
$sth->execute || die("Couldn't exec sth! at SQLUserAction 2");
while(@row = $sth->fetchrow) {
if ($row[1]) { $user_action{$row[2]} = $row[1] . '::' . $row[2]; }
elsif ($row[2]) { $user_action{$row[2]} = $row[2]; }
}
$sth->finish();

}
#
# ---------------------------------------------------------------------
# Check Auth Session if user is logged in.
# ---------------------------------------------------------------------
sub SQL_Auth_Session {
# Get cookie.
my $pwd   = $query->cookie('ID') || '';

my %user_data  = ();
# Guest Account Settings
my %guest_data = (
   uid => $usr{anonuser},
   nick => $usr{anonuser},
   sec_level => $usr{anonuser},
   us_level => $usr{anonuser},
   email => $usr{anonuser},
   theme => $cfg{default_theme},
   );

# If user isn't logged in.
return %guest_data unless $pwd;

# Check Session Length
# Sha-1 has a length of 40, all the time
return %guest_data if (length($pwd) != 40);

# Data integrity check.
require filters;
$pwd = filters::untaint2($pwd); # if bad will return a blank value
return %guest_data if (!$pwd);

# Get the current date.
require DATE_TIME;
my $date = DATE_TIME::get_date();

        # Get current session
        my ($session_id, $us_name, $date_exp, $last_date) = ('','','','');
        $sth = "SELECT * FROM auth_session WHERE session_id='$pwd'";
        $sth = $dbh->prepare($sth);
        $sth->execute;
        while(my @user_data = $sth->fetchrow)  {
                   $session_id = $user_data[0];
                   $us_name = $user_data[1];
                   $date_exp = $user_data[3];
                   $last_date = $user_data[4];
        }
        $sth->finish();
        # User is Guest if no session data
        return %guest_data unless ($session_id && $us_name && $date_exp && $last_date);

        # Load SQLEdit
        require SQLEdit;
        # Session Expired
        if ($date_exp < $date) {
             my $sql_code = qq(DELETE FROM auth_session WHERE id='$session_id');
             SQLEdit::SQLAddEditDelete($sql_code);
             return %guest_data;
        }

#         # if not active for 20 minutes then remove session ID
#         $last_date += 60 * 20;
#         if ($last_date < $date) {
#              my $sql_code = qq(DELETE FROM auth_session WHERE id='$session_id');
#              SQLEdit::SQLAddEditDelete($sql_code);
#              return %guest_data;
#         }
# Load Sha1
use Digest::SHA1 qw(sha1_hex);
# Get user's data from approved user.
$sth = "SELECT * FROM members WHERE memberid='$us_name' AND approved='1'";
$sth = $dbh->prepare($sth) or die("Couldn't exec sth! at SQL_Auth_Session 2");
$sth->execute || die("Couldn't exec sth! at SQL_Auth_Session 3");

while(my @user_data = $sth->fetchrow) {

# Format Session Key
my $host = $ENV{REMOTE_ADDR} || $ENV{REMOTE_HOST} || '';
$us_name = $user_data[1] . $user_data[2] . $date_exp;
$host = sha1_hex($us_name, $host);

# Check Valid Session
if ($pwd eq $host) {
        # Format User Profile
        my $sec_level = $user_data[8];
        my $stat_level = $user_data[8];

        if ($user_data[8] eq '') {
             $sec_level = $usr{user};
             $stat_level = $usr{user};
        }

        if ($user_data[8] ne ''
        && $user_data[8] ne $usr{user}
        && $user_data[8] ne $usr{admin}
        && $user_data[8] ne $usr{mod}
        && $user_data[8] ne $usr{anonuser}) {
            $sec_level = $usr{user};
            $stat_level = $user_data[8];
        }

%user_data = (
 id => $user_data[0], uid => $user_data[2], pwd => $host,
 nick => $user_data[3], email => $user_data[4], website => $user_data[5],
 website_url => $user_data[6], signature => $user_data[7], xp => $user_data[11],
 sec_level => $sec_level, icq => $user_data[15], pic => $user_data[9],
 joined => $user_data[10], votes => $user_data[12], votes_next => $user_data[13],
 us_level => $stat_level, theme => $user_data[14], yahoo => $user_data[16],
 aim => $user_data[17], msnm => $user_data[18], skype => $user_data[19],
 flag => $user_data[20], gen => $user_data[21], bugbadge => $user_data[22],
 votes_used => $user_data[23], silver => $user_data[24], bronze => $user_data[25],
 buddys => $user_data[26], approved => $user_data[27], admin_ip => $user_data[28],
 cookieuid => '',
 );
   }
        }
        $sth->finish();
        
# no uesr_data return guest account
return %guest_data unless $user_data{uid};

# Check Administrator and Moderator IP - IP Edit in Profile and Need Clear with email.
if ($user_data{admin_ip} && $user_data{admin_ip} ne $ENV{REMOTE_ADDR}
     && ($user_data{sec_level} eq $usr{admin} || $user_data{sec_level} eq $usr{mod})) {
     return %guest_data;
}

        SQLEdit::SQLAddEditDelete("UPDATE `auth_session` SET `date` = '$date' WHERE `id` ='$session_id' LIMIT 1 ;");
        return %user_data; # Finaly ur logged
}

sub AUBBC_Config {
use AUBBC;
$AUBBC::DEBUG_AUBBC = 0;

$AUBBC_mod = new AUBBC;

$AUBBC_mod->settings(
aubbc => 1,
utf => 1,
smileys => 1,
highlight => 1,
no_bypass => 0,
for_links => 0,
aubbc_escape => 1,
icon_image => 1,
image_hight => 60,
image_width => 90,
image_border => 0,
image_wrap => 1,
href_target => 0,
images_url => $cfg{imagesurl},
html_type => 'html',
code_class => ' class="codepost"',
code_extra => '<div style="clear: left"> </div>',
href_class => '',
quote_class => ' class="border"',
quote_extra => '<div style="clear: left"> </div>',
script_escape => 0,
protect_email => 4,
);
my %smileys = ();
my $query1 = "SELECT * FROM smilies;";
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
        $smileys{$row[1]} = $row[2];
}
$sth->finish;
$AUBBC_mod->smiley_hash(%smileys);

require wiki_link;
$AUBBC_mod->add_build_tag('wiki','l,n,-,:,_,s',1,'wiki_link::build_link_name');
$AUBBC_mod->add_build_tag('wkid','n',1,'wiki_link::build_link_id');
require forum_home;
$AUBBC_mod->add_build_tag('id','all',1,'forum_home::build_link_aubbc');
require portal_aubbc;
$AUBBC_mod->add_build_tag('search','all',1,'portal_aubbc::search_links');
$AUBBC_mod->add_build_tag('page','n',1,'portal_aubbc::page_links');

return $AUBBC_mod;
}

1;
