package error;

=head1 COPYLEFT

 $Id: error.pm,v 1.0 5/19/2006 13:37:55 $|-|4X4_|=73}{ Exp $

 This file is part of Flex WPS - Flex Web Portal System.

=cut

#use strict;
use vars qw( %user_data );
#use lib '.';
use exporter;

=head1 NAME

Package error

=head1 DESCRIPTION

 theme moved here for size and speed.

=head1 SYNOPSIS

 use error;
 haha.


=head1 FUNCTIONS

 These functions are available from this package:

=cut

=head2 user_error()

 Display an error message if user input isn't valid.

=cut

sub user_error {
my ($error, $theme) = @_;
#####$| = 1;
if(!$error) { $error = $err{auth_failure}; }
#if(!$theme) { $theme = ;}
require theme;
theme::print_header();
theme::print_html($theme, $nav{error});
print $error;
theme::print_html($theme, $nav{error}, 1);
exit;
}

=head2 user_error()

 Error for banned users.

=cut

sub ban_error {
print "Content-type: text/html\n\n";

        print <<HTML;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Resource is no longer available!</title>
</head>
<body>
<font face="Arial" size="5"><b>Resource is no longer available!</b></font>
<p>
The requested URL is no longer available on this server and there is no<br>
forwarding address.
</body>
</html>
HTML
# Disconnect SQL
$dbh->disconnect() unless (!$cfg{db_fault_error});
exit;
}

1;