package flat_file;
# Error_Log Module uses this

# Load necessary modules.
use strict;

#use lib '.';
use exporter;
use Fcntl ':flock';
#use Fcntl qw(:DEFAULT :flock); #temp or can be moved to flat_file.pm!
# Log Perl Warnings and Errors - Standard
#BEGIN {
#     use CGI::Carp qw(carpout);
#     open(LOG, ">>", "$cfg{datadir}/error.log")
#         or die "Unable to append to log-log: $!\n";
#     carpout(*LOG);
#}

sub dir2array {
        my $file = shift;
        my @content = ();

        if (!(-d $file)) { return; }
        opendir(DIR, $file);
        @content = readdir(DIR);
        closedir DIR;

        return \@content;
}
# ---------------------------------------------------------------------
# Read file to array and return reference.
# ---------------------------------------------------------------------
sub file2array {
        my $file  = shift;
        my $chomp = shift || 0;
        if (!(-r $file)) { return []; }
        my @content = ();
        #sysopen(FH, $file, O_RDONLY);
        open(FH, '<', $file);
        flock(FH, LOCK_EX);
        @content = <FH>;
        close(FH);

        if ($chomp) { chomp(@content); }

        return \@content;
}

# ---------------------------------------------------------------------
# Read file to scalar and return it.
# ---------------------------------------------------------------------
sub file2scalar {
        my $file  = shift;
        my $chomp = shift || 0;
        my $content = '';
        if (!(-r $file)) { return; }
        #sysopen(FH, $file, O_RDONLY);
        open(FH, '<', $file);
        flock(FH, LOCK_EX);
        $content = <FH>;
        close(FH);

        if ($chomp) { chomp($content); }

        return $content;
}
1;