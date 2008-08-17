package exporter;
#
# 10/25/2007 By: N.K.A.
# Note: seems ok with strict
#
# All these are Global
use strict;
# Initialize global variables.
use vars qw(
    $query $dbh $VERSION @ISA @EXPORT
    %cfg %usr %err %msg %btn %nav %inf %hlp %months %week_days
    %user_data %user_action %sub_action %mysql $AUBBC_mod
    );

BEGIN {
# Export global routines and variables.
require Exporter;
require AutoLoader;
@ISA    = qw(Exporter AutoLoader);
@EXPORT = qw(
          $VERSION %cfg %usr %err %msg %btn %nav %inf %hlp
          %months %week_days %adm
          $dbh %user_data $query %user_action %sub_action %mysql $AUBBC_mod
          );

}

1;
