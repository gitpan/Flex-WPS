package Error_Log;
# ==============================================================================
#
# Perl Warning & Error Log View & Delete/Clear.
# Fatal Error Log View & Delete/Clear.
#
# Help: www.shakaflex.com
#
# DJ
# ==============================================================================

# Load necessary modules.
use strict;
use vars qw(
    $query %cfg %user %user_action
    %user_data %usr %err
    );
use exporter;
require flat_file;

# BEGIN
# {
#         use lib '../..';
#         require 'flex.pl';
#         use flex;
# }

# Create a new CGI object.
#my $query = new CGI;

# Get the input.
my $op  = $query->param('op')  || '';

# Error Log
$cfg{errorlog}       = $cfg{datadir} . '/error.log';
$cfg{errorlog2}       = $cfg{datadir} . '/fatal_error.log';

# Get user profile.
#my %user_data = authenticate();

# Define possible user actions.
%user_action = (
    admin_index => 1,
    clear => 1,
    admin_index2 => 1,
    clear2 => 1
);

if ($user_data{sec_level} ne $usr{admin}) {
 require error;
 error::user_error($err{auth_failure}, $user_data{theme});
}

# Depending on user action, decide what to do.
# if ($user_action{$op}) { $user_action{$op}->(); }
# else { admin_index(); }

sub admin_index {

 my $errorlog = flat_file::file2array($cfg{errorlog}, 1);

 require theme;

        theme::print_header();
        theme::print_html($user_data{theme}, "Error Log Admin View");

        print <<HTML;
<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=clear;module=Error_Log">Delete</a></center>
HTML
        if(scalar @{$errorlog} == 0) {
        print "No Errors Found.";
        }
        else {
        require HTML_TEXT;
        foreach my $error (@{$errorlog}) {
                    if ($error) {
                         $error = HTML_TEXT::html_escape($error);
                         print "<br>$error <br>";
                    }
        }
        }
theme::print_html($user_data{theme}, "Error Log Admin View", 1);

}

# ================
# Clear Log file
# ================
sub clear
{
require error;
#require exporter;
use Fcntl ':flock';
                #sysopen(FH, $cfg{errorlog}, O_WRONLY | O_TRUNC)
                open(FH, '>', $cfg{errorlog})
                    or error::user_error("$err{not_writable} $cfg{errorlog}. ($!)",
                        $user_data{theme});
                flock(FH, LOCK_EX);
                print FH "";
                close(FH);

                print $query->redirect(
                -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin_index;module=Error_Log'
                );
}
sub admin_index2 {

 my $errorlog = flat_file::file2array($cfg{errorlog2}, 1);

 require theme;

        theme::print_header();
        theme::print_html($user_data{theme}, "Fatal Error Log Admin View");

        print <<HTML;
<center><a href="$cfg{pageurl}/index.$cfg{ext}?op=clear2;module=Error_Log">Delete</a></center>
HTML
        if(scalar @{$errorlog} == 0) {
        print "No Errors Found.";
        }
        else {
        require HTML_TEXT;
        foreach my $ln (@{$errorlog}) {
                    if ($ln) {
                     $ln =~ s/\|/ - /g;
                     $ln = HTML_TEXT::html_escape($ln);
                         print "<br>$ln <br>";
                    }
        }
        }
theme::print_html($user_data{theme}, "Error Log Admin View", 1);

}

# ================
# Clear fatal Log file
# ================
sub clear2
{
require error;
#require exporter;
use Fcntl ':flock';
                #sysopen(FH, $cfg{errorlog}, O_WRONLY | O_TRUNC)
                open(FH, '>', $cfg{errorlog2})
                    or error::user_error("$err{not_writable} $cfg{errorlog2}. ($!)",
                        $user_data{theme});
                flock(FH, LOCK_EX);
                print FH "";
                close(FH);

                print $query->redirect(
                -location => $cfg{pageurl} . '/index.' . $cfg{ext} . '?op=admin_index2;module=Error_Log'
                );
}
1;