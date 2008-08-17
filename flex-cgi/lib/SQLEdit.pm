package SQLEdit;
# Initialize global variables.
use vars qw($dbh);
use exporter;
sub SQLAddEditDelete {
my $string = shift || '';
     $dbh->do($string) unless (!$string);
}
1;