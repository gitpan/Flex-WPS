package PM_EMAIL;

#
#
#  PM_EMAIL.pm,v1.0 10/25/2007 By: N.K.A.
#
#  This file is part of Flex-WPS - mySQL.
#
use strict;
use vars qw( %cfg );

use exporter;

# ---------------------------------------------------------------------
# Send emails.
# ---------------------------------------------------------------------
sub send_email {

use Carp;
#use CGI qw(:standard);  # may not need this
        my ($from, $to, $subject, $message) = @_;
        my ($x, $here, $there, $null) = '';

        # Format input.
        $to      =~ s/[ \t]+/, /g;
        $from    =~ s/.*<([^\s]*?)>/$1/;
        $message =~ s/^\./\.\./gm;
       # $message =~ s/\r\n/\n/g;
       # $message =~ s/\n/\r\n/g;

        $cfg{smtp_server} =~ s/^\s+//g;
        $cfg{smtp_server} =~ s/\s+$//g;

        # Send email via SMTP.
        if ($cfg{mail_type} == 1) {
                ($x, $x, $x, $x, $here)  = gethostbyname($null);
                ($x, $x, $x, $x, $there) = gethostbyname($cfg{smtp_server});

                my $thisserver   = pack('S n a4 x8', 2, 0,  $here);
                my $remoteserver = pack('S n a4 x8', 2, 25, $there);

                if (!(socket(S, 2, 1, 6))) { croak "Socket failure. $!"; }
                if (!(bind(S, $thisserver))) { croak "Bind failure. $!"; }
                if (!(connect(S, $remoteserver))) {
                        croak "Connection to $cfg{smtp_server} has failed. $!";
                }

                my $oldfh = select(S);
                $| = 1;
                select($oldfh);
                $_ = <S>;
                if ($_ !~ /^220/) {
                        croak "Sending Email: data in Connect error - 220. $!";
                }
                print S "HELO $cfg{smtp_server}\r\n";
                $_ = <S>;
                if ($_ !~ /^250/) {
                        croak "Sending Email: data in Connect error - 250. $!";
                }
                print S "MAIL FROM:<$from>\n";
                $_ = <S>;
                if ($_ !~ /^250/) {
                        croak "Sending Email: Sender address '$from' not valid. $!";
                }
                print S "RCPT TO:<$to>\n";
                $_ = <S>;
                if ($_ !~ /^250/) {
                        croak "Sending Email: Recipient address '$to' not valid. $!";
                }
                print S "DATA\n";
                $_ = <S>;
                if ($_ !~ /^354/) {
                        croak "Sending Email: Message send failed - 354. $!";
                }
        }

        # Send email via NET::SMTP.
        if ($cfg{mail_type} == 2) {
                eval q^
                        use Net::SMTP;
                        my $smtp = Net::SMTP->new($cfg{smtp_server}, Debug => 0)
                                or croak "Unable to connect to '$cfg{smtp_server}'. $!";

                        $smtp->mail($from);
                        $smtp->to($to);
                        $smtp->data();
                        $smtp->datasend("From: $from\n");
                        $smtp->datasend("Subject: $subject\n");
                        $smtp->datasend("\n");
                        $smtp->datasend($message);
                        $smtp->dataend();
                        $smtp->quit();
                ^;
                if ($@) { croak "Net::SMTP fatal error: $@"; }
                return 1;
        }

        # Send email via sendmail.
        $ENV{PATH} = '';
        if ($cfg{mail_type} == 0) {
                open S, "| $cfg{mail_program} -t" or croak "Mailprogram error. at $!";
        }

         print S <<THE_EMAIL;
From: $from
Subject: $subject
To: $to
X-Mailer: Flex-WPS Mail_Module v1.0
Content-type: text/plain

$message
.

THE_EMAIL

#         print S "Reply-to: $from\n";
#         print S "To: $to\n";
#         print S "Date: "; # Date: Tue, Mar 18 1997 14:36:14 PST
#         print S "X-Mailer: Loris v2.32\n";
#         print S "Subject: $subject\n\n";
#         print S "Content-type: text/plain\n\n";
#         print S "$message";
#         print S "\n\n";

        # Send email via SMTP.
        if ($cfg{mail_type} == 1) {
                $_ = <S>;
                if ($_ !~ /^250/) {
                        croak "Sending Email: Message send failed - try again - 250. $!";
                }
                print S "QUIT\n";
        }

        close(S);
        return 1;
}
1;
