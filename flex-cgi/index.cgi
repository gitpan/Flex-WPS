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
# Main Index.
#
#
#
# Date: 01/09/2008 12:52:36
# =====================================================================

# Load necessary modules.
use strict;
use vars qw(
    %user_action $query %cfg %err
    %user_data $dbh %nav $AUBBC_mod
    );
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
# Get the input.
my $op = $query->param('op') || '';
my $module = $query->param('module') || '';
# Catch CGI.pm fatal errors.
core::fatal_error('CGI.pm has encounterd an error at CGI.pm') unless (!$query->cgi_error());

# Database Connect
#Memoize::memoize('SQLsubs::SQLConnect');
SQLsubs::SQLConnect();
# Database Config
#Memoize::memoize('SQLsubs::SQLConfig');
SQLsubs::SQLConfig();

# AUBBC Config
Memoize::memoize('SQLsubs::AUBBC_Config');
$AUBBC_mod = SQLsubs::AUBBC_Config();

# Get user profile.
%user_data = SQLsubs::SQL_Auth_Session();

# Subs Load - Location 1. Rest are in theme.pm
# Home load added in sub main_page the location name is 'home'

# Fix for subload's @INC issue, Can be removed?
#$cfg{moduleload} = 2 if !$module && $op;
#$cfg{moduleload} = 1 if $module;

SQLSubLoad::SQLSubLoad('1');

# Catch Black hole error - from stats_log.pm loaded from SQLSubLoad()
core::fatal_error($cfg{system_error}) unless (!$cfg{system_error});

# Error on any bad input, $op and $module Only!
require filters;
if ($op) {
     $op = filters::untaint2($op);
     if(!$op) {
     require error;
     error::user_error($err{bad_input});
     }
}
if ($module) {
     $module = filters::untaint2($module);
     if(!$module) {
     require error;
     error::user_error($err{bad_input});
 }
}

# Define possible user actions. populates %user_action
Memoize::memoize('SQLsubs::SQLUserAction');
SQLsubs::SQLUserAction();

# Load Uncommen Portal Module
my $module_check = 0;
# Check module
if ($module && -r ("$cfg{modulesdir}/$module.pm")) {
# Get user actions from current module
require "$cfg{modulesdir}/$module.pm";
# Check request
   if ($user_action{$op}) {
      $module_check = 1;
      $user_action{$op} = $module . '::' . $op;
      }
       else {
        warn "Portal Module ( $module\:\:$op ) does not supported page view"
       }
}
 elsif ($module) {
        warn "Portal Module ( $module ) does not exist"
 }

no strict 'refs';

# Depending on user action, decide what to do.
if (!$module_check && $user_action{$op}) { # Very Commen Portal Modules
require "$cfg{portaldir}/$1.pm" if ($user_action{$op} =~ m!\A(.+?)\:\:(.+?)\z!i);
$user_action{$op}->();
}
elsif ($module_check) { # Uncommen Portal Module
$user_action{$op}->();
}
else { # Home page
warn "Portal Action ( $op ) not installed" if $op && !$user_action{$op} && !$module;
main_page();
}

# Home/Main Page
sub main_page {

# Print start page.
require theme;
theme::print_header();
theme::print_html($user_data{theme}, $nav{home});
# Home Page Welome Message
my $sth = "SELECT * FROM welcome WHERE active='1'";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't connect to database!"); # use die here
while(my @row = $sth->fetchrow)  {
 if ($row[2]) {
$row[2] = theme::eval_theme_tags($row[2]);
$row[3] = theme::eval_theme_tags($row[3]);
$row[3] = $AUBBC_mod->do_all_ubbc($row[3]);
$row[2] = $AUBBC_mod->do_all_ubbc($row[2]);
print <<HTML;
<table border="0" cellpadding="7" cellspacing="0" width="100%" class="navtable" align="center">
<tr>
<td><p class="texttitle">$row[2]</p>
$row[3]</td>
</tr></table>
HTML
 }
}
$sth->finish;
# Subs Load - Location "home"
SQLSubLoad::SQLSubLoad('home');
theme::print_html($user_data{theme}, $nav{home}, 1);

}
