package rank;

=head1 COPYLEFT

 $Id: rank.pm,v 1.0 5/19/2006 13:37:55 $|-|4X4_|=73}{ Exp $

 This file is part of Flex WPS - Flex Web Portal System.

=cut

use strict;
use vars qw($dbh);
#use lib '.';
use exporter;

=head1 NAME

Package rank

=head1 DESCRIPTION

 rank moved here for size and speed.

=head1 SYNOPSIS

 use rank;
 haha.


=head1 FUNCTIONS

 These functions are available from this package:

=cut

=head2 load_ranks()

 moved in rank.pm

=cut

sub load_ranks {
my @rank;

my($query1) = "SELECT * FROM rank";
my $sth = $dbh->prepare($query1);
$sth->execute || return;
while(my @row = $sth->fetchrow)  {
push (@rank, join ("|", $row[1], $row[2]));
}
$sth->finish;

return unless @rank;
return @rank;
}
1;
