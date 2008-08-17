package core;

# =====================================================================
# Flex-WPS mySQL, Core version 1.0 beta 3
#
# Copyright (C) 2006 by N. K. A. (shakainc@tampabay.rr.com)
#
# This program is NOT free software; you can NOT redistribute it and/or
# modify it!
#
# Main Core.
#
#
#
# Date: 12/27/2001 13:32:54
# =====================================================================

# Clean up the environment.
delete @ENV{qw(IFS CDPATH ENV BASH_ENV)};

# Load necessary modules.
use strict;
use vars qw(%cfg $dbh $VERSION);
use warnings;

use lib 'lib';
use exporter;

# Flex Version
$VERSION = '1.0';

use constant IS_MODPERL => $ENV{MOD_PERL};
use subs qw(exit);
# Select the correct exit function
*exit = IS_MODPERL ? \&Apache::exit(Apache::Constants::DONE) : sub { CORE::exit };

# Nice trick but fixing them makes the code faster
# $SIG{__WARN__} = sub {
#   my $wn = shift;
#   return if $wn =~ /Use of uninitialized value/i;    #Most annoying
#   return if $wn =~ /name "(?:.+?)" used only once/i; #Very annoying
#   warn $wn;
# };

# Catch fatal errors.
$SIG{__DIE__} = \&fatal_error;

use DBI;
use Memoize;

# Used for die(), CGI.pm and upload.cgi
sub fatal_error {

my $error = shift;
$error =~ s/\n/ /gso if $error; # found 1 & removed it for gud, but others can messup the db =P
$error =~ s/\|/&#124;/gso if $error; # just incase
my ($msg, $path) = ('','');
($msg, $path) = split( " at ", $error) if ($error && $error =~ m/\bat\b/io);

                # Update log file.
                use Fcntl ':flock';
                #my $date = CGI::Util::expires('','') || '';
                my $date = scalar(localtime); # same date as the warning log
                $date = '[' . $date . ']' . '|' . $msg . '|' . $path;
                open(FH, '>>' , "./db/fatal_error.log")
                    or die $!;
                flock(FH, LOCK_EX);
                print FH $date . "\n";
                close(FH);

        print "Content-type: text/html\n\n" if !$cfg{theme_printed};
        print <<HTML if !$cfg{theme_printed};
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Fatal Error</title>
</head>
<body>
HTML

print <<HTML;
<font face="arial, verdana, helvetica" size="6"
color="#333366">Flex $VERSION Fatal Error</font>
<hr size="1" color="#000000" noshade>
<font face="arial, verdana, helvetica" size="3" color="#00000">Flex has
exited with the following error:<br><br>
<b>$msg</b><br><br>This error was reported at: <font color="#000099"
face="courier, courier new, arial, verdana, helvetica">$path</font><br><br>
<font size="3" color="#990000"><b>Please inform the webmaster if this
error persists.</b></font>
</body>
</html>
HTML

# DC SQL
$dbh->disconnect() unless (!$cfg{db_fault_error});
exit;
}
1;
