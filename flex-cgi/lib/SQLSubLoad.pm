package SQLSubLoad;
# SQLSubLoad.pm,v 3.2 By: N.K.A.
#
# Last Edited: 01-09-2008
#
# This file is part of Flex WPS SQL.
# SQLSubLoad 7 Locations - Modules supported
#
# Notes: This script has had many bugs but v3.0 has addressed all possable issues
# for the future.
#
# Development Notes: In the next version v4.0
# - maybe v3.0 is the best i can think of, unless I go OO.
#
# Version History:
# v3.2 - 01-09-2008
# - Added warning if module does not exist or sub can not be loaded.
#
# v3.1 - 12-07-2007
# - made the code smaller and now uses full directory path to class.
#
# v3.0 - 9-12-2007
# - Add a fail safe if sub(s) can not be loaded do to bad location or not authorized.
# This New method uses parts of v2.0 to fix all known issues.
#
# v2.0 - 1-25-2007
# - Fixed error when files of the same name are in /lib/portal and /lib/modules
#   /lib may have an issue having a *.pm file with the same name as one in /lib/portal or /lib/modules.
#   For this file the issues are fixed but for other parts this issue may show up.
#   If other parts are effected, "use lib 'the_missing_path';" can be used to fix the error.
# - Added SQL column "lib" to "subload" Table for codes in /lib
#
# v1.2 - 10-18-2006
# - Changed a small part of the sub SQLSubLoad to be faster.
#
use strict;
use vars qw(
    $dbh %sub_action %cfg $AUBBC_mod
    );
use exporter;
sub SQLSubLoad {
my $location = shift || '';
my ($load, @subs) = ( '' , () );
# Get Sub's to load for location
$location = $dbh->quote($location);
my $sth = "SELECT * FROM `subload` WHERE `location` = $location";
$sth = $dbh->prepare($sth);
$sth->execute || die("Couldn't exec sth!");
# Table: subload
# id  lib  module  pmname  subname  location
while(my @row = $sth->fetchrow) {

if ($row[0]) {
     $load = 1;
        push (
                @subs,
                join (
                        "|",     $row[0], $row[1],
                        $row[2], $row[3],
                        $row[4], $row[5]
                )
            );
        }
}
$sth->finish();

# Stop if there is nothing to do
if ($load) {
$load = '';
#          # Make New @INC
#          my @NEW = ();
#          foreach (@INC) {
#                    push ( @NEW, $_  ) unless $_ =~ m/\A\.\/lib\/(portal|modules)\z/i;
#          }
#          @INC = @NEW;

no strict 'refs';
foreach (@subs) {
          my (@row) = split (/\|/, $_);
          my $lib_path = '';
          next if (!$row[0]);
          $lib_path = $cfg{libdir} if ($row[1]);
          $lib_path = $cfg{portaldir} if (!$row[1] && !$row[2]);
          $lib_path = $cfg{modulesdir} if ($row[2]);

          unless ($row[3] && -r "$lib_path/$row[3].pm") {
                warn "Module ( $lib_path/$row[3].pm ) does not exist";
                next;
                }

          require "$lib_path/$row[3].pm";

          unless ($row[4] && exists $sub_action{$row[4]}) {
                delete $INC{"$lib_path/$row[3].pm"};
                warn "Module ( $lib_path/$row[3].pm ) Does not support SubLoad ( $row[4] )";
                next;
                }

            $load = $row[3] . '::' . $row[4];
            $load->();
            delete $INC{"$lib_path/$row[3].pm"};
  }
 use strict 'refs';
 # will phase this out.
 #push ( @INC, './lib/portal' ) if $cfg{moduleload} && $cfg{moduleload} eq 2;
 #push ( @INC, './lib/modules' ) if $cfg{moduleload} && $cfg{moduleload} eq 1;
 }
}
1;
