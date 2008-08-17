package rank;

# Load necessary modules.
use strict;

# Assign global variables.
use vars qw(
    %user_action $dbh %cfg %user_data
    );

use exporter;

sub print_ranks {

my $row_color = qq( class="tbl_row_dark");
my $rank = '<table width="55%" border="0" cellspacing="1" cellpadding="4" align="center">';
my $query1 = "SELECT `ranknumber`, `rankname` FROM `rank`";
my $sth = $dbh->prepare($query1);
$sth->execute;
while(my @row = $sth->fetchrow)  {
        $row_color = ($row_color eq qq( class="tbl_row_dark"))
         ? qq( class="tbl_row_light")
         : qq( class="tbl_row_dark");

        $rank .= qq(<tr$row_color>
<td><b>$row[1]</b></td>
<td  align="center"><div style="background-color : #666666; border:1px solid black; padding: 1px 1px 1px 1px;"><img src="$cfg{imagesurl}/rank/$row[1].gif" alt="$row[1]" border="0"></div></td>
<td><b>$row[0] XP</b></td>
</tr>);
}
$sth->finish;

        $rank .= qq(</table>);
        require theme;
        theme::print_header();
        theme::print_html($user_data{theme}, 'Ranks');
        print $rank;
        theme::print_html($user_data{theme}, 'Ranks', 1);
}
1;