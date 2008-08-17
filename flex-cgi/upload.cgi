#!/usr/bin/perl
$| = 1;

# =====================================================================
# Flex - WPS SQL
#
# Copyright (C) 2006 by N. K. A. (shakainc@tampabay.rr.com)
#
# This program is NOT free software; you can NOT redistribute it and/or
# modify it!
#
# Upload.
#
# - New version of ExifTool is out, get & use it..
# http://owl.phy.queensu.ca/~phil/exiftool/
#
# This needs to be made this way because of CGI.pm's Header settings.
# Image security methodes Some standard others are extra's by Flex.
#
# Date: 12/02/2006 21:34:28
# =====================================================================

# Load necessary modules.
use strict;
use vars qw(
    %user_action %cfg %user_data $query
    );
# Load Portal Core
use lib '.';
use core;
use exporter;
use SQLsubs;
use SQLSubLoad;

# Only Called Here!
# Database Connect
SQLsubs::SQLConnect();
# Database Config
SQLsubs::SQLConfig();
# Log Perl Warnings and Errors - Standard
    use CGI::Carp qw(carpout);
    open(LOG, ">>", "$cfg{datadir}/error.log")
        or die "Unable to append to log-log: $!\n";
    carpout(*LOG);
# Load CGI.pm
$query = SQLsubs::UpLoadCGI();
# Catch CGI.pm fatal errors.
core::fatal_error("CGI.pm has encounterd an error at $!") unless (!$query->cgi_error());
# Get user profile.
%user_data = SQLsubs::SQL_Auth_Session();
# Subs Load - Location 1. Rest are in theme.pm
# Home load added in sub main_page the location name is 'home'
SQLSubLoad::SQLSubLoad('1');
# Catch Black hole error
core::fatal_error($cfg{system_error}) unless (!$cfg{system_error});

# Check admin's
if($user_data{sec_level} ne $usr{admin}) {
core::fatal_error("$err{auth_failure} at Upload.cgi");
}

my $op = $query->param('op') || '';
my $cat = $query->param('cat') || '';
my $subcat = $query->param('subcat');
my $call_type = $query->param('call_type') || '';
my $name = $query->param('name') || '';
my $up_count = $query->param('up_count') || 5;

if ($up_count) {
$up_count = filters::untaint2($up_count);
    if (!$up_count) {
       require error;
       error::user_error($err{bad_input});
     }
}
if ($op) {
$op = filters::untaint2($op);
    if(!$op) {
       require error;
       error::user_error($err{bad_input});
     }
}
if ($cat) {
$cat = filters::untaint2($cat);
    if(!$cat) {
       require error;
       error::user_error($err{bad_input});
     }
}
if ($subcat) {
$subcat = filters::untaint2($subcat);
    if(!$subcat) {
       require error;
       error::user_error($err{bad_input});
     }
}
if ($call_type) {
$call_type = filters::untaint2($call_type);
    if(!$call_type) {
       require error;
       error::user_error($err{bad_input});
     }
}
if ($name) {
$name = filters::untaint2($name);
    if(!$name) {
       require error;
       error::user_error($err{bad_input});
     }
}
$cfg{gallerydir} = "$cfg{imagesdir}/uploads";
my $allowEightbit = 1;

# Define possible user actions
%user_action = (
 upload => \&upertt,
 final => \&final,
 page => \&page
 );

