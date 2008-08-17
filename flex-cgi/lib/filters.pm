package filters;
use strict;
# ---------------------
#  Untaint
# ---------------------
sub untaint {
my $value   = shift || '';
my $pattern = shift || '\w\-\.\/';
return '' unless $value;
$value =~ m!^([$pattern]+)$!i
 ? return $1
 : return;
}
# ---------------------
#  Untaint2
# ---------------------
sub untaint2 {
my $value   = shift || '';
my $pattern = shift || '0-9a-zA-Z\_';
return '' unless $value;
$value !~ m!^([$pattern]+)$!i
 ? return
 : return $1;
}
1;