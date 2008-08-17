package chat_text;

# SELECT * FROM pmin WHERE memberid='$user_data{id}'
# ORDERBY date DESC


use strict;
# Assign global variables.
use vars qw(
    %user_data $dbh
    %usr %cfg %msg
    %sub_action %nav
    );
use exporter;

%sub_action = ( print_posts => 1 );
# working
sub print_posts {

# Get chat from Lobby
my $message_time = 990;
my $messages_print = '';
my (@sorted_messages);
my($query1) = qq(SELECT * FROM chat_messages WHERE room_name='Lobby'
ORDER BY date ASC);
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
if ((time - $row[3]) <= $message_time)
{
        push (
                @sorted_messages,
                join (
                        "|",     $row[3],
                        $row[2], $row[5]
                )
            );
 }
}
$sth->finish;
        #require theme;
        #$messages_print .= theme::box_header(' Chatterbox');
#         $messages_print .= qq(<tr width="192">
# <td>);
if (@sorted_messages) {
# Wrap Text
#use Text::Wrap
#$Text::Wrap::columns = 25;
foreach (@sorted_messages) {
                my (
                        $sorted_date,  $name, $message
                    )
                    = split (/\|/, $_);
#$message = wrap('', '', $message) if $message;
                   # $message =~ s{&#39;}{'}gso;
   if ($name eq '[message]' && $message =~ m/\A$user_data{uid}\s\-\s(\S+?)/i) { $messages_print .= $message . '<br> '; }
   elsif ($name eq '[message2]') { $messages_print .= $message . '<br> '; }
   elsif ($name eq $user_data{uid} && $message =~ m/\A\*(\S+?)\:\s(\S+?)/i) { $messages_print .= '<b>' . $message . '</b><br> '; }
   elsif ($name ne $user_data{uid} && $message =~ m/\A\*$user_data{uid}\:\s(\S+?)/i) { $messages_print .= '<b>' . $message . '</b><br> '; }
   elsif ($name ne '[message]' && $name ne '[message2]' && $message !~ m/\A\*(\S+?)/i) { $messages_print .= '<b>' . $name . ':</b> ' . $message . '<br> '; }
        }
  }
   else {
    $messages_print .= ' No Chatter ....';
   }
#         $messages_print .= qq(</td>
# </tr>);
#$messages_print .= theme::box_footer();
print <<HTML;
<table width="185" border="0" cellspacing="4" cellpadding="4" class="navtable" align="center">
<tr>
<td>
 <a href="$cfg{pageurl}/index.$cfg{ext}?op=enter_chat;module=Chat"><font size="4"><b>Chatterbox</b></font></a><br>
$messages_print
</td>
</tr>
</table><hr>
HTML

}
1;