if ($user_action{$op}) {
$user_action{$op}->();
}
else {
page();
}
sub upertt {
require filters;
require error;

        # Data integrity check
        $call_type = filters::untaint2($call_type);
        error::user_error($err{bad_input}) if !$call_type;
        if ($cat) {
        $cat = filters::untaint2($cat);
        !$cat ? error::user_error($err{bad_input}) : $call_type .= '/' . $cat;
        }
        if ($subcat) {
        $subcat = filters::untaint2($subcat);
        !$subcat ? error::user_error($err{bad_input}) : $call_type .= '/' . $subcat;
        }

        # Image Error and Header module.
        use Image::ExifTool 'ImageInfo';
        my $exifTool = new Image::ExifTool;
        $exifTool->Options(Binary => 1, Composite => 1, DateFormat => '%Y:%m:%d %H:%M:%S', Unknown => 2, Verbose => 0);

        # Process image upload.
        my ($filename, $upload_filehandle, $buffer, $err_msg) = ('','','','');
        # Get the form input and assign the variables.
        foreach my $key (sort {$a cmp $b} $query->param()) {
                next if ($key =~ /^\s*$/);
                next if ($query->param($key) =~ /^\s*$/);
                next if ($key !~ /^picture_(\d+)$/);

                unless ($query->param($key) =~ /([^\/\\]+)\z/) {
                        $err_msg = '1) File Not Writable! at upload param check';
                        last;
                }

                $filename = $1;
                $filename =~ s/^\.+//;
                # Extension Check
                unless ($filename =~ m/\.(gif|GIF|jpg|JPG|png|PNG)\z/i) {
                         $err_msg = '1) Only gif, jpg and png files allowed! at upload Extension';
                         last;
                }
                # Change File name
                if ($name && $up_count eq 1) {
                     $filename =~ s/\A(.*?)\.(.*?)$/\.$2/;
                     $filename = $name . $filename;
                }
                else {
                      if (-r ("$cfg{gallerydir}/$call_type/$filename")) {
                           my $pic_count = 1;
                           $filename =~ s/\A(.*?)\.(.*?)$/$1/;
                           my $extens = '.' . $2;

                           while ($pic_count) {
                                   if (-r ("$cfg{gallerydir}/$call_type/$filename$pic_count$extens")) {
                                        $pic_count++;
                                        next;
                                   }
                                   else {
                                         $filename = $filename . $pic_count . $extens;
                                         last;
                                   }
                           }
                      }

                }
                my $filename2 = $filename;
                $filename = "$cfg{gallerydir}/$call_type/$filename";
                # returns a filehandle
                $upload_filehandle = $query->upload($key);

                # Save image.
                # Will Overwright files with '>'
                unless (open (FH, '>', $filename)) {
                        $err_msg = '2) File Not Writable! at upload open';
                        last;
                }
                #binmode ($upload_filehandle);
                binmode (FH);

                while (<$upload_filehandle>) {
                         # This is realy not needed.
                         # But its one way to find some text files.
                         if ($_ =~ m/(<(html|HTML|script|SCRIPT)>|<?php|<!--(.|\n)*-->)/i) {
                         $err_msg = '2) Only gif, jpg and png files allowed! at upload text/html';
                         last;
                         }
                         else {
                               print FH $_;
                         }
                }

                close FH;

                # Stop loop on error
                if ($err_msg) {
                     unlink($filename);
                     last;
                }

                # Hmmmmm.......
                chmod($filename, 0644);

                # Check File Size 1 mb.
                my $size = (stat($filename))[7];
                unless ($size && $size < (1024 * 1024)) {
                     unlink($filename);
                     $err_msg = '1) File was to Big. at upload Bytes: ' . $size;
                     last;
                }

                # Get file info
                my $info = $exifTool->ImageInfo($filename);

                # File Format Warning or Error
                if ($$info{Warning} || $$info{Error}) {
                      unlink($filename);
                      $err_msg = '2) File format error. at upload format';
                      last;
                }
                # File x, y and Type
                unless ($$info{FileType} && $$info{ImageWidth} && $$info{ImageHeight} && $$info{ImageWidth} < 2000 && $$info{ImageHeight} < 2000
                && ($$info{FileType} eq 'JPG' || $$info{FileType} eq 'GIF' || $$info{FileType} eq 'PNG'|| $$info{FileType} eq 'JPEG')) {
                        unlink($filename);
                        $err_msg = '2) Only gif, jpg and png files allowed! at upload ' . "$$info{FileType} && $$info{ImageWidth} && $$info{ImageHeight}";
                        last;
                }

                # Test all
              #  my $info = $exifTool->ImageInfo($upload_filehandle, \%options);
#                 my $stuff ='';
#                 if ($info || !$info) {
#                     unlink($filename);
#                    foreach (sort keys %$info) {
#                    $stuff .= "$_ => $$info{$_}<br>\n";
#                    }
#                      $err_msg = '8) Only gif, jpg and png files allowed! at upload ' . $stuff;
#                      last;
#                 }

                # Gallery SQL
                if ($call_type =~ 'Gallery') {
                # Load SQLEdit module
                require SQLEdit;
                my $sql_string = qq(INSERT INTO `gallery_x` ( `id` , `cat_id` , `subcat_id` , `pic_disc` , `pic` , `view_ct` )
VALUES (
NULL , '$cat', '$subcat', '$filename2', '$cat/$subcat/$filename2', NULL
););
                SQLEdit::SQLAddEditDelete($sql_string);
                }
        }
if ($err_msg) {
     core::fatal_error($err_msg);
     }
      else {
           print $query->redirect(-location=>"$cfg{pageurl}/upload.$cfg{ext}?op=final");
     }
}

sub final {
print "Content-type: text/html\n\n";
print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Screen</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body bgcolor="#FFFFFF" text="#000000">
<center>Upload(s) Successful!<br>
<a href="javascript:window.close();">Close Window</a></center>
<script type="text/javascript" language="JavaScript1.2">
<!--
window.onload=function(m,u,l)
{
        window.close();
}
//-->
</script>
</body>
</html>
HTML

}
sub page {
print "Content-type: text/html\n\n";
print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Upload Screen</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>

<body bgcolor="#FFFFFF" text="#000000">
<form action="$cfg{pageurl}/upload.$cfg{ext}" method="post" enctype="multipart/form-data">
<table border="0" cellpadding="1" cellspacing="0">
<tr><td colspan="3" height="15">&nbsp;</td></tr>
HTML

        foreach (1 .. $up_count) {
                print <<HTML;
<tr><td>Picture $_</td>
<td width="20">&nbsp;</td>
<td><input name="picture_$_" type="file" accept="image/gif,image/jpg"></td></tr>
HTML
        }

        print <<HTML;
<tr><td colspan="3" height="10">&nbsp;</td></tr>
<tr><td colspan="3">
<input name="name" type="hidden" value="$name">
<input name="cat" type="hidden" value="$cat">
<input name="subcat" type="hidden" value="$subcat">
<input name="op" type="hidden" value="upload">
<input name="call_type" type="hidden" value="$call_type">
<input name="up_count" type="hidden" value="$up_count">
<input type="submit" value="Save Picture">
<tr><td colspan="3" height="10">&nbsp;</td></tr>
<tr><td colspan="3">only_gif_or_jpg</td></tr>
</td></tr></table>
</form><br><center><a href="javascript:window.close();">Close Window</a></center>
</body>
</html>
HTML
}
1;
